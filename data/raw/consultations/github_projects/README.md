# GitHub Projects Intake (DSC + Education Workstreams)

Drop exports or API snapshots for GitHub Projects here. These will be used for project work/task metrics, not direct consultation counts.

Suggested subfolders:

- `ucla_data_science_center_project3/`
- `uc_ospo_network_project1/`

Recommended raw exports (keep unchanged and date-stamped):

- project items CSV export (if available)
- issue list CSV export
- API JSON snapshots (GraphQL / REST)

Suggested filename pattern:

- `project-items-YYYY-MM-DD.csv`
- `issues-YYYY-MM-DD.csv`
- `project-items-YYYY-MM-DD.json`

Notes:

- Treat GitHub Projects as a task/work source (`task_count`, `task_activity`, `backlog`, `throughput`).
- Keep education/grant work as a distinct `workstream` so it can be reported separately and rolled up.
