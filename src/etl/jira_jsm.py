"""
Jira Service Management ETL — DSC project (key: DSC)

Exports all issues from the DSC Jira service desk project to a dated CSV.

Authentication:
    Reads JIRA_EMAIL and JIRA_API_TOKEN from environment variables.
    Generate a token at: https://id.atlassian.com/manage-profile/security/api-tokens

Usage:
    # Set env vars, then run:
    JIRA_EMAIL=you@example.com JIRA_API_TOKEN=your_token python src/etl/jira_jsm.py

    # Or source a .env file first:
    source .env && python src/etl/jira_jsm.py

    # Via pixi:
    pixi run update-jira

Output:
    data/raw/consultations/jira_service_desk/dsc_issues_YYYY-MM-DD.csv
"""

import os
import csv
import sys
import requests
from datetime import datetime

# ── Configuration ─────────────────────────────────────────────────────────────

JIRA_SITE  = os.getenv("JIRA_SITE", "uclalibrary.atlassian.net")
JIRA_EMAIL = os.getenv("JIRA_EMAIL")
JIRA_API_TOKEN = os.getenv("JIRA_API_TOKEN")

PROJECT_KEY = "DSC"
PAGE_SIZE   = 100

FIELDS = [
    "key",
    "summary",
    "status",
    "issuetype",
    "priority",
    "assignee",
    "reporter",
    "created",
    "updated",
    "resolutiondate",
    "labels",
    "description",
]

OUTPUT_DIR = "data/raw/consultations/jira_service_desk"

# ── Auth ───────────────────────────────────────────────────────────────────────

def get_session():
    if not JIRA_EMAIL or not JIRA_API_TOKEN:
        print("Error: JIRA_EMAIL and JIRA_API_TOKEN must be set.", file=sys.stderr)
        print("  Generate a token at: https://id.atlassian.com/manage-profile/security/api-tokens",
              file=sys.stderr)
        sys.exit(1)
    session = requests.Session()
    session.auth = (JIRA_EMAIL, JIRA_API_TOKEN)
    session.headers.update({"Accept": "application/json", "Content-Type": "application/json"})
    return session

# ── Fetch ──────────────────────────────────────────────────────────────────────

def fetch_all_issues(session, jql, fields):
    """Paginate through all issues matching JQL and return list of raw issue dicts.

    Uses POST /rest/api/3/search/jql with nextPageToken pagination
    (replaces deprecated GET /rest/api/3/search with startAt offset).
    """
    base_url   = f"https://{JIRA_SITE}/rest/api/3/search/jql"
    issues     = []
    next_token = None

    while True:
        body = {"jql": jql, "maxResults": PAGE_SIZE, "fields": fields}
        if next_token:
            body["nextPageToken"] = next_token

        resp = session.post(base_url, json=body)
        resp.raise_for_status()
        data  = resp.json()
        batch = data.get("issues", [])
        issues.extend(batch)

        print(f"  Fetched {len(issues)}...", end="\r")

        next_token = data.get("nextPageToken")
        if not next_token or not batch:
            break

    print()
    return issues

# ── Flatten ────────────────────────────────────────────────────────────────────

def _str(val):
    """Safely convert a value to a flat string."""
    if val is None:
        return ""
    if isinstance(val, dict):
        return val.get("name") or val.get("displayName") or val.get("emailAddress") or ""
    if isinstance(val, list):
        return ";".join(_str(v) for v in val)
    return str(val)

def _description_text(adf):
    """Extract plain text from Atlassian Document Format (ADF) description."""
    if not adf or not isinstance(adf, dict):
        return ""
    texts = []
    def walk(node):
        if isinstance(node, dict):
            if node.get("type") == "text":
                texts.append(node.get("text", ""))
            for child in node.get("content", []):
                walk(child)
    walk(adf)
    return " ".join(texts).strip()

def flatten_issue(issue):
    f = issue.get("fields", {})
    return {
        "key":             issue.get("key", ""),
        "summary":         _str(f.get("summary")),
        "status":          _str(f.get("status")),
        "issuetype":       _str(f.get("issuetype")),
        "priority":        _str(f.get("priority")),
        "assignee":        _str(f.get("assignee")),
        "reporter":        _str(f.get("reporter")),
        "created":         (f.get("created") or "")[:10],
        "updated":         (f.get("updated") or "")[:10],
        "resolutiondate":  (f.get("resolutiondate") or "")[:10],
        "labels":          ";".join(f.get("labels") or []),
        "description":     _description_text(f.get("description")),
        "export_date":     datetime.now().strftime("%Y-%m-%d"),
    }

# ── Main ───────────────────────────────────────────────────────────────────────

def export_dsc_issues():
    session = get_session()

    # Verify connection before paginating
    test = session.get(f"https://{JIRA_SITE}/rest/api/3/myself")
    test.raise_for_status()
    me = test.json()
    print(f"Authenticated as: {me.get('emailAddress')} ({me.get('displayName')})")

    jql = f"project = {PROJECT_KEY} ORDER BY created ASC"
    print(f"Fetching all issues: {jql}")

    issues = fetch_all_issues(session, jql, FIELDS)
    rows   = [flatten_issue(i) for i in issues]

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    today    = datetime.now().strftime("%Y-%m-%d")
    out_path = os.path.join(OUTPUT_DIR, f"dsc_issues_{today}.csv")

    with open(out_path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)

    print(f"Wrote {len(rows)} issues → {out_path}")

    # Print status breakdown
    from collections import Counter
    statuses = Counter(r["status"] for r in rows)
    print("\nStatus breakdown:")
    for status, n in statuses.most_common():
        print(f"  {status or '(none)'}: {n}")

if __name__ == "__main__":
    export_dsc_issues()
