# Quarto Dashboard Enrichment Plan (Consultations + Project Work)

## Objective

Expand the Quarto dashboard so it distinguishes:

- `Direct consultations` (DSC / DataSquad)
- `Project work / research support tasks` (Trello historical, GitHub Projects current, Jira JSM optional)
- `Qualitative evidence of work` (themes, outcomes, examples)

This prevents consultation-only reporting from hiding follow-on work.

## Recommended Information Architecture (Consulting / Services Area)

### 1. Direct Consultations (core service interactions)

Purpose:
- Show direct interaction volume and basic service coverage.

Suggested metrics:
- DSC direct consultations (scheduled)
- DataSquad direct consultations (scheduled + walk-in)
- Total direct consultations
- Consultations by year / month
- Consultations by patron type / department (if stable enough)

Suggested labels:
- Use `direct consultations` consistently
- Avoid `total consults` if task metrics appear on same page without a qualifier

Suggested caveat note:
- "Direct consultations capture the intake/interaction portion of service, not all follow-on project work."

### 2. Project Work / Research Support Tasks (workload)

Purpose:
- Represent follow-on labor and assigned work that continues beyond the initial consult.

Subsections:

#### 2a. Historical task activity (Trello)
- Metric: `Task activity (comment-weighted, all)`
- Metric: `Task activity (comment-weighted, reportable filtered)`
- Optional chart: by year (all vs filtered)

Labeling note:
- Call this `task activity`, not `consultations`

#### 2b. Current project work (GitHub Projects)
- Pending integration: `ucla-data-science-center` project #3
- Future metrics:
  - tasks created
  - tasks completed
  - open tasks/backlog
  - tasks involving students (where applicable)

#### 2c. Service requests / tickets (Jira JSM)
- Optional separate panel
- Future metrics:
  - tickets created
  - tickets resolved
  - open backlog
  - ticket activity/comments

### 3. Combined Service Workload (optional summary panel)

Purpose:
- Provide a high-level "total workload picture" while preserving metric boundaries.

Recommended format:
- Side-by-side summary cards, not a single summed metric:
  - Direct consultations
  - Project tasks/activity
  - Service tickets

If using a composite metric, label it explicitly:
- `Combined workload indicators (non-equivalent units)`

## Qualitative Enrichment (Recommended)

### A. Request Themes (text-derived)

Goal:
- Show what kinds of help are being requested, not just counts.

Possible sources:
- LibInsight `Question/Topic` / notes
- GitHub Issue titles + descriptions (project boards)
- Jira ticket summaries / request types

Outputs:
- Top themes by period
- theme trend chart (optional)
- grouped categories (e.g., data cleaning, analysis, coding, visualization, data management)

### B. Project Highlights (human-curated)

Goal:
- Give concrete examples of impact/outcomes.

Format:
- 3-5 short entries per period (month/quarter/year)

Fields:
- request type / topic
- work performed
- outcome/deliverable
- audience (student/faculty/staff)
- tool/system (optional)

### C. Outcomes / Deliverables (lightweight)

Examples:
- dataset prepared/published
- workflow automated
- documentation created
- analysis support completed
- reproducible script/notebook delivered

## On-Page Definitions (Strongly Recommended)

Add a short "How to read these metrics" box:

- `Direct consultations`: one-on-one or walk-in service interactions
- `Project work/tasks`: follow-on assigned work tracked in project systems
- `Task activity (comment-weighted)`: activity indicator, not equal to number of tasks or hours
- `Tickets`: service requests tracked in Jira JSM (if included)

## Implementation Plan (Incremental)

### Phase 1 (now)
- Keep current consultation charts
- Add a "Project Work / Tasks" panel using Trello (all + filtered)
- Add metric definitions/caveats text
- Add 3-5 qualitative highlights manually

### Phase 2
- Add GitHub Projects (#3) extraction and metrics
- Add student involvement dimension (education work)
- Add qualitative themes from GitHub issue text

### Phase 3
- Add Jira Service Desk metrics
- Add cross-source normalized task/ticket reporting
- Add trend lines and throughput/backlog measures

## Suggested Quarto Section Skeleton (copy/adapt)

```markdown
## Direct Consultations

Direct consultations measure one-on-one or walk-in service interactions. They do not include follow-on project work.

<!-- charts: yearly direct consults, patron type, departments -->

## Project Work / Research Support Tasks

Project work captures follow-on labor and assigned research support tasks that continue beyond the initial consultation.

### Historical Task Activity (Trello)

Task activity is reported as a comment-weighted indicator and shown separately from consultation counts.

<!-- charts: trello all vs filtered by year -->

### Current Project Work (GitHub Projects)

<!-- future charts: tasks created/completed/open -->

### Service Requests / Tickets (Jira JSM)

<!-- future charts: tickets created/resolved/open -->

## Qualitative Highlights

The examples below summarize representative work and outcomes from DSC/DataSquad support.

<!-- curated bullets/cards -->

## Metric Definitions & Caveats

- Direct consultations = service interactions
- Tasks/project work = assigned follow-on work
- Task activity (comment-weighted) = activity indicator, not tasks completed or hours worked
```

## Review/Communication Language (Short Version)

"Consultation counts capture direct service interactions, but not all of the follow-on project work required to support research requests. To represent our workload more accurately, the dashboard reports direct consultations separately from project/task activity and service requests, with qualitative examples to show the types of support provided."
