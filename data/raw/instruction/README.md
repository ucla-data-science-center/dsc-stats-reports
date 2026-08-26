# Instruction source data

`dsc_workshops.csv` contains consolidated attendee-level instruction records from multiple workshop sources. Its counting unit is one attendee-event row.

This consolidated file is the full instruction source, not a UCLA-only subset. The previously published `data/processed/instruction/ucla_workshops.rda` contains 1,676 UCLA and UCLA-like rows and must not be used for overall UC-wide attendance totals. UCLA, department, and future school/division metrics still apply their validated dimension filters to the full source.

The consolidated file already represents cleaned GIS Week and Love Data Week inputs. Upstream registration workbooks and ZIP copies are provenance sources, not additive datasets. Title-based validation currently finds:

- GIS Week: 883 (2020), 892 (2021), 596 (2022), and 370 (2023) attendance records.
- Love Data Week: 5 (2019), 2,585 (2022), 2,182 (2023), and 2,413 (2024) attendance records.

These counts must not be added again from the restricted workbooks.

`workshop_attendance_aggregate.csv` contains privacy-safe event summaries for sources where validated attendance counts exist but publishable participant dimensions do not. Its counting unit and source-specific attendance rule are explicit in every row.

Aggregate records may contribute to compatible overall, year, event, and topic attendance totals. They must not be assigned to UCLA affiliation, department, school, participant affiliation, or unique-person metrics when those dimensions are blank. Blank means unknown, not non-UCLA.

Row-level Zoom exports, participant names, email addresses, meeting identifiers, and row fingerprints remain in restricted provenance storage outside this repository.
