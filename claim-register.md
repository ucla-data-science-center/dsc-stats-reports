# Claim Register

Every public-facing headline claim (site copy, leadership brief, faculty
page) gets an entry here before it ships. Adopted 2026-09-12 after external
validation of the stats-site redesign approach (see
`validation-prompt-stats-site-storytelling-redesign-2026-09-12.md`) found
our two existing case studies technically correct but at risk of being
compressed into unsupported claims once summarized. This register is the
guard against that.

Update an entry's "Last verified" date whenever the underlying data changes
(a new LibInsight export, a re-run of `instruction_aggregate.R`, a new
identity-resolution pass). A claim whose source data has changed since its
last verification date should not be reused until re-checked.

## 1. Carceral Ecologies processing speedup

- **Approved wording**: "For one documented helicopter-surveillance processing task, an approximately 159-fold runtime reduction was observed under the reported conditions."
- **Not approved**: "DSC made processing 159 times faster" (implies a general DSC capability, not one documented task).
- **Reporting period**: multi-year engagement, outcome reported as of case intake.
- **Unit of observation**: one processing task within one research engagement.
- **Numerator/denominator**: n/a (single before/after measurement, ~318 min -> ~2 min).
- **Population/exclusions**: one case, not generalizable to other engagements.
- **Missingness/coverage**: n/a.
- **Source**: `data/processed/consultations/impact_case_studies.csv`, row 1.
- **Deduplicated**: n/a (single case).
- **Contribution language allowed**: "supported," "enabled" — not "caused" or "achieved" as a DSC-wide capability.
- **Last verified**: 2026-09-12.

## 2. BioCritical Studies Lab award recognition

- **Approved wording**: "DSC contributed data integration, analysis, and visualization support to research later recognized through UCLA's 2024 Public Impact Research Awards."
- **Not approved**: "DSC research won a public-impact award" (DSC did not win the award; the research it supported did).
- **Reporting period**: multi-year engagement, award dated 2024.
- **Unit of observation**: one research engagement.
- **Source**: `data/processed/consultations/impact_case_studies.csv`, row 2.
- **Contribution language allowed**: "contributed to," "supported" — not "won" or "produced."
- **Last verified**: 2026-09-12.

## 3. carp2025 trajectory finding

- **Approved wording**: "Public evidence confirmed at least 10 of 43 qualifying-attendance registrants from the September 2025 UC Carpentries series subsequently observed in research or data-intensive roles."
- **Not approved**: "10 people went on to research careers because of the workshop" (causation not established; role may predate attendance — no role-start date was captured in this pass).
- **Population/exclusions**: 95 net-new UCLA people identified; only 43 had qualifying attendance (not just registration); 2 more had other real DSC engagement, tracked separately.
- **Coverage**: identity resolution run once via ChatGPT on public professional information; not exhaustive, not re-verified since.
- **Source**: `restricted/named-people/carp2025_cohort_2026-09-12.csv` (restricted, not public); public aggregate only in `named-people/README.md`.
- **Deduplicated**: within-cohort yes; cross-cohort against ucworkshop checked 2026-09-12 (0 overlap in the confirmed subset, see entry 5).
- **Contribution language allowed**: "subsequently observed in," "confirmed as holding" — not "went on to," "progressed into," "entered."
- **Last verified**: 2026-09-12.

## 4. ucworkshop trajectory finding

- **Approved wording**: "Public evidence confirmed at least 29 of 123 genuine external registrants across the 2021, 2022, and 2024 joint UC Carpentries series subsequently observed in research or data-intensive roles."
- **Not approved**: same causation/timing caveats as entry 3.
- **Population/exclusions**: 135 net-new UCLA people identified; 7 excluded as DSC staff/DataSquad alumni wrongly swept into the roster, leaving 123 genuine external registrants.
- **Source**: `restricted/named-people/ucworkshop_cohort_2026-09-12.csv` (restricted); public aggregate in `named-people/README.md`.
- **Last verified**: 2026-09-12.

## 5. Combined trajectory count (carp2025 + ucworkshop)

- **Approved wording**: "Across two separately defined cohorts (September 2025, and 2021/2022/2024), public evidence confirmed at least 39 people subsequently observed in research or data-intensive roles."
- **Not approved**: presenting 39 as one cohort, or as a tracer study, or implying systematic/complete coverage.
- **Numerator/denominator**: 39 confirmed of 166 combined qualifying attendees (43 + 123).
- **Dedup check**: run 2026-09-12 — 1 person (Molly Haigh) appears in both full rosters but is not in either confirmed subset, so 10 + 29 = 39 has no double-count. `carp3yr` and `ldw58` passes have NOT been checked against this combined figure; do not fold them in without repeating the overlap check.
- **Contribution language allowed**: "early trajectory signals," "retrospective trajectory tracing" — not "tracer study" or "alumni study" (implies a defined eligible population, observation window, and systematic follow-up this work does not yet have).
- **Last verified**: 2026-09-12.

## 6. UCLA organizational-parent resolved attendance

- **Approved wording**: "838 of UCLA-affiliated attendance records with a known department are mapped to a school, division, or institute; 29 remain in a deliberately unresolved 'Multiple Departments' bucket by policy, not by gap."
- **Not approved**: a department/division leaderboard presented without the coverage note alongside it, or treating unresolved as zero.
- **Source**: `data/reference/instruction/department_to_organizational_parent_v2.tsv`, cross-checked via `tests/test_instruction_aggregate.R`.
- **Last verified**: 2026-09-12 (crosswalk activation of Forestry and Institute of American Cultures).
