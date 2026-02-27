# Jira Service Desk Intake (Optional Task Source)

Drop Jira Service Management exports here for normalization into the consultation/task audit.

Recommended export: CSV issue export with at least these columns (names can vary; we can map them):

- `Issue key`
- `Summary`
- `Status`
- `Created`
- `Updated`
- `Resolved` (if available)
- `Assignee`
- `Reporter`
- `Request type` (or equivalent)
- `Labels`
- `Comments` (count) or a comment export

Notes:
- Jira should be modeled as a task/work-request source, not direct consultations.
- We can add a `jira_service_desk` task metric parallel to Trello / GitHub Projects.
- Keep raw exports unchanged and dated, e.g. `jira-servicedesk-2026-02-25.csv`.
