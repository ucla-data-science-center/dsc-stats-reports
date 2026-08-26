# Metrics Governance (DSC Stats)

## Purpose

Define consistent, reproducible metrics for UCLA Data Science Center reporting across direct consultations, DataSquad task work, and service desk/ticket systems.

## Core Principle

Do not mix different units of work into a single metric without explicit labeling.

Examples:
- A consultation appointment is not the same as a Trello/GitHub/Jira task.
- A task is not the same as a comment/update on a task.
- A ticket is not the same as a completed resolution.

## Metric Families

### 1) Direct Service Metrics (Consultations)

These represent direct interactions with patrons/researchers.

Examples:
- `dsc_consultations_scheduled_count`
- `datasquad_consultations_direct_count`
- `consultations_total_direct_count`

Primary sources:
- LibInsights / Calendly exports
- DataSquad sign-in forms (walk-ins)

Unit:
- One consultation record / event row (unless a different rule is explicitly documented)

## 2) Task / Workload Metrics (Project Work)

These represent internal/assigned work performed by DSC/DataSquad, not direct consultations.

Examples:
- `datasquad_tasks_created_count`
- `datasquad_tasks_completed_count`
- `datasquad_task_activity_comment_count`
- `datasquad_task_activity_comment_weighted_count`

Primary sources:
- Trello (historical)
- GitHub Projects (current/future)
- Jira Service Desk / JSM (if used for service requests)

Unit:
- Task/card/issue (`task_count_*`) OR activity on a task (`comment_count`, `update_count`)

## 3) Ticket / Service Request Metrics (Jira Service Desk)

These represent service requests submitted and tracked in a ticketing system.

Examples:
- `jsm_tickets_created_count`
- `jsm_tickets_resolved_count`
- `jsm_tickets_open_backlog_count`
- `jsm_ticket_comment_count`

Unit:
- Ticket/issue or ticket activity

## 4) Instruction Attendance Metrics

These represent attendance instances at DSC-supported workshops and instructional events.

Primary sources:
- LibInsight attendee-event exports
- Validated aggregate event summaries when row-level participant data cannot be published

Unit:
- One attendee-event row, or one participant-session included in a documented aggregate attendance count

Aggregate event summaries may contribute to overall, year, event, and compatible topic totals. They must not contribute to UCLA affiliation, department, school/division, participant affiliation, or unique-person metrics unless those dimensions are directly supported by validated source data. Missing institution is unknown, not non-UCLA.

## Metric Naming Guidelines

Use names that encode:
- `who/what` (DSC, DataSquad, JSM)
- `domain` (consultations, tasks, tickets)
- `behavior` (created, completed, resolved, direct, activity)
- `unit` (`count`, `comment_count`, `days`)

Examples:
- Good: `datasquad_trello_task_activity_comment_weighted_count`
- Good: `consultations_direct_count`
- Bad: `total_work` (ambiguous)

## Counting Rules (Required)

Every published metric should document:
- Source system(s)
- Grain/unit (row, card, issue, comment)
- Date field used (`start_date_time`, `last_activity_date`, `created_at`, etc.)
- Inclusion filters (archived cards, list/status filters, canceled appointments)
- Deduplication logic (e.g., `Event UUID` for LibInsights backfills)

If a rule changes, version it or note the effective date.

## Approved Comparisons

Valid:
- Direct consultations by year
- Task workload by year
- Ticket volume by month
- Direct consultations vs task workload (side-by-side, separate metrics)

Use caution:
- Comparing task activity counts to consultation counts as if they are equivalent output

Not valid (without explicit methodology):
- Summing consultations + tasks + comments into one unlabeled “total work” metric

## Recommended Reporting Pattern

For each period (month/quarter/year), report at least:

### Direct Service
- DSC direct consultations
- DataSquad direct consultations
- Total direct consultations

### Workload / Tasks
- Task count (created/completed)
- Task activity (comment/update count or weighted count)
- Backlog snapshot (open tasks)

### Tickets (if Jira Service Desk is in use)
- Tickets created
- Tickets resolved
- Open backlog
- Median/average time to resolution (later phase)

## Source Transition Policy (Trello -> GitHub Projects)

When changing systems:
- Preserve historical source metrics as-is (Trello)
- Add new source metrics (GitHub Projects)
- Create a normalized cross-source task metric only after mapping fields and rules
- Clearly mark transition dates in dashboards/reports

Do not silently splice two systems together without documentation.

## Data Stewardship Rules

- Raw exports are immutable and stored with date-stamped filenames.
- Processed datasets are reproducible from scripts.
- Reference mappings (staff roster, department map, task filters) live in `data/reference/`.
- Dashboard/report numbers must be traceable to a script and a processed output file.
- Restricted participant identifiers must not be copied into public aggregate instruction sources.

## Current Known Caveats (This Repo)

- Trello “comment-weighted” metrics measure task activity, not direct consultations.
- DataSquad sign-in and task sources may have coverage gaps depending on available exports.
- Manual consultation logs from Google Drive may overlap with LibInsights and should be used for reconciliation unless dedup rules are implemented.
