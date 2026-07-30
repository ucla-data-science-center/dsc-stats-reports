# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & preview commands

```bash
pixi run render      # Render all QMD pages → docs/
pixi run preview     # Live preview with auto-reload

# ETL tasks (fetch fresh data)
pixi run update-dataverse      # Fetch Dataverse metrics CSV
pixi run update-dataverse-impact  # Fetch detailed Dataverse impact data
pixi run clean-aws             # Fetch AWS cost data
pixi run update-jira           # Fetch Jira Service Management tickets
```

**Critical**: Always use `pixi run render`, never bare `quarto render`. On macOS/aarch64, the pixi task overrides `QUARTO_*` env vars to use system Quarto (`/Applications/quarto/`) because pixi's bundled aarch64 deno binary is broken.

## Architecture

**Static Quarto website** → `docs/` → GitHub Pages (auto-deployed on push to `main` via `.github/workflows/publish.yml`)

### Report pages (dual-engine)

| File | Engine | Data sources |
|------|--------|-------------|
| `index.qmd` | R/knitr | `consultation_audit_2023_2025_summary_tagged.csv`, `*_by_year_source.csv` |
| `consulting.qmd` | R/knitr | same audit CSVs + `dsc_consult_merged.rds` |
| `instruction.qmd` | R/knitr | `data/processed/instruction/ucla_workshops.rda` |
| `infrastructure.qmd` | Python/jupyter | AWS Cost Explorer API + CloudWatch + Dataverse API + CSVs |
| `about.qmd` | Markdown | static |
| `metrics-governance.md` | Markdown | published as site page |

R pages use tidyverse/ggplot2/DT. The Python page (`infrastructure.qmd`) uses pandas/matplotlib/boto3 with graceful fallback to CSV when AWS credentials are absent.

### ETL pipeline (`src/etl/`)

- `aws_processing.py` — AWS Cost Explorer + CloudWatch S3 metrics (boto3); auth via `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` env vars
- `jira_jsm.py` — Jira Service Management export; auth via `JIRA_EMAIL`/`JIRA_API_TOKEN`
- `dataverse_metrics.py` / `dataverse_impact.py` — UCLA Dataverse API; auth via `DATAVERSE_TOKEN`
- R scripts in `src/etl/` produce the processed CSVs/RDS files consumed by QMD pages

Credentials go in `.env` (gitignored); GitHub Actions secrets supply them in CI.

### Key processed data files

```
data/processed/consultations/
  consultation_audit_2023_2025_summary_tagged.csv   # KPI values (metric_id/value pairs)
  consultation_audit_2023_2025_by_year_source.csv   # YoY by data source
  consultation_audit_2023_2025_by_year_task_mode.csv
  consultation_audit_source_coverage.csv            # date ranges per source
  dsc_consult_merged.rds                            # full consult records (may be absent → graceful fallback)
data/processed/instruction/
  ucla_workshops.rda                                # workshop attendance records
data/raw/infrastructure/
  datasets_files_published_monthly.csv             # Dataverse cumulative metrics
  AWS_Costs/*.csv                                  # monthly cost exports (fallback)
```

### Styling

`styles.css` implements UCLA branding (blue `#2774ae`, gold `#ffd100`). Color contrast ratios are documented in comments — do not lighten UCLA blue (contrast 4.79:1 is at AA minimum). Dashboard is WCAG 2.1 AA compliant; all chart images require alt text.

### Two known unfixable WCAG issues (Quarto framework bugs)

- Duplicate IDs `quarto-text-highlighting-styles` / `quarto-bootstrap` on all pages
- GitHub nav icon `<a>` has no accessible name (aria-label on child `<i>`, not `<a>`)

## Environment notes

- Symlink `/Users/timdennis/projects/dsc-stats-reports` → this repo fixes conda RPATH issues baked into pixi env
- `pixi.lock` is committed; do not run `pixi install` manually unless dependencies changed in `pixi.toml`
- `docs/` is committed to version control (enables manual GitHub Pages push without CI)
