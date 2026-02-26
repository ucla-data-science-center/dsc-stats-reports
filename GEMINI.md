# Gemini Project Memory: DSC Statistics Reports

## Project Overview
A unified statistics dashboard for the UCLA Library Data Science Center (DSC), using Quarto to generate reports from R and Python data pipelines.

## Context & State (As of 2026-02-05)
- **Environment:** Managed via `pixi`.
- **Infrastructure:** AWS cost retrieval is fully automated via `boto3` in `src/etl/aws_processing.py`.
- **Dataverse:** Metrics collection automated in `src/etl/dataverse_metrics.py`. Note: Site downtime recently caused failures; script uses environment variables for tokens.
- **Normalization:** Codebase successfully reorganized. Raw data in `data/raw`, processed in `data/processed`, ETL logic in `src/etl`. Relative paths in `.qmd` and `.py` files have been verified.

## Recent Reflections
- **API Resilience:** The recent Dataverse outage highlights the need for the dashboard to gracefully handle stale data when APIs are unreachable.
- **Token Security:** Confirmed that sensitive tokens are handled via `os.getenv`, preventing accidental exposure in the repository.
- **Workflow Efficiency:** Moving from static CSV uploads to live API processing (especially for AWS) has significantly reduced the "manual labor" of updating the infrastructure report.

## Brainstorming: Future Metrics & Features
- **Dataverse Impact:**
    - **Top 10 Downloads:** Identify the most popular collections/datasets.
    - **Citations Tracking:** Use DOI/DataCite lookups to count how many times UCLA Dataverse datasets are cited in published research.
    - **Linked Research:** Show the connection between datasets and the resulting peer-reviewed articles.
    - **Subject Diversity:** Visualizing the growth of specific disciplines (e.g., Social Sciences vs. Life Sciences).
- **Consulting Insights:**
    - **Repeat Support:** Distinguish between one-off questions and long-term project support.
    - **Topic Modeling:** Revive the archived R scripts to perform NLP on consultation reasons to identify emerging research trends at UCLA.
- **Visual Enhancements:**
    - **Potree Integration:** Embed 3D point cloud previews directly in the infrastructure report.

## Pending Tasks
- [ ] **Dataverse Recovery:** Re-run `pixi run update-dataverse` once the site is confirmed up.
- [ ] **Full Render:** Execute `pixi run render` to generate the final HTML docs for all pages.
- [ ] **Top Downloads:** Investigate the Dataverse Metrics API for "most downloaded" endpoints.

