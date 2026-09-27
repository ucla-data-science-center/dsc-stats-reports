#!/usr/bin/env python3
"""Build the DSC service-evidence package for deposit in UCLA Dataverse.

Copies the public, aggregate-only files that the site is built from into
release/dsc-evidence-v<VERSION>/, writes a README and a codebook generated from
the files' own columns, records a SHA-256 manifest, and refuses to build if any
file contains an email- or phone-like string.

    python scripts/dataverse/build_package.py --version 1
    python scripts/dataverse/build_package.py --version 1 --exclude-staffing
"""
import argparse, csv, hashlib, re, shutil, sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

# (source path, description). Aggregates only; every file is already public on the site.
FILES = [
    ("data/processed/canonical/headline_aggregates.csv",
     "Reconciled headline figures with window, unit, basis, caveat, and source for each (claim register #8-#10, #12, #13, #16)."),
    ("data/processed/canonical/consultations_by_year.csv",
     "Recorded research consultations by calendar year, 2017-2026; years from 2024 are floors (claim #10)."),
    ("data/processed/canonical/instruction_seats_by_program_year.csv",
     "Registered workshop seats by program and year, with attended seats where recorded (claim #12)."),
    ("data/processed/canonical/service_capacity_by_year.csv",
     "Service capacity by year: staff full-time equivalents (DSC and other Library units) and average student employees per month (claim #17)."),
    ("data/processed/canonical/research_outputs_public.csv",
     "Documented research projects and outputs connected to DSC investments; verified and permitted rows only (claim #19)."),
    ("data/processed/consultations/public/consult_records_by_year.csv",
     "Consultation records file, rows by year (Jan 2021 to Jun 2024)."),
    ("data/processed/consultations/public/consult_records_by_year_team.csv",
     "Consultation records file by year and record type (scheduled appointments, DataSquad walk-in sign-ins, other)."),
    ("data/processed/consultations/public/consult_records_by_department.csv",
     "Consultation records file by department; units under 5 combined."),
    ("data/processed/consultations/public/consult_records_by_affiliation.csv",
     "Consultation records file by affiliation; units under 5 combined."),
    ("data/processed/consultations/public/consult_records_by_team.csv",
     "Consultation records file by team."),
    ("data/processed/consultations/public/consult_records_window.csv",
     "Date window of the consultation records file and the number of suppressed units."),
    ("claim-register.md",
     "Claim register: approved wording, reporting period, unit, exclusions, and source for every headline figure."),
]
STAFFING = "data/processed/canonical/service_capacity_by_year.csv"

EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.(edu|com|org|net|gov|io)\b")
PHONE = re.compile(r"\(?\b[0-9]{3}\)?[-. ][0-9]{3}[-. ][0-9]{4}\b")
ALLOWED_EMAILS = {"datascience@g.ucla.edu"}


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--version", required=True, help="package version, e.g. 1 or 1.1")
    ap.add_argument("--exclude-staffing", action="store_true", help="leave out the service-capacity file")
    args = ap.parse_args()

    files = [(p, d) for p, d in FILES if not (args.exclude_staffing and p == STAFFING)]
    out = ROOT / "release" / f"dsc-evidence-v{args.version}"
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)

    problems = []
    for src, _ in files:
        text = (ROOT / src).read_text(encoding="utf-8")
        emails = {m.group(0) for m in EMAIL.finditer(text)} - ALLOWED_EMAILS
        if emails or PHONE.search(text):
            problems.append(src)
    if problems:
        sys.exit("Refusing to build: email- or phone-like strings in " + ", ".join(problems))

    codebook = [f"# Codebook, DSC service evidence v{args.version}\n"]
    manifest = []
    for src, desc in files:
        p = ROOT / src
        shutil.copy2(p, out / p.name)
        manifest.append((p.name, desc, sha256(out / p.name)))
        codebook.append(f"\n## {p.name}\n\n{desc}\n")
        if p.suffix == ".csv":
            with open(p, newline="", encoding="utf-8") as f:
                rows = list(csv.reader(f))
            codebook.append(f"\nRows: {len(rows) - 1}. Columns:\n")
            codebook += [f"- `{c}`\n" for c in rows[0]]

    (out / "CODEBOOK.md").write_text("".join(codebook), encoding="utf-8")
    with open(out / "MANIFEST.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["file", "description", "sha256"])
        w.writerows(manifest)

    readme = f"""# UCLA Library Data Science Center Service Evidence, 2017-2026 (v{args.version})

Built {date.today().isoformat()} from the source repository
https://github.com/ucla-data-science-center/dsc-stats-reports

Aggregate evidence behind the DSC statistics site,
https://ucla-data-science-center.github.io/dsc-stats-reports/ . Each figure's
approved wording, reporting period, unit, exclusions, and source are in
claim-register.md; column lists are in CODEBOOK.md; file checksums in MANIFEST.csv.

What is not here, by design: row-level consultation, registration, sign-in, ticket,
or timesheet records, and anything that identifies a person other than researchers
who agreed to be named for their published work. Department and affiliation
breakdowns fold any unit under 5 into a combined row.

Units matter: a registered seat is one registration for one session, not a person;
a consultation is an interaction, not a person; people-reached figures count people
only where identity could be confirmed and are floors. Recorded consultations are
incomplete from mid-2024.

Files:
""" + "".join(f"- {n}: {d}\n" for n, d, _ in manifest)
    (out / "README.md").write_text(readme, encoding="utf-8")
    print(f"Built {out.relative_to(ROOT)} with {len(manifest)} data files plus README, CODEBOOK, MANIFEST.")


if __name__ == "__main__":
    main()
