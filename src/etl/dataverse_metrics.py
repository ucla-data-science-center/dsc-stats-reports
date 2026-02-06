import requests
import pandas as pd
from datetime import datetime
import os

# Configuration
DATAVERSE_URL = "https://dataverse.ucla.edu"
OUTPUT_FILE = "data/raw/infrastructure/datasets_files_published_monthly.csv"
API_TOKEN = os.getenv("DATAVERSE_TOKEN")

def fetch_metric(metric_type, to_month):
    """
    Fetches a specific metric (datasets or files) up to a specific month.
    """
    endpoint = f"{DATAVERSE_URL}/api/info/metrics/{metric_type}/toMonth/{to_month}"
    headers = {}
    if API_TOKEN:
        headers["X-Dataverse-key"] = API_TOKEN
        
    try:
        response = requests.get(endpoint, headers=headers)
        response.raise_for_status()
        data = response.json()
        return data['data']['count']
    except Exception as e:
        print(f"Error fetching {metric_type} for {to_month}: {e}")
        return None

def fetch_datasets_by_subject():
    """
    Fetches the distribution of datasets by subject.
    """
    endpoint = f"{DATAVERSE_URL}/api/info/metrics/datasets/bySubject"
    headers = {}
    if API_TOKEN:
        headers["X-Dataverse-key"] = API_TOKEN

    try:
        response = requests.get(endpoint, headers=headers)
        response.raise_for_status()
        return response.json()['data']
    except Exception as e:
        if 'response' in locals():
            print(f"Error fetching datasets by subject: {e}. Body: {response.text[:200]}")
        else:
            print(f"Error fetching datasets by subject: {e}")
        return []

def update_metrics():
    # 1. Generate month range from the end of existing data or a start date
    # Based on the file, it ends at 2024-05.
    start_year = 2019
    start_month = 4
    
    current_date = datetime.now()
    months = []
    
    # Simple loop to generate YYYY-MM strings up to current month
    y, m = start_year, start_month
    while (y < current_date.year) or (y == current_date.year and m <= current_date.month):
        months.append(f"{y}-{m:02d}")
        m += 1
        if m > 12:
            m = 1
            y += 1
            
    results = []
    print(f"Fetching metrics from {DATAVERSE_URL}...")
    
    for month in months:
        print(f"  Processing {month}...", end="\r")
        datasets = fetch_metric("datasets", month)
        files = fetch_metric("files", month)
        downloads = fetch_metric("downloads", month)
        results.append({
            "date": month,
            "datasets_published": datasets,
            "files_published": files,
            "downloads": downloads
        })
        
    df = pd.DataFrame(results)
    
    # Ensure directory exists
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    
    # Save to CSV
    df.to_csv(OUTPUT_FILE, index=False)
    print(f"\nSuccessfully updated {OUTPUT_FILE}")

    # 2. Fetch Datasets by Subject
    print("Fetching datasets by subject...")
    subject_data = fetch_datasets_by_subject()
    if subject_data:
        df_subj = pd.DataFrame(subject_data)
        subj_file = OUTPUT_FILE.replace("datasets_files_published_monthly.csv", "datasets_by_subject.csv")
        df_subj.to_csv(subj_file, index=False)
        print(f"Successfully updated {subj_file}")

if __name__ == "__main__":
    update_metrics()