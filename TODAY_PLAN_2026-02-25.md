# Today Plan (2026-02-25)

## Goal

Improve DSC/DataSquad reporting so direct consultations are reported separately from project work/tasks, then prepare clearer review language and a dashboard upgrade path.

## Why This Matters (working framing)

Consultation counts capture the direct interaction, but not the follow-on labor. Much of DataSquad and DSC work continues as project work (research support tasks, assigned work, and service requests). If we only count consultations, we understate workload and impact.

## Priority Tasks (Today)

1. Gather recent LibInsight / Calendly exports
- Export latest LibInsight data (covering mid-2024 through today).
- Save raw exports with original filenames/date stamps.
- Put files in canonical raw folder (or linked GDrive import path):
  - `data/raw/consultations/imported_gdrive/libinsights/YYYY/`

2. Gather recent DataSquad direct consult logs
- Update walk-in/sign-in export (if available).
- Save to `data/raw/consultations/` and verify date coverage extends past `2024-06-05`.

3. Confirm current task sources and source-of-record policy
- Historical: Trello (already backfilled from JSON export)
- Current: GitHub Projects (`ucla-data-science-center` project #3)
- Additional ticketing: Jira Service Desk (JSM)
- Decide/report as separate metric families (recommended), with optional rollup.

4. Update task metric filters (reportable work)
- Review Trello list filters in:
  - `data/reference/consultations/trello_task_filters.csv`
- Confirm which lists/statuses should count as reportable work.
- Keep archived/admin/backlog separated or excluded.

5. Refresh counts after new data drops
- Run:
  - `Rscript src/etl/consultation_audit_summary.R`
- Check outputs:
  - `data/processed/consultations/consultation_audit_2023_2025_summary.csv`
  - `data/processed/consultations/consultation_audit_2023_2025_by_year_group.csv`
  - `data/processed/consultations/consultation_audit_2023_2025_by_year_task_mode.csv`

6. Define qualitative evidence inputs (keep small today)
- Pick 1-2 sources for examples/themes:
  - LibInsight meeting notes / request text
  - GitHub project issue titles/comments
  - Jira ticket summaries
- Choose a minimum viable output for dashboard:
  - 3-5 project highlights
  - common request themes
  - example outcomes/deliverables

7. Draft review language (clear and defensible)
- Use terms consistently:
  - `direct consultations`
  - `project work / research support tasks`
  - `service requests / tickets`
- Include one sentence on why consult-only counts understate work.

8. Update dashboard plan (Quarto)
- Add section outline for:
  - Direct Consultations
  - Project Work / Research Support Tasks
  - Qualitative Highlights
- Include metric definitions / caveats on page.

## End-of-Day Deliverables (minimum)

- Latest LibInsight exports added to canonical raw data (or linked import path)
- Refreshed consultation/task audit CSVs
- Draft review paragraph
- Quarto section outline for dashboard enrichment

## Review Language Draft (working)

Consultation counts capture only the intake and direct interaction portion of our service model. A substantial share of DSC and DataSquad labor occurs as follow-on project work (research support tasks, assigned work, and service requests) that extends beyond the initial consultation. To represent this accurately, I report direct consultations separately from project/task workload and ticket-based support, and pair those counts with qualitative examples of outcomes and research support provided.
