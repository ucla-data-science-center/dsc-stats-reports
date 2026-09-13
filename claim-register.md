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

## 6. Direct consultations, 2023-2025

- **Approved wording**: "DSC and DataSquad recorded 741 direct consultations from 2023 through 2025 (LibInsight scheduled appointments combined with DataSquad walk-in sign-ins, canceled appointments excluded, manual logs deduplicated where possible)."
- **Not approved**: "DSC served 741 researchers" (a consultation is an interaction record, not a unique person — no person-level dedup was done) or presenting 741 as a lifetime/all-time total (it is not; it is 2023-2025 only, and covers a different, narrower reconciliation project than the separate 2017-2026 consultation-series rebuild in `dsc-stats-integration`, which found 1,859 total consultations over that longer window using different methodology).
- **Reporting period**: 2023-2025.
- **Unit of observation**: one consultation record (appointment or sign-in row).
- **Numerator/denominator**: n/a (a count, not a rate).
- **Population/exclusions**: DSC staff consultations (462, LibInsight) + DataSquad consultations (142 direct + sign-in) combined and deduplicated; canceled appointments excluded. A narrower related metric, `direct_consults_dsc_plus_datasquad_count` = 604, excludes some DataSquad sign-in sources included in 741 — the two are different scopes of the same underlying data, not competing measurements of the same thing.
- **Missingness/coverage**: not assessed in this pass; see `consultation_audit_source_coverage.csv` for known gaps.
- **Source**: `data/processed/consultations/consultation_audit_2023_2025_summary_tagged.csv`, metric_id `direct_consults_combined_deduped_count`, dated 2026-02-25. This file predates the September 2026 consultation-series reconciliation in `dsc-stats-integration` and has not been reconciled against it.
- **Deduplicated**: manual-log duplicates flagged heuristically (4 rows); no cross-year or person-level dedup.
- **Contribution language allowed**: "recorded," "combined and deduplicated" — not "served X researchers," not "total" without the 2023-2025 qualifier.
- **Last verified**: 2026-09-13. Previously and incorrectly flagged in `PUNCH-LIST-2026-09-11.md` as having "no surviving source, date, or method" — that was wrong; the source file documents both 604 and 741 clearly in its own columns. Corrected 2026-09-13.

## 7. UCLA organizational-parent resolved attendance

- **Approved wording**: "838 of UCLA-affiliated attendance records with a known department are mapped to a school, division, or institute; 29 remain in a deliberately unresolved 'Multiple Departments' bucket by policy, not by gap."
- **Not approved**: a department/division leaderboard presented without the coverage note alongside it, or treating unresolved as zero.
- **Source**: `data/reference/instruction/department_to_organizational_parent_v2.tsv`, cross-checked via `tests/test_instruction_aggregate.R`.
- **Last verified**: 2026-09-12 (crosswalk activation of Forestry and Institute of American Cultures).

## 7. Direct consultations, 2023-2025

- **Approved wording**: "DSC and DataSquad recorded 741 direct consultations from 2023 through 2025 (LibInsight scheduled appointments combined with DataSquad walk-in sign-ins, canceled appointments excluded, manual logs deduplicated where possible)."
- **Not approved**: "DSC served 741 researchers" (a consultation is an interaction record, not a unique person — no person-level dedup was done) or presenting 741 as a lifetime/all-time total (it is not; it is 2023-2025 only, and covers a different, narrower reconciliation project than the separate 2017-2026 consultation-series rebuild in `dsc-stats-integration`, published as claim #10).
- **Reporting period**: 2023-2025.
- **Unit of observation**: one consultation record (appointment or sign-in row).
- **Numerator/denominator**: n/a (a count, not a rate).
- **Population/exclusions**: DSC staff consultations (462, LibInsight) + DataSquad consultations (142 direct + sign-in) combined and deduplicated; canceled appointments excluded. A narrower related metric, `direct_consults_dsc_plus_datasquad_count` = 604, excludes some DataSquad sign-in sources included in 741 — the two are different scopes of the same underlying data, not competing measurements of the same thing.
- **Missingness/coverage**: not assessed in this pass; see `consultation_audit_source_coverage.csv` for known gaps.
- **Source**: `data/processed/consultations/consultation_audit_2023_2025_summary_tagged.csv`, metric_id `direct_consults_combined_deduped_count`, dated 2026-02-25. This file predates the September 2026 consultation-series reconciliation in `dsc-stats-integration` and has not been reconciled against it.
- **Deduplicated**: manual-log duplicates flagged heuristically (4 rows); no cross-year or person-level dedup.
- **Contribution language allowed**: "recorded," "combined and deduplicated" — not "served X researchers," not "total" without the 2023-2025 qualifier.
- **Last verified**: 2026-09-13. Previously and incorrectly flagged in `PUNCH-LIST-2026-09-11.md` as having "no surviving source, date, or method" — that was wrong; the source file documents both 604 and 741 clearly in its own columns. Corrected 2026-09-13.

## 8. Workshop attendee-events, verified window

- **Approved wording**: "17,466 workshop attendee-events from May 2017 through April 2024."
- **Not approved**: "17,466 people trained" or "17,466 UCLA attendees." An attendee-event is one registration for one workshop, not a person. The total includes the full UC-wide audience of the joint Carpentries series; UCLA is a subset.
- **Reporting period**: 2017-05-04 to 2024-04-19, plus the Sept 2024 UC Carpentries batch.
- **Unit of observation**: one participant registration for one workshop session.
- **Population/exclusions**: attendee-level DSC workshop records (the 15,765 previously published) plus the UC-wide joint Carpentries series DSC co-founded, co-governs, and co-delivers: 2020 +321, 2021 +955, 2022 +425.
- **Missingness/coverage**: 2022's +425 may include a small amount of same-session double counting (no participant log survives to rule it out); disclosed, not resolved.
- **Source**: `data/processed/canonical/headline_aggregates.csv` (`instruction_attendee_events_verified`), from `dsc-stats-integration` `DEFENSIBLE-NUMBERS-2026-09-05.md` (rev. 2026-09-11) and `historical-instruction/instruction-gap-reconciliation.md`. Checked with `/validate-external` 2026-09-11.
- **Deduplicated**: yes, exact-duplicate rows checked against named sources 2026-09-10.
- **Contribution language allowed**: "attendee-events," "workshop registrations," "co-delivered" for the joint series.
- **Last verified**: 2026-09-24.

## 9. Workshop sessions and attendee-events since 2017

- **Approved wording**: "Since 2017, DSC has offered 819 workshop sessions with about 18,700 attendee-events."
- **Not approved**: stating 18,712 as an exact verified count, or as unique people.
- **Reporting period**: 2017-05-04 to 2026-05-31.
- **Unit of observation**: session = distinct (event, date) pair; attendee-event as in #8.
- **Population/exclusions**: #8 plus the 2024-2026 tail: +22 sessions / +235 (Jul 2024-Feb 2026), +9 / +558 (Sept 2025 Carpentries), +6 / +453 (May 2026 Library Carpentry).
- **Missingness/coverage**: the Jul 2024-Feb 2026 slice has not had the duplication check run on #8.
- **Source**: `data/processed/canonical/headline_aggregates.csv` (`instruction_attendee_events_lifetime`, `instruction_sessions_lifetime`), same upstream as #8.
- **Contribution language allowed**: "about," "since 2017."
- **Last verified**: 2026-09-24.

## 10. Recorded consultations, 2017-2026

- **Approved wording**: "DSC has recorded about 1,850 research consultations since 2017, a floor."
- **Not approved**: "1,850 researchers served" (records, not people); presenting the post-mid-2024 drop as a fall in demand. It is a recording gap: Calendly ended mid-2024, LibCal wasn't in use until May 2025, and two reorganizations and staff departures cut logging. LibCal shows the work continued.
- **Reporting period**: 2017 through Sept 2026.
- **Unit of observation**: one consultation record.
- **Per year**: 2017 3, 2018 37, 2019 160, 2020 185, 2021 341, 2022 389, 2023 394, 2024 ~226, 2025 ~60-65, 2026 ~55 (partial). 2024 onward are floors.
- **Population/exclusions**: external research consultations; Shoreline-project and internal-coordination bookings removed from 2017-2020 (Tim-vetted 2026-09-11).
- **Source**: `data/processed/canonical/consultations_by_year.csv`, from `dsc-stats-integration` `historical-consultations/service-activity-reconciliation-status.md`.
- **Why not 1,859**: the 2026-09-11 one-paragraph summary used 2024 = ~230 and 2025 = ~65; the row-level table gives ~226 and ~60-65, summing to 1,850-1,855. "About 1,850" is the defensible rounding.
- **Not the same as #7**: #7 (741) is a separate 2023-2025 audit with DataSquad walk-ins and a different dedup method. The two series haven't been put on one timeline.
- **Last verified**: 2026-09-24.
