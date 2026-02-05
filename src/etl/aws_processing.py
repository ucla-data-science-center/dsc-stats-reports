import pandas as pd
import os
import glob
import re
import boto3
from botocore.exceptions import NoCredentialsError, ClientError

def load_tag_mapping(config_path='config/aws_tags.csv'):
    try:
        if not os.path.exists(config_path):
            # Fallback to relative path if run from root
            config_path = os.path.join('..', config_path)
        
        if os.path.exists(config_path):
            df_tags = pd.read_csv(config_path)
            return dict(zip(df_tags['original_tag'], df_tags['mapped_tag']))
        else:
            print(f"Warning: Config file {config_path} not found. Using empty mapping.")
            return {}
    except Exception as e:
        print(f"Error loading tag mapping: {e}")
        return {}

def get_session(profile='ucla-library-dsc'):
    """
    Creates a boto3 session, favoring environment variables if available.
    """
    try:
        # If running in GitHub Actions or env vars are set, use them
        if os.getenv('AWS_ACCESS_KEY_ID') and os.getenv('AWS_SECRET_ACCESS_KEY'):
            return boto3.Session()
        # Fallback to profile for local use
        return boto3.Session(profile_name=profile)
    except Exception as e:
        print(f"Session Error: {e}")
        return None

def fetch_aws_costs(start_date, end_date, profile='ucla-library-dsc'):
    """
    Fetches AWS costs using the Cost Explorer API.
    Returns a DataFrame with columns: date, application, cost, AFY.
    """
    try:
        session = get_session(profile)
        if not session:
            return pd.DataFrame()
            
        client = session.client('ce')
        
        response = client.get_cost_and_usage(
            TimePeriod={'Start': start_date, 'End': end_date},
            Granularity='MONTHLY',
            Metrics=['NetUnblendedCost'],
            GroupBy=[{'Type': 'TAG', 'Key': 'application'}]
        )
        
        results = []
        for result in response['ResultsByTime']:
            date = result['TimePeriod']['Start']
            for group in result['Groups']:
                app = group['Keys'][0].replace('application$', '')
                if not app: 
                    app = "No Tag"
                cost = float(group['Metrics']['NetUnblendedCost']['Amount'])
                results.append({'date': date, 'application': app, 'cost': cost})
                
        df = pd.DataFrame(results)
        if df.empty:
            return df
            
        df['date'] = pd.to_datetime(df['date'])
        
        # Apply Tag Mapping
        tag_mapping = load_tag_mapping()
        df['application'] = df['application'].map(tag_mapping).fillna(df['application'])
        
        # Calculate AFY (July 1st cutoff)
        df['AFY'] = df['date'].apply(lambda x: x.year + 1 if x.month >= 7 else x.year)
        
        return df

    except Exception as e:
        print(f"AWS API Error: {e}. Falling back to CSV only.")
        return pd.DataFrame()

def fetch_s3_storage_stats(profile='ucla-library-dsc'):
    """
    Retrieves storage size for all S3 buckets using CloudWatch metrics.
    Note: These metrics are reported daily by AWS.
    """
    try:
        session = get_session(profile)
        if not session: return pd.DataFrame()
        
        s3 = session.client('s3')
        cloudwatch = session.client('cloudwatch')
        
        buckets = s3.list_buckets()['Buckets']
        stats = []
        
        from datetime import datetime, timedelta
        end_time = datetime.now()
        start_time = end_time - timedelta(days=2) # Get last 2 days to ensure we find a data point
        
        for bucket in buckets:
            bucket_name = bucket['Name']
            
            # S3 reports BucketSizeBytes per storage type
            response = cloudwatch.get_metric_statistics(
                Namespace='AWS/S3',
                MetricName='BucketSizeBytes',
                Dimensions=[
                    {'Name': 'BucketName', 'Value': bucket_name},
                    {'Name': 'StorageType', 'Value': 'StandardStorage'}
                ],
                StartTime=start_time,
                EndTime=end_time,
                Period=86400,
                Statistics=['Average']
            )
            
            if response['Datapoints']:
                latest_size = response['Datapoints'][-1]['Average']
                stats.append({
                    'bucket': bucket_name,
                    'size_gb': latest_size / (1024**3),
                    'last_updated': response['Datapoints'][-1]['Timestamp']
                })
        
        return pd.DataFrame(stats)
    except Exception as e:
        print(f"S3 Stats Error: {e}")
        return pd.DataFrame()

def process_aws_data(data_dir):
    aws_file = os.path.join(data_dir, 'costs (3).csv')
    try:
        df_aws_wide = pd.read_csv(aws_file)
        df_aws_wide = df_aws_wide.iloc[2:].copy()
        df_aws_wide.rename(columns={df_aws_wide.columns[0]: 'date'}, inplace=True)
        df_aws_wide['date'] = pd.to_datetime(df_aws_wide['date'])
        
        df_aws = df_aws_wide.melt(id_vars=['date', 'Total costs($)'], 
                                  var_name='application', 
                                  value_name='cost')
        
        df_aws['application'] = df_aws['application'].str.replace(r'\(\$\)', '', regex=True).str.strip()
        df_aws['cost'] = pd.to_numeric(df_aws['cost'], errors='coerce')
        df_aws.dropna(subset=['cost'], inplace=True)
        df_aws = df_aws[~df_aws['application'].isin(['Total costs', 'application total'])]

        tag_mapping = load_tag_mapping()
        
        df_aws['application'] = df_aws['application'].map(tag_mapping).fillna(df_aws['application'])
        df_aws['AFY'] = df_aws['date'].apply(lambda x: x.year + 1 if x.month >= 7 else x.year)
        return df_aws
    except Exception as e:
        print(f"Error loading AWS data: {e}")
        return pd.DataFrame()

def extract_ledger_costs(charge_dir):
    ledger_data = []
    messy_pattern = re.compile(r'4\s+\d{5}\s+605000\s+DA\s+03.*?AWS CLOUD SERVICES\s+\d{4}\.\d{2}\s+([0-9,]+\.\d{2})')
    files = glob.glob(os.path.join(charge_dir, "*.csv"))
    
    for f in files:
        filename = os.path.basename(f)
        date_match = re.search(r'(\d{4}-\d{2})', filename)
        if not date_match: continue
        date_str = date_match.group(1)
        
        try:
            with open(f, 'r') as file:
                content = file.read()
            if content.startswith("Loc,Fund"):
                df_temp = pd.read_csv(f)
                df_temp['Account'] = df_temp['Account'].astype(str)
                df_temp['CC'] = df_temp['CC'].astype(str)
                dept_charge = df_temp[(df_temp['Account'] == '605000') & (df_temp['CC'] == 'DA')]
                amount = dept_charge['Credit'].sum() if dept_charge['Credit'].sum() > 0 else dept_charge['Debit'].sum()
                ledger_data.append({'month': date_str, 'ledger_cost': amount})
            else:
                matches = messy_pattern.findall(content)
                total_month = sum(float(m.replace(',','')) for m in matches)
                if total_month > 0:
                    ledger_data.append({'month': date_str, 'ledger_cost': total_month})
        except Exception as e:
            print(f"Error parsing {filename}: {e}")
            
    return pd.DataFrame(ledger_data)
