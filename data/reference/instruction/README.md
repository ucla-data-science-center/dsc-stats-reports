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
