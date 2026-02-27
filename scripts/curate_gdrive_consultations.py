#!/usr/bin/env python3
from __future__ import annotations

import csv
import os
from pathlib import Path


GDRIVE = Path("/Users/timdennis/Google Drive/Shared drives/data-science-center/stats-reports")
REPO = Path("/Users/timdennis/projects/dsc-stats/dsc-stats-reports")
OUTDIR = REPO / "data" / "processed" / "repo_cleanup"


def ensure_link(src: Path, dst: Path) -> str:
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists() or dst.is_symlink():
        if dst.is_symlink() and os.readlink(dst) == str(src):
            return "exists"
        dst.unlink()
    os.symlink(src, dst)
    return "linked"


def main() -> None:
    # Curated consultation files to integrate or retain as reference.
    mappings = [
        {
            "source_rel": "01_Consultations/Data/dsc_cosults/tim/filtered-event-data-from-20240222-to-20250220.csv",
            "purpose": "libinsights_backfill",
            "action": "symlink",
            "dest_rel": "data/raw/consultations/imported_gdrive/libinsights/2025/filtered-event-data-from-20240222-to-20250220.csv",
            "notes": "Calendly/LibInsights-style export; extends coverage into 2025. Dedup by Event UUID.",
        },
        {
            "source_rel": "01_Consultations/Data/dsc_cosults/2024-clean-dsc.csv",
            "purpose": "manual_consult_log_reference",
            "action": "symlink",
            "dest_rel": "data/raw/consultations/imported_gdrive/manual_logs/2024/2024-clean-dsc.csv",
            "notes": "Reference export for 2024 DSC consult logging; likely overlaps existing totals and useful for validation.",
        },
        {
            "source_rel": "01_Consultations/Data/dsc_cosults/data-raw-archive/dsc_2024_consults.csv",
            "purpose": "manual_consult_log_reference",
            "action": "symlink",
            "dest_rel": "data/raw/consultations/imported_gdrive/manual_logs/2024/dsc_2024_consults.csv",
            "notes": "Alternate 2024 export variant; use for reconciliation and field comparison.",
        },
        {
            "source_rel": "01_Consultations/Data/dsc_cosults/clean_dsc_2021-consults.csv",
            "purpose": "manual_consult_log_reference",
            "action": "symlink",
            "dest_rel": "data/raw/consultations/imported_gdrive/manual_logs/2021/clean_dsc_2021-consults.csv",
            "notes": "Historical cleaned DSC consult log export.",
        },
        {
            "source_rel": "01_Consultations/Data/dsc_cosults/clean_dsc_2022_consults.csv",
            "purpose": "manual_consult_log_reference",
            "action": "symlink",
            "dest_rel": "data/raw/consultations/imported_gdrive/manual_logs/2022/clean_dsc_2022_consults.csv",
            "notes": "Historical cleaned DSC consult log export.",
        },
        {
            "source_rel": "01_Consultations/Data/dsc_cosults/clean_dsc_2023-consults.csv",
            "purpose": "manual_consult_log_reference",
            "action": "symlink",
            "dest_rel": "data/raw/consultations/imported_gdrive/manual_logs/2023/clean_dsc_2023-consults.csv",
            "notes": "Historical cleaned DSC consult log export.",
        },
        {
            "source_rel": "01_Consultations/Data/dsc_cosults/data-raw-archive/dsc_2023_calendly_to_libinsight.csv",
            "purpose": "legacy_transform_reference",
            "action": "symlink",
            "dest_rel": "data/raw/consultations/imported_gdrive/legacy_transforms/2023/dsc_2023_calendly_to_libinsight.csv",
            "notes": "Legacy transform output; reference only unless schema mapping is needed.",
        },
        {
            "source_rel": "01_Consultations/Data/Lux Lab Stats.csv",
            "purpose": "related_service_stats",
            "action": "symlink",
            "dest_rel": "data/raw/consultations/imported_gdrive/related_services/Lux_Lab_Stats.csv",
            "notes": "Separate service area stats; keep outside main DSC consultation tally.",
        },
    ]

    rows = []
    for m in mappings:
        src = GDRIVE / m["source_rel"]
        dst = REPO / m["dest_rel"]
        exists = src.exists()
        status = "missing_source"
        if exists and m["action"] == "symlink":
            status = ensure_link(src, dst)
        rows.append(
            {
                **m,
                "source_abs": str(src),
                "dest_abs": str(dst),
                "source_exists": "yes" if exists else "no",
                "status": status,
            }
        )

    out_csv = OUTDIR / "gdrive_consultation_curation_plan.csv"
    out_csv.parent.mkdir(parents=True, exist_ok=True)
    with out_csv.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "purpose",
                "action",
                "source_rel",
                "source_abs",
                "dest_rel",
                "dest_abs",
                "source_exists",
                "status",
                "notes",
            ],
        )
        w.writeheader()
        w.writerows(rows)

    print(f"Wrote {out_csv}")
    for r in rows:
        print(f"{r['status']:>12}  {r['source_rel']} -> {r['dest_rel']}")


if __name__ == "__main__":
    main()
