# Instruction source data

`dsc_workshops.csv` contains attendee-level LibInsight records. Its counting unit is one attendee-event row.

`workshop_attendance_aggregate.csv` contains privacy-safe event summaries for sources where validated attendance counts exist but publishable participant dimensions do not. Its counting unit and source-specific attendance rule are explicit in every row.

Aggregate records may contribute to compatible overall, year, event, and topic attendance totals. They must not be assigned to UCLA affiliation, department, school, participant affiliation, or unique-person metrics when those dimensions are blank. Blank means unknown, not non-UCLA.

Row-level Zoom exports, participant names, email addresses, meeting identifiers, and row fingerprints remain in restricted provenance storage outside this repository.
