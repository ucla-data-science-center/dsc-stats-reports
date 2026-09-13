# Validation capture: stats-site storytelling redesign

Source prompt: `validation-prompt-stats-site-storytelling-redesign-2026-09-12.md`
External response adjudicated 2026-09-12. Full adopt/reject/defer table
below reflects what was checked against actual project files before
adoption, not the external model's claims taken at face value.

## Adopted and implemented this session

- Labeled the Research Impact case studies "illustrative cases selected to
  show different forms of contribution, not a representative sample"
  (`consulting.qmd`).
- Created `claim-register.md` with approved/not-approved wording for the 6
  claims currently backed by real data (2 case studies, 2 trajectory
  findings, the combined trajectory count, and the crosswalk-resolved
  attendance count).
- Ran the cross-cohort overlap check the reviewer said was missing before
  any combined trajectory figure could be used: carp2025 and ucworkshop
  share exactly 1 person (Molly Haigh) across their full rosters, present
  in neither cohort's confirmed subset. 10 + 29 = 39 is safe to combine;
  `carp3yr` and `ldw58` have not been checked and should not be folded in
  without repeating this.
- Downgraded "tracer study" framing to "early trajectory signals" /
  "retrospective trajectory tracing" and added a timing caveat to
  `named-people/README.md`: a confirmed later role does not establish it
  began after DSC engagement, since no pass captured a role-start date.

## Adopted, not yet implemented (real design/build work, tracked as `dsc_stats_reporting:30`)

- Split into three products: faculty-facing page, two-page campus-leadership
  brief, and the existing Quarto site demoted to an evidence/methods layer.
- Genre: research-support/research-capacity impact report (contribution-focused
  program evaluation), not a blended narrative-dashboard.
- Three impact pathways (Research enabled / Research capability built /
  Shared infrastructure sustained) as the structural spine, with existing
  By Year/By Department/By Affiliation tables demoted to supporting
  evidence beneath each pathway.
- Need roughly 6 varied case studies (currently have 2, both consulting)
  before treating cases as representative; "Shared infrastructure sustained"
  specifically has zero case studies right now.
- Homepage with two visible entry points ("Get research support" /
  "See DSC's campus contribution").

## Deferred

- The reviewer's external citations (Turpen et al. core-facility metrics,
  ACRL Standards for Libraries in Higher Education, CARL Library Impact
  Framework, NSF broader-impacts guidance) were not independently verified
  this session (no fetch tool used). Check before citing publicly.
- Specific proposed titles ("DSC Research Capacity and Impact," etc.) left
  to Tim; naming is a taste call, not a fact check.

## Rejected

- None outright. Every adopted claim survived a check against actual repo
  files (case-study CSV, punch-list numbers, extract scripts, crosswalk
  test) before being accepted, not adopted on the external model's
  authority alone.
