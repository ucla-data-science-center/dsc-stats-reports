#!/usr/bin/env python3
"""Deposit the DSC service-evidence package to UCLA Dataverse as a DRAFT.

Never publishes. Review the draft in the Dataverse web interface and publish
there. The first run creates a dataset in the `dsc` collection and saves its DOI
to scripts/dataverse/deposit_state.json; later runs add or replace files in a
new draft version of the same DOI.

Requires DATAVERSE_TOKEN in the environment or in .env (never committed).

    python scripts/dataverse/deposit.py release/dsc-evidence-v1            # dry run (default)
    python scripts/dataverse/deposit.py release/dsc-evidence-v1 --execute  # create/update the draft
"""
import argparse, csv, json, os, sys
from pathlib import Path
import requests

ROOT = Path(__file__).resolve().parents[2]
BASE = os.environ.get("DATAVERSE_URL", "https://dataverse.ucla.edu")
COLLECTION = os.environ.get("DATAVERSE_COLLECTION", "dsc")
HERE = Path(__file__).resolve().parent
STATE = HERE / "deposit_state.json"


def token():
    tok = os.environ.get("DATAVERSE_TOKEN")
    env = ROOT / ".env"
    if not tok and env.exists():
        for line in env.read_text().splitlines():
            if line.startswith("DATAVERSE_TOKEN="):
                tok = line.split("=", 1)[1].strip().strip('"').strip("'")
    if not tok:
        sys.exit("DATAVERSE_TOKEN not set (add it to .env; see .env.example).")
    return tok


def check(r, what):
    try:
        body = r.json()
    except ValueError:
        body = {"message": r.text[:300]}
    if r.status_code >= 300 or body.get("status") == "ERROR":
        sys.exit(f"{what} failed ({r.status_code}): {body.get('message', body)}")
    return body


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("package", help="package folder built by build_package.py")
    ap.add_argument("--execute", action="store_true", help="actually create or update the draft")
    args = ap.parse_args()

    pkg = (ROOT / args.package).resolve()
    if not (pkg / "MANIFEST.csv").exists():
        sys.exit(f"No MANIFEST.csv in {pkg}; run build_package.py first.")
    desc = {r["file"]: r["description"] for r in csv.DictReader(open(pkg / "MANIFEST.csv"))}
    desc.update({"README.md": "Read me first: scope, units, and what is excluded.",
                 "CODEBOOK.md": "Columns in each data file.",
                 "MANIFEST.csv": "File list with descriptions and SHA-256 checksums."})
    files = sorted(p for p in pkg.iterdir() if p.is_file())
    state = json.loads(STATE.read_text()) if STATE.exists() else {}
    doi = state.get("doi")

    print(f"Dataverse: {BASE}  collection: {COLLECTION}")
    print(f"Dataset: {'existing ' + doi if doi else 'NEW (first deposit)'}")
    print(f"Files ({len(files)}): " + ", ".join(p.name for p in files))
    if not args.execute:
        print("\nDry run only. Re-run with --execute to create or update the DRAFT. Nothing is published.")
        return

    H = {"X-Dataverse-key": token()}
    if not doi:
        meta = json.loads((HERE / "dataset_metadata.json").read_text())
        body = check(requests.post(f"{BASE}/api/dataverses/{COLLECTION}/datasets", headers=H, json=meta, timeout=60),
                     "Create dataset")
        doi = body["data"]["persistentId"]
        STATE.write_text(json.dumps({"doi": doi}, indent=2) + "\n")
        print(f"Created draft dataset {doi}")

    listing = check(requests.get(f"{BASE}/api/datasets/:persistentId/versions/:latest/files",
                                 params={"persistentId": doi}, headers=H, timeout=60), "List files")
    existing = {f["dataFile"]["filename"]: f["dataFile"]["id"] for f in listing["data"]}

    for p in files:
        meta = {"description": desc.get(p.name, ""), "tabIngest": "false"}
        with open(p, "rb") as fh:
            if p.name in existing:
                meta["forceReplace"] = True
                r = requests.post(f"{BASE}/api/files/{existing[p.name]}/replace", headers=H,
                                  files={"file": (p.name, fh)}, data={"jsonData": json.dumps(meta)}, timeout=120)
                check(r, f"Replace {p.name}")
                print(f"  replaced {p.name}")
            else:
                r = requests.post(f"{BASE}/api/datasets/:persistentId/add", params={"persistentId": doi}, headers=H,
                                  files={"file": (p.name, fh)}, data={"jsonData": json.dumps(meta)}, timeout=120)
                check(r, f"Add {p.name}")
                print(f"  added {p.name}")

    print(f"\nDraft ready for review: {BASE}/dataset.xhtml?persistentId={doi}&version=DRAFT")
    print("Nothing was published. Review the draft and publish it in the Dataverse interface.")


if __name__ == "__main__":
    main()
