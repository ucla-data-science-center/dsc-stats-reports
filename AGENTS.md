# AGENTS.md

## Purpose
This file provides starter operating guidance for AI agents working on this project.
Use it with `project-registry.yaml` and repo-local documentation to stay aligned with canonical project context.

## Canonical Repository
- Project key: `dsc_stats_reporting`
- Canonical repository path: `/Users/timdennis/projects/dsc-stats/dsc-stats-reports`
- Status: active

## Context Loading Order
1. `~/projects/project-registry.yaml` for canonical project metadata
2. Repo-local `GEMINI.md` (agent-specific guidance)
3. Repo-local `AGENTS.md` (this file)

## Related Paths
- Website paths:
  - (none)
- Data paths:
  - (none)
- Non-canonical paths:
  - (none)

## Repo-Local Signals
- `_quarto.yml` detected: a Quarto workflow may be in use.
- `pixi.toml` detected: a pixi-managed environment may be in use.
- `GEMINI.md` detected: include it when working with Gemini CLI.

## Rules For Agents
- Work in the canonical repository unless explicitly told otherwise.
- Avoid creating duplicate working copies in Downloads or Documents.
- If registry metadata conflicts with stale notes, prefer `project-registry.yaml`.
- Prefer repo-local `README.md`, `CONTEXT.md`, and `AGENTS.md` when present.

## File Placement Guidance
- Keep this file at repository root as `AGENTS.md`.
- Keep project-level policy updates in `~/projects/project-registry.yaml`.
- Keep implementation details and task plans in repo-local docs where possible.

## Output Expectations For Agents
- Confirm target files before editing.
- Prefer minimal, additive patches.
- Report what changed, why, and any unresolved risks.
- Do not move, rename, or delete repositories unless explicitly instructed.

---

## Runbook (from the former CLAUDE.md)

### Build & preview commands

```bash
pixi run render      # Render all QMD pages → docs/
pixi run preview     # Live preview with auto-reload

## ETL tasks (fetch fresh data)
pixi run update-dataverse      # Fetch Dataverse metrics CSV
pixi run update-dataverse-impact  # Fetch detailed Dataverse impact data
pixi run clean-aws             # Fetch AWS cost data
pixi run update-jira           # Fetch Jira Service Management tickets
```

**Critical**: Always use `pixi run render`, never bare `quarto render`. On macOS/aarch64, the pixi task overrides `QUARTO_*` env vars to use system Quarto (`/Applications/quarto/`) because pixi's bundled aarch64 deno binary is broken.

### Architecture

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

### Environment notes

- Symlink `/Users/timdennis/projects/dsc-stats-reports` → this repo fixes conda RPATH issues baked into pixi env
- `pixi.lock` is committed; do not run `pixi install` manually unless dependencies changed in `pixi.toml`
- `docs/` is committed to version control (enables manual GitHub Pages push without CI)
