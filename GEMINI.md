# Gemini Project Memory: DSC Statistics Reports

## Project Overview
A unified statistics dashboard for the UCLA Library Data Science Center (DSC), using Quarto to generate reports from R and Python data pipelines.

## Context & State
- **Environment:** Managed via `pixi`.
- **Primary Reports:** Located in `reports/` (`dsc_report2024.qmd`, `infrastructure.qmd`, etc.).
- **Output:** Rendered to the root `docs/` folder for GitHub Pages.

## Recent Changes (2026-01-29)
- **Codebase Normalization Verified:** Successfully ran `quarto render` after fixing relative paths and `sys.path` imports in `.qmd` and `.py` files.
- **AWS Infrastructure:**
    - Updated `src/etl/aws_processing.py` to use the `ucla-library-dsc` AWS profile.
    - Enhanced `fetch_aws_costs` to include tag mapping and Fiscal Year (AFY) calculation.
    - **Report Update:** `reports/infrastructure.qmd` now pulls **live AWS data** via `fetch_aws_costs` instead of reading static CSVs, resolving data discrepancies.
    - Identified AWS Account ID (`221761179339`) and IAM User (`tdennis`).

## Pending Tasks
- [x] **AWS Access:** Help user regain access to the AWS unit account console. (Login URL: https://221761179339.signin.aws.amazon.com/console)
- [x] **Credentials:** Configure AWS Access Keys (via `aws configure`) to enable the `fetch_aws_costs` automation.
- [x] **Verification:** Run a full `quarto render` to ensure all path changes in `.qmd` files are working correctly with the new structure.

