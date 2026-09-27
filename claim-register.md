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
- **Status**: superseded 2026-09-26 by #12 as the published instruction figure. Kept for documents that already cite it; do not use in new copy.

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
- **Status**: the attendee-event figure (about 18,700) is superseded 2026-09-26 by #12. The session count (819, May 2017 to May 2026) is still current.

## 10. Recorded consultations, 2017-2026

- **Approved wording**: "DSC has recorded about 1,850 research consultations since 2017, a floor."
- **Not approved**: "1,850 researchers served" (records, not people); presenting the post-mid-2024 drop as a fall in demand. It is a recording gap: Calendly ended mid-2024, LibCal wasn't in use until May 2025, and two reorganizations and staff departures cut logging. LibCal shows the work continued.
- **Reporting period**: 2017 through Sept 2026.
- **Unit of observation**: one consultation record.
- **Per year**: 2017 3, 2018 37, 2019 160, 2020 185, 2021 341, 2022 389, 2023 394, 2024 ~226, 2025 ~60-65, 2026 ~55 (partial). 2024 onward are floors.
- **Population/exclusions**: external research consultations booked as scheduled appointments (Calendly, then LibInsight and LibCal), including appointments with DataSquad student consultants; Shoreline-project and internal-coordination bookings removed from 2017-2020 (Tim-vetted 2026-09-11). DataSquad in-person walk-in sign-ins are not included (checked 2026-09-27: Jan-May 2024 scheduled appointments agree with the separate records file, 165 vs 166, which also holds walk-in sign-ins).
- **Source**: `data/processed/canonical/headline_aggregates.csv` (`consultations_recorded_series`) and `consultations_by_year.csv`, from `dsc-stats-integration` `historical-consultations/service-activity-reconciliation-status.md`.
- **Why not 1,859**: the 2026-09-11 one-paragraph summary used 2024 = ~230 and 2025 = ~65; the row-level table gives ~226 and ~60-65, summing to 1,850-1,855. "About 1,850" is the defensible rounding.
- **Not the same as #7**: #7 (741) is a separate 2023-2025 audit with DataSquad walk-ins and a different dedup method. The two series haven't been put on one timeline.
- **Last verified**: 2026-09-24.

## 11. UCLA-held workshop attendance, 2017-2020

- **Approved wording**: "Before DSC began teaching systemwide, its workshops at UCLA drew about 2,800 attendee-events (2017-2020)." On the instruction page: "UCLA-held" attendance.
- **Not approved**: calling these UCLA-affiliated people or unique people; adding the 926 attendee-events from mixed sessions to the UCLA figure.
- **Reporting period**: 2017-05-04 to 2020-12-01.
- **Unit of observation**: attendee-event.
- **Per year (blank-institution records from UCLA-held sessions)**: 2017 273, 2018 378, 2019 641, 2020 1,483 (about 1,290 of it the Spring 2020 online R series). Total 2,775.
- **Population/exclusions**: sessions classified `ucla` in `data/reference/instruction/session_venue_2017_2020.tsv`. Excluded: 23 mixed sessions (926 attendee-events: USC and CSU Long Beach Library Carpentry, fall 2020 Carpentries, 2020 Mapathon, UC GIS Week 2020) and 4 external sessions (69: Portland instructor training, Johannesburg Library Carpentry, an October 2017 instructor training).
- **Missingness/coverage**: institution was not collected before 2020, so affiliation is inferred from venue. A UCLA-held session can include a few outside attendees. 2021 onward not yet classified.
- **Source**: session-by-session review by the DSC director, 2026-09-25, with venues checked against workshop-site repositories (`dsc-stats-integration/proposals/ucla-venue-2017-2020-proposal.md`).
- **Contribution language allowed**: "about," "held at UCLA."
- **Last verified**: 2026-09-25.
- **Registry**: `ucla-held-attendance-2017-2020` (to be added to `dsc-evidence-registry`).

## 12. Registered workshop seats, 2017-2026

- **Approved wording**: "DSC instruction reached 27,986 registered seats from May 2017 through September 2026 (2026 partial)." Short form: "27,986 registered workshop seats since 2017."
- **Not approved**: "27,986 people trained," "27,986 attendees," or "27,986 UCLA participants." A registered seat is one registration for one session, not a person and not an attendance. The total includes the full UC-wide audience of series DSC co-founded and co-delivers; UCLA is a subset.
- **Reporting period**: 2017-05-04 to 2026-09-26. 2026 is partial (Fall 2026 UC Carpentries in progress).
- **Unit of observation**: registered seat, one unit per series: UC Carpentries and Library Carpentry registered seats; Love Data Week registered seats (best effort, Tim's call 2026-09-26); GIS Week registrations; DSC-run workshops the larger of the named rebuild and the published aggregate, per year.
- **By program**: UC Carpentries (joint series) 10,749; Library Carpentry (UC, May 2026) 1,064; Love Data Week 8,708; GIS Week 2,738; DSC workshops 4,727. By year: `data/processed/canonical/instruction_seats_by_program_year.csv`.
- **Attended alongside**: UC Carpentries 524 (2023), 1,036 (2024), 637 (2025); Library Carpentry May 2026 428; Love Data Week 2021 655 (some sessions only). Compare only within the same series and dates; never apply the UC Carpentries ratio (about 1 attended per 3 registered) to other series or the total.
- **Presentation**: not a hero number. Shown as a stacked annual chart by program with the total beside it (seats proposal, "Presentation", adopted 2026-09-26).
- **Love Data Week 2021 correction**: 1,529 registered seats on the same UC-wide basis as 2022-2024, replacing 177 (DSC-hosted sessions only) in the earlier series.
- **Why it differs from #8 (17,466)**: unit (earlier Carpentries figures counted attended seats or people), window (adds 2024-2026), the Love Data Week 2021 correction, and the larger-of rule for DSC workshops 2017-2019.
- **Missingness/coverage**: named sources for general DSC workshops 2017-2019 are incomplete (workbench gaps G11, G12). Library Carpentry May 2026 attended is 428 here against 453 in the earlier series; UC Carpentries Sept 2024 attended is 1,036 Zoom rows against 1,027 after merging rejoins.
- **Source**: `data/processed/canonical/headline_aggregates.csv` (`instruction_registered_seats`) and `instruction_seats_by_program_year.csv`, from `dsc-stats-integration` `proposals/2026-09-26-seats-reconciliation.md` (decided by Tim 2026-09-26). Row-level inputs stay in the workbench.
- **Deduplicated**: DSC workshops deduplicated on person and date in the rebuild; other series use source registration counts.
- **Contribution language allowed**: "registered seats," "registrations," "co-delivered" for the joint series.
- **Registry**: `instruction-registered-seats-2017-2026` and `love-data-week-2021-registered-seats` (both to be added to `dsc-evidence-registry`).
- **Last verified**: 2026-09-26.

## 13. UCLA people reached, 2017-2026

- **Approved wording**: "At least 1,908 confirmed UCLA researchers used DSC instruction or consultation from 2017 to September 2026."
- **Not approved**: presenting 1,908 as a census or as everyone DSC served; "1,908 students"; adding it to seat or consultation counts. It is a floor.
- **Reporting period**: 2017 to 2026-09-08 (date of the person-level run).
- **Unit of observation**: one person, confirmed UCLA.
- **Population/exclusions**: faculty, graduate students, postdocs, and academic staff who attended instruction or had a consultation. DSC staff and non-UCLA excluded. 2,082 counting probable matches; the published figure uses confirmed only.
- **Method**: email match first, then name plus a corroborating field; ambiguous common names left unmerged.
- **Source**: `data/processed/canonical/headline_aggregates.csv` (`people_reached_confirmed_ucla`), from the `dsc-stats-integration` v3h person-level merge (2026-09-08). Row-level data stays in the workbench.
- **Pending**: a broader v4 definition (more service sources) is provisional. It replaces this figure only when Tim lifts the provisional flag; see the `TODO(reach-v4)` note in `index.qmd`.
- **Contribution language allowed**: "at least," "confirmed UCLA researchers," "used."
- **Registry**: `ucla-researchers-served-2017-2026` (exists; its `verification_status` is `unverified`, and its `used_in` needs `dsc-stats-reports index.qmd`).
- **Last verified**: 2026-09-26 (figure unchanged since the 2026-09-08 run).

## 14. Since 1961 (home-page history band)

- **Approved wording**: "UCLA has kept research data for reuse since 1961, when political scientist Dwaine Marvick founded the Political Behavior Archive. The unit's name and institutional home have changed several times since; what persisted is the stewardship of research data and the work of widening access to it."
- **Not approved**: implying that today's DSC portfolio (Dataverse, Redivis, compute, instruction) existed in 1961, or that the unit was one continuous organization. It moved through several institutional homes.
- **Reporting period**: 1961 to 2026.
- **Unit of observation**: historical account.
- **Source**: `ssda-dsc-history` `history.qmd` ("Introduction" and "The history in 30 seconds"), corrected 2026-09-14.
- **Registry**: `ssda-1961-founding` (exists, verified; its `used_in` needs `dsc-stats-reports index.qmd`).
- **Last verified**: 2026-09-26.

## 15. Three instruction eras (capability pathway long-view callout)

- **Approved wording**: "Instruction went through three eras": local, one campus, in person from 2017, with campus-trained volunteers leading workshops by January 2020; the systemwide UC Carpentries network co-founded in 2020 in response to the pandemic, with Berkeley, San Diego, Santa Barbara, Merced, and Riverside as partners; system scale from 2023.
- **Not approved**: describing the 2020 shift as a planned expansion (the source says it was reactive), or crediting the UC-wide series to DSC alone (co-founded, co-delivered).
- **Reporting period**: 2017-2026.
- **Unit of observation**: historical account.
- **Source**: `ssda-dsc-history` `history.qmd`, "Teaching: The Carpentries and an instructor network".
- **Registry**: `instruction-eras-2017-2026` (to be added to `dsc-evidence-registry`).
- **Last verified**: 2026-09-26.

## 16. Released datasets in UCLA Dataverse

- **Approved wording**: "About 1,390 released datasets in UCLA Dataverse (Feb 2026): about 376 deposited directly at UCLA and about 1,014 legacy SSDA datasets that Library staff harvested and curate."
- **Not approved**: "DSC published 1,390 datasets" (most are legacy SSDA holdings harvested in, not new DSC-assisted deposits); presenting 1,390 and the live dashboard's directly-deposited count (395, Sept 2026) as competing figures. They are the same repository at different scopes and dates.
- **Reporting period**: snapshot, Feb 2026. The directly-deposited slice on `infrastructure.qmd` is live and dated at render.
- **Unit of observation**: released dataset (1,603 counting drafts and restricted deposits).
- **Source**: `data/processed/canonical/headline_aggregates.csv` (`dataverse_datasets_released`).
- **Downloads**: the 143,000+ in the retrospective and the live download total on `infrastructure.qmd` are the same measure (file-level download events) at different dates (Feb 2026 and the render date).
- **Registry**: `dataverse-dataset-count` (exists, verified 2026-09-02; its `used_in` needs `dsc-stats-reports index.qmd` and `infrastructure.qmd`).
- **Last verified**: 2026-09-26.
