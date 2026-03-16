# Plan (2026-03-16)

## Goal

Refresh data, update cost pipeline, and improve the infrastructure page — including
exploring the AWS MCP for Potree and Dataverse storage assessment.

---

## Priority Tasks

### 1. Get fresh consultation data (manual exports needed first)

- **LibInsight** — export from Springshare covering 2026-02-14 through today
  - Save to: `data/raw/consultations/imported_gdrive/libinsights/2026/`
  - Current coverage ends: 2026-02-13
- **DataSquad sign-in** — export walk-in sign-in form (Google Form / Sheets)
  - Save to: `data/raw/consultations/datasquad-sign-in.csv` (append or replace)
  - Current coverage ends: 2024-06-05 (9 months stale — high priority)
- After both exports land, re-run the audit:
  ```bash
  Rscript src/etl/consultation_audit_summary.R
  ```
- Verify output CSVs in `data/processed/consultations/` reflect new date coverage

---

### 2. Update AWS cost data

- **Option A (preferred):** Run Cost Explorer API pull — `aws_processing.fetch_aws_costs()`
  is already wired in `infrastructure.qmd`. If AWS creds are active locally, a re-render
  may be sufficient.
- **Option B (fallback):** Export from AWS Cost Explorer console and drop in
  `data/raw/infrastructure/AWS_Costs/` — normalize to match `aws_costs_all_normalized.csv`
- Most recent CSVs in `AWS_Costs/` are dated 2025-08-21; need coverage through 2026-03
- Check if `fetch_aws_costs()` date range in `infrastructure.qmd` line ~37 is still set
  to pull last 12 months (should auto-cover current period)

---

### 3. Explore AWS MCP for storage assessment

The AWS MCP is installed. Before render, use it interactively to:

- **Potree bucket** (`potree-test2`, `us-west-2`):
  - Confirm current total size and object count
  - Compare to CloudWatch's reported value — sanity check
  - Explore whether MCP can give per-prefix breakdown (e.g., by project/dataset)
  - Consider: is per-prefix breakdown worth surfacing on the dashboard?

- **Dataverse bucket** (name TBD — find via MCP):
  - Confirm bucket name and region
  - Get current total size and object count
  - Dataverse cumulative file counts are already on the page via API;
    S3 storage size would be a complementary metric

- **Decision point after exploration:**
  - If MCP gives richer data than CloudWatch, update `aws_processing.py` to use it
    (or add a new `fetch_s3_inventory()` function)
  - If CloudWatch is sufficient, keep as-is and just verify it's healthy

---

### 4. Infrastructure page cleanup

Current page issues to address:

- **Section structure**: Review whether the AWS Costs / S3 Storage / Potree / Dataverse
  sections flow logically — consider grouping by "Costs" vs "Storage & Capacity"
- **Dataverse storage**: Add S3 storage size alongside existing dataset/file/download KPIs
  (pending MCP exploration above)
- **KPI cards**: Infrastructure page has fewer KPI cards than consulting/instruction —
  consider whether AWS total cost and Potree size should be top-line KPIs
- **Data notes**: Update coverage dates after cost refresh

---

### 5. Re-render and commit

After all data refreshes:
```bash
pixi run render
git add -p   # review before staging
git commit
```

---

## Context / Notes

- Current S3 storage pipeline: `aws_processing.fetch_s3_storage_stats()` and
  `fetch_s3_historical_growth('potree-test2', days=365)` — both use boto3 + CloudWatch
- AWS credentials: locally via `ucla-library-dsc` profile; in CI via GitHub secrets
- Potree bucket confirmed: `potree-test2` in `us-west-2` (~11 TB baseline, ~6 GB net growth)
- Cost CSV files in `AWS_Costs/` are stale (last dated 2025-08-21) but the live API
  pull at render time may already be current — verify before re-exporting manually

## Open Questions

- What is the Dataverse S3 bucket name? (Find via AWS MCP or ask Doug/team)
- Should Dataverse S3 storage size be a top-line KPI or just a data note?
- Is the DataSquad sign-in form still being filled out? (9-month gap suggests maybe not)
