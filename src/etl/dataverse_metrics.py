import requests
import pandas as pd
from datetime import datetime
import os
import io

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

def fetch_csv_metric(endpoint_path):
    """
    Fetches metrics that return CSV data (like bySubject or byCategory).
    """
    endpoint = f"{DATAVERSE_URL}/api/info/metrics/{endpoint_path}"
    headers = {}
    if API_TOKEN:
        headers["X-Dataverse-key"] = API_TOKEN

    try:
        response = requests.get(endpoint, headers=headers)
        response.raise_for_status()
        # Dataverse often returns CSV for these endpoints
        if "text/csv" in response.headers.get("Content-Type", "") or "subject,count" in response.text:
            return pd.read_csv(io.StringIO(response.text))
        return pd.DataFrame(response.json()['data'])
    except Exception as e:
        print(f"Error fetching {endpoint_path}: {e}")
        return pd.DataFrame()

def update_metrics():
    # 1. Monthly History
    start_year = 2019
    start_month = 4
    
    current_date = datetime.now()
    months = []
    
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
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    df.to_csv(OUTPUT_FILE, index=False)
    print(f"\nSuccessfully updated {OUTPUT_FILE}")

    # 2. Categorical Metrics
    print("Fetching metrics by subject and category...")
    
    df_subj = fetch_csv_metric("datasets/bySubject")
    if not df_subj.empty:
        subj_file = OUTPUT_FILE.replace("datasets_files_published_monthly.csv", "datasets_by_subject.csv")
        df_subj.to_csv(subj_file, index=False)
        print(f"Successfully updated {subj_file}")

    df_cat = fetch_csv_metric("dataverses/byCategory")
    if not df_cat.empty:
        cat_file = OUTPUT_FILE.replace("datasets_files_published_monthly.csv", "dataverses_by_category.csv")
        df_cat.to_csv(cat_file, index=False)
        print(f"Successfully updated {cat_file}")

if __name__ == "__main__":
    update_metrics()