# Consultation Data Reconciliation Plan

## Goal

Use `dsc-stats-reports` as the single source of truth for consultation and DataSquad activity metrics, with a clear separation between raw inputs, normalized tables, and reporting outputs.

## Canonical Folder Layout

```text
data/
  raw/
    consultations/
      libinsights/
        YYYY/
          libinsights-YYYY-MM-DD.csv
      datasquad_signin/
        YYYY/
          datasquad-signin-YYYY-MM-DD.csv
      datasquad_trello/
        YYYY/
          datasquad-trello-YYYY-MM-DD.csv
  staging/
    consultations/
      *.parquet or *.rds      # lightly cleaned, schema-aligned, source-preserved
  processed/
    consultations/
      consultations_unified.rds
      consultations_unified.csv
      consultation_audit_source_coverage.csv
      consultation_audit_YYYY_YYYY_summary.csv
      consultation_audit_YYYY_YYYY_by_year_group.csv
      consultation_audit_YYYY_YYYY_by_year_source.csv
  reference/
    consultations/
      staff_roster.csv        # person -> team/group history
      department_map.csv      # raw department -> standardized department
```

## Standardization Rules (Going Forward)

1. Preserve raw files exactly as exported.
2. Keep a `source_system` column (`libinsights`, `datasquad_signin`, `trello`).
3. Keep a `source_file` column with the raw filename.
4. Add a stable `record_type` column:
   - `scheduled_consult`
   - `walkin_consult`
   - `trello_task`
5. Add a stable `activity_count_method` column:
   - `row_count`
   - `comment_weighted_row_count` (for current Trello logic)
6. Standardize datetime to UTC in `activity_ts_utc` and also store `activity_date`.
7. Preserve original fields in source-prefixed columns (example: `libinsights_user_name_raw`).
8. Derive `service_group` from a reference roster table, not hard-coded vectors in scripts.
9. Never overwrite prior processed outputs without saving a dated snapshot.

## Reconciliation Workflow (Monthly)

1. Drop new exports into dated source folders under `data/raw/consultations/`.
2. Run ETL to produce source-aligned staging tables with source metadata retained.
3. Run a schema check (required columns, date parse success, duplicate keys).
4. Run coverage audit (`min_date`, `max_date`, row counts by source).
5. Generate unified processed file and reporting summaries.
6. Review deltas against previous month before publishing dashboard updates.

## Immediate Cleanup Tasks

1. Replace hard-coded staff lists in `src/etl/data_cleaning.R` with `data/reference/consultations/staff_roster.csv`.
2. Move department standardization map from R list into `data/reference/consultations/department_map.csv`.
3. Add `source_system` and `record_type` columns to the merged consultation output.
4. Create a backfill step for post-2024-06 consultation exports (currently missing in workspace).
