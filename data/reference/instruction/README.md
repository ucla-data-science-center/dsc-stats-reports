# Instruction reference mappings

`department_to_organizational_parent_v2.tsv` maps standardized UCLA department/unit labels to a broader analytical parent. The field is named `organizational_parent` because values include UCLA College divisions, professional schools, the Library, UCLA Health, academic institutes, extension, campus organizations, external organizations, and administrative reporting groups.

Version 2.0.0 was seeded from a legacy 76-row department-to-division file, updated against currently observed instruction departments, and reviewed against official UCLA organizational sources recorded in each active row.

Rules:

- Apply mappings only to records whose validated institution is exactly `UCLA`.
- Do not infer a parent for records with missing departments.
- Rows with `mapping_status = unresolved` retain a blank parent.
- Do not treat `administrative_group`, `academic_institute`, `library`, `health_system`, or `external` as professional schools.
- Preserve the distinction between overall UCLA attendance and attendance with a known organizational parent.

Version 2.0.0 leaves `Multiple Departments`, `Forestry`, and `Institute of American Cultures` unresolved. Future changes require a new version plus coverage regression tests.

## Session venue, 2017-2020

`session_venue_2017_2020.tsv` classifies each 2017-2020 session (one row per `date`, `event` pair in `data/raw/instruction/dsc_workshops.csv`) by where it was held: `ucla`, `mixed` (co-hosted or UC-wide, e.g. USC and CSU Long Beach Library Carpentry, fall 2020 Carpentries, UC GIS Week 2020), or `non_ucla` (external workshops DSC staff taught, e.g. Portland and Johannesburg). Classifications were reviewed session by session by the DSC director (2026-09-25), with venues checked against the workshop-site repositories where they exist. Provenance: `dsc-stats-integration/proposals/ucla-venue-2017-2020-proposal.md`.

Rules:

- Used only for the `ucla_held` metric. It never sets `institution`, department, or organizational parent.
- A blank-institution record counts as UCLA-held only when its session is `ucla`. `mixed` and `non_ucla` sessions add nothing to it.
- Every row must match a session in the attendee file (enforced in `tests/test_instruction_aggregate.R`).
