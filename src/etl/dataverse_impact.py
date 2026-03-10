"""
Dataverse Scholarship Impact ETL

Traces UCLA Dataverse datasets to their linked publications via the
Dataverse metadata API, then enriches with OpenAlex citation counts.

Background / known issues
--------------------------
UCLA Dataverse is currently running version 5.14. Two infrastructure
problems prevent automatic citation tracking through DataCite:

  1. Publication metadata (the 'publication' field in Dataverse) is NOT
     exported to DataCite as relatedIdentifiers (IsSupplementTo / IsCitedBy).
     Datasets therefore show 0 citations in DataCite despite having real
     linked papers. This is a known Dataverse export bug, likely fixed in
     later versions. Migration in progress as of 2026-03.

  2. Make Data Count (MDC) is not enabled on the instance, so per-dataset
     view and download metrics are unavailable.

This script works around both problems by:
  - Fetching publication DOIs directly from the Dataverse metadata API
  - Looking them up in OpenAlex (open, free, no auth required)

When the migration to Dataverse 6.x completes:
  - Re-check DataCite relatedIdentifiers export (should be fixed)
  - Enable MDC for per-dataset metrics
  - This script can then be replaced or supplemented with DataCite Events API

Usage:
    python src/etl/dataverse_impact.py
    pixi run update-dataverse-impact

Output:
    data/raw/infrastructure/dataverse_impact/linked_papers_YYYY-MM-DD.csv
    data/raw/infrastructure/dataverse_impact/dataset_pub_links_YYYY-MM-DD.csv
"""

import csv
import json
import os
import time
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime

DATAVERSE_URL   = "https://dataverse.ucla.edu"
OPENALEX_URL    = "https://api.openalex.org"
OUTPUT_DIR      = "data/raw/infrastructure/dataverse_impact"
MAX_WORKERS     = 8
SEARCH_PER_PAGE = 100
SLEEP_OPENALEX  = 0.15  # OpenAlex polite rate limit

# ── Step 1: collect all dataset DOIs from search index ────────────────────────

def fetch_all_dataset_dois():
    """Paginate the Dataverse search API and return all dataset DOIs."""
    dois   = []
    start  = 0
    total  = None

    while True:
        url = (f"{DATAVERSE_URL}/api/search"
               f"?q=*&type=dataset&per_page={SEARCH_PER_PAGE}&start={start}")
        try:
            with urllib.request.urlopen(url, timeout=10) as r:
                d = json.loads(r.read())
            items = d["data"]["items"]
            for item in items:
                gid = item.get("global_id", "")
                if gid.startswith("doi:"):
                    dois.append(gid.replace("doi:", ""))
            total = d["data"]["total_count"]
            start += SEARCH_PER_PAGE
            print(f"  Collected {len(dois)}/{total} DOIs...", end="\r")
            if start >= total:
                break
            time.sleep(0.05)
        except Exception as e:
            print(f"\n  Warning: search page failed at start={start}: {e}")
            break

    print()
    return dois


# ── Step 2: fetch publication metadata per dataset ────────────────────────────

def fetch_pub_metadata(doi):
    """
    Fetch publication field from a single Dataverse dataset.
    Returns (doi, list_of_pub_dicts) or (doi, None) on error.
    """
    url = f"{DATAVERSE_URL}/api/datasets/:persistentId/?persistentId=doi:{doi}"
    try:
        with urllib.request.urlopen(url, timeout=8) as r:
            d = json.loads(r.read())
        fields = (d.get("data", {})
                   .get("latestVersion", {})
                   .get("metadataBlocks", {})
                   .get("citation", {})
                   .get("fields", []))
        pub_field = next(
            (f for f in fields if f.get("typeName") == "publication"), None
        )
        pubs = []
        if pub_field and isinstance(pub_field.get("value"), list):
            for pub in pub_field["value"]:
                id_type  = pub.get("publicationIDType", {}).get("value", "").lower()
                id_num   = pub.get("publicationIDNumber", {}).get("value", "").strip()
                citation = pub.get("publicationCitation", {}).get("value", "").strip()
                pub_url  = pub.get("publicationURL", {}).get("value", "").strip()
                if id_num:
                    pubs.append({
                        "type": id_type, "id": id_num,
                        "citation": citation[:200], "url": pub_url,
                    })
        return doi, pubs
    except Exception:
        return doi, None


def fetch_all_pub_metadata(dois):
    results = {}
    done    = 0
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as ex:
        futures = {ex.submit(fetch_pub_metadata, doi): doi for doi in dois}
        for fut in as_completed(futures):
            doi, pubs = fut.result()
            results[doi] = pubs
            done += 1
            if done % 50 == 0:
                print(f"  Fetched metadata for {done}/{len(dois)}...", end="\r")
    print()
    return results


# ── Step 3: look up paper DOIs in OpenAlex ────────────────────────────────────

def openalex_lookup(paper_id):
    """
    Resolve a paper DOI or PMID to OpenAlex work metadata.
    Returns dict or None.
    """
    # Normalise full URL DOIs
    if paper_id.startswith("https://doi.org/"):
        paper_id = paper_id.replace("https://doi.org/", "")

    if paper_id.startswith("10."):
        filter_str = f"doi:https://doi.org/{paper_id}"
    else:
        filter_str = f"pmid:{paper_id}"

    url = (f"{OPENALEX_URL}/works"
           f"?filter={filter_str}"
           f"&select=id,doi,title,cited_by_count,publication_year,"
           f"primary_location,authorships")
    try:
        with urllib.request.urlopen(url, timeout=8) as r:
            d = json.loads(r.read())
        works = d.get("results", [])
        if not works:
            return None
        w = works[0]
        loc = w.get("primary_location") or {}
        return {
            "title":    (w.get("title") or "")[:120],
            "year":     w.get("publication_year"),
            "cited_by": w.get("cited_by_count", 0),
            "journal":  (loc.get("source") or {}).get("display_name", ""),
            "oa_id":    w.get("id", ""),
        }
    except Exception:
        return None


def enrich_with_openalex(pub_metadata):
    """
    Given the full pub_metadata dict, collect unique paper IDs,
    look each up in OpenAlex, return {paper_id: openalex_info or None}.
    """
    # Collect unique paper DOIs/PMIDs
    paper_ids = {}
    for dataset_doi, pubs in pub_metadata.items():
        if not pubs:
            continue
        for pub in pubs:
            if pub["type"] in ("doi", "pmid"):
                raw = pub["id"].strip()
                if raw.startswith("https://doi.org/"):
                    raw = raw.replace("https://doi.org/", "")
                if raw not in paper_ids:
                    paper_ids[raw] = []
                paper_ids[raw].append(dataset_doi)

    print(f"  Looking up {len(paper_ids)} unique paper IDs in OpenAlex...")
    results = {}
    for i, (pid, dataset_dois) in enumerate(paper_ids.items()):
        info = openalex_lookup(pid)
        if info:
            info["dataset_dois"] = dataset_dois
        results[pid] = info
        time.sleep(SLEEP_OPENALEX)
        if (i + 1) % 5 == 0:
            print(f"  {i+1}/{len(paper_ids)}...", end="\r")

    found = sum(1 for v in results.values() if v)
    print(f"\n  Found {found}/{len(results)} papers in OpenAlex")
    return results


# ── Step 4: write outputs ─────────────────────────────────────────────────────

def write_outputs(pub_metadata, openalex_results, export_date):
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    found_ids = {k for k, v in openalex_results.items() if v}

    # Paper-level CSV
    paper_rows = []
    for pid, info in openalex_results.items():
        if info:
            paper_rows.append({
                "paper_id":        pid,
                "title":           info["title"],
                "year":            info["year"],
                "journal":         info["journal"],
                "cited_by":        info["cited_by"],
                "linked_datasets": ";".join(info["dataset_dois"]),
                "dataset_count":   len(info["dataset_dois"]),
                "openalex_id":     info["oa_id"],
                "export_date":     export_date,
            })
        else:
            paper_rows.append({
                "paper_id": pid, "title": "", "year": "", "journal": "",
                "cited_by": "", "linked_datasets": "", "dataset_count": "",
                "openalex_id": "not_found", "export_date": export_date,
            })

    papers_path = os.path.join(OUTPUT_DIR, f"linked_papers_{export_date}.csv")
    with open(papers_path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=paper_rows[0].keys())
        w.writeheader(); w.writerows(paper_rows)

    # Dataset-level CSV
    dataset_rows = []
    for dataset_doi, pubs in pub_metadata.items():
        if pubs is None:
            status = "restricted_or_error"
            pub_types = paper_ids_str = in_oa = ""
        elif not pubs:
            status = "no_publication_field"
            pub_types = paper_ids_str = in_oa = ""
        else:
            types    = set(p["type"] for p in pubs)
            ids      = [p["id"] for p in pubs if p["type"] in ("doi", "pmid")]
            status   = "linked"
            pub_types      = ";".join(types)
            paper_ids_str  = ";".join(ids)
            in_oa          = str(any(i in found_ids for i in ids))

        dataset_rows.append({
            "dataset_doi": dataset_doi,
            "link_status": status,
            "pub_types":   pub_types,
            "paper_ids":   paper_ids_str,
            "in_openalex": in_oa,
            "export_date": export_date,
        })

    links_path = os.path.join(OUTPUT_DIR, f"dataset_pub_links_{export_date}.csv")
    with open(links_path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=dataset_rows[0].keys())
        w.writeheader(); w.writerows(dataset_rows)

    return papers_path, links_path


# ── Main ───────────────────────────────────────────────────────────────────────

def run():
    export_date = datetime.now().strftime("%Y-%m-%d")

    print("Step 1: Collecting dataset DOIs from Dataverse search...")
    dois = fetch_all_dataset_dois()
    print(f"  {len(dois)} DOIs collected")

    print("\nStep 2: Fetching publication metadata per dataset...")
    pub_metadata = fetch_all_pub_metadata(dois)
    has_pub = sum(1 for v in pub_metadata.values() if v)
    errors  = sum(1 for v in pub_metadata.values() if v is None)
    print(f"  {has_pub} with publication field | {errors} restricted/errors")

    print("\nStep 3: Enriching with OpenAlex citation data...")
    openalex_results = enrich_with_openalex(pub_metadata)

    print("\nStep 4: Writing outputs...")
    papers_path, links_path = write_outputs(pub_metadata, openalex_results, export_date)
    print(f"  {papers_path}")
    print(f"  {links_path}")

    # Summary
    found  = {k: v for k, v in openalex_results.items() if v}
    all_ds = set()
    for v in found.values():
        all_ds.update(v["dataset_dois"])
    total_cites = sum(v["cited_by"] for v in found.values())

    print(f"""
Summary
-------
  Datasets surveyed:                {len(dois)}
  Datasets with publication links:  {has_pub}
  Unique papers found in OpenAlex:  {len(found)}
  Datasets linked to those papers:  {len(all_ds)}
  Total citations:                  {total_cites}

Known limitations (migration in progress)
-----------------------------------------
  - Dataverse 5.14: publication field not exported to DataCite
    relatedIdentifiers → DataCite shows 0 citations for all datasets
  - Make Data Count not enabled → no per-dataset view/download stats
  - 562 datasets inaccessible (restricted/draft) → undercounts real impact
  - 160 ISBN-linked datasets (book chapters) not tracked via OpenAlex
  These issues are expected to improve after migration to Dataverse 6.x.
""")


if __name__ == "__main__":
    run()
