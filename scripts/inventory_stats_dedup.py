#!/usr/bin/env python3
from __future__ import annotations

import csv
import hashlib
import itertools
import os
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


BASE = Path("/Users/timdennis/projects/dsc-stats")
GDRIVE = Path("/Users/timdennis/Google Drive/Shared drives/data-science-center/stats-reports")
OUTDIR = BASE / "dsc-stats-reports" / "data" / "processed" / "repo_cleanup"

IGNORE_DIRS = {
    ".git",
    ".quarto",
    "__pycache__",
    "node_modules",
    ".Rproj.user",
    ".ipynb_checkpoints",
}

TEXT_EXTS = {
    ".csv", ".tsv", ".txt", ".md", ".qmd", ".rmd", ".r", ".py", ".json", ".yaml", ".yml",
    ".toml", ".sql", ".xml", ".html", ".js", ".css"
}

ANALYSIS_EXTS = TEXT_EXTS | {
    ".rds", ".rda", ".xlsx", ".xls", ".parquet", ".feather", ".ipynb", ".gz", ".zip"
}

# Keep the first pass fast and relevant for cleanup decisions.
MAX_HASH_BYTES = 200 * 1024 * 1024


@dataclass
class FileRec:
    root_name: str
    root_path: str
    path: str
    rel_path: str
    ext: str
    size_bytes: int
    mtime_utc: str
    sha256: str


def sha256_file(path: Path, chunk_size: int = 1024 * 1024) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        while True:
            chunk = f.read(chunk_size)
            if not chunk:
                break
            h.update(chunk)
    return h.hexdigest()


def iter_files(root: Path):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS]
        pdir = Path(dirpath)
        for fn in filenames:
            p = pdir / fn
            if p.is_symlink():
                continue
            yield p


def collect(root_name: str, root: Path) -> list[FileRec]:
    recs: list[FileRec] = []
    for p in iter_files(root):
        try:
            st = p.stat()
            if p.suffix.lower() not in ANALYSIS_EXTS:
                continue
            if st.st_size > MAX_HASH_BYTES:
                continue
            mtime = datetime.fromtimestamp(st.st_mtime, tz=timezone.utc).isoformat()
            rel = str(p.relative_to(root))
            recs.append(
                FileRec(
                    root_name=root_name,
                    root_path=str(root),
                    path=str(p),
                    rel_path=rel,
                    ext=p.suffix.lower(),
                    size_bytes=st.st_size,
                    mtime_utc=mtime,
                    sha256=sha256_file(p),
                )
            )
        except (OSError, PermissionError):
            continue
    return recs


def write_csv(path: Path, rows: list[dict], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        for row in rows:
            w.writerow(row)


def main() -> None:
    roots: list[tuple[str, Path]] = []

    for child in sorted(BASE.iterdir()):
        if child.is_dir() and (child / ".git").exists():
            roots.append((child.name, child))
    roots.append(("gdrive-stats-reports", GDRIVE))

    all_recs: list[FileRec] = []
    for name, root in roots:
        print(f"Scanning {name}: {root}")
        all_recs.extend(collect(name, root))

    manifest_rows = [r.__dict__ for r in all_recs]
    write_csv(
        OUTDIR / "file_manifest.csv",
        manifest_rows,
        ["root_name", "root_path", "path", "rel_path", "ext", "size_bytes", "mtime_utc", "sha256"],
    )

    by_hash: dict[str, list[FileRec]] = defaultdict(list)
    for r in all_recs:
        by_hash[r.sha256].append(r)

    dup_groups = []
    for h, recs in by_hash.items():
        if len(recs) < 2:
            continue
        roots_in = sorted({r.root_name for r in recs})
        dup_groups.append(
            {
                "sha256": h,
                "size_bytes": recs[0].size_bytes,
                "copies": len(recs),
                "root_count": len(roots_in),
                "roots": " | ".join(roots_in),
                "sample_paths": " || ".join(r.path for r in recs[:5]),
            }
        )
    dup_groups.sort(key=lambda x: (int(x["root_count"]), int(x["copies"]), int(x["size_bytes"])), reverse=True)
    write_csv(
        OUTDIR / "duplicate_groups.csv",
        dup_groups,
        ["sha256", "size_bytes", "copies", "root_count", "roots", "sample_paths"],
    )

    root_summary = []
    root_to_recs: dict[str, list[FileRec]] = defaultdict(list)
    for r in all_recs:
        root_to_recs[r.root_name].append(r)

    for root_name, recs in sorted(root_to_recs.items()):
        hashes = {r.sha256 for r in recs}
        dup_file_count = sum(1 for r in recs if len(by_hash[r.sha256]) > 1)
        cross_root_dup_file_count = sum(
            1 for r in recs if len({x.root_name for x in by_hash[r.sha256]}) > 1
        )
        root_summary.append(
            {
                "root_name": root_name,
                "files": len(recs),
                "total_size_bytes": sum(r.size_bytes for r in recs),
                "unique_hashes_in_root": len(hashes),
                "files_with_duplicate_content": dup_file_count,
                "files_duplicated_across_roots": cross_root_dup_file_count,
                "latest_mtime_utc": max((r.mtime_utc for r in recs), default=""),
            }
        )

    write_csv(
        OUTDIR / "root_summary.csv",
        root_summary,
        [
            "root_name",
            "files",
            "total_size_bytes",
            "unique_hashes_in_root",
            "files_with_duplicate_content",
            "files_duplicated_across_roots",
            "latest_mtime_utc",
        ],
    )

    overlap_counts: dict[tuple[str, str], dict[str, int]] = defaultdict(lambda: {"shared_hashes": 0, "shared_bytes": 0})
    for h, recs in by_hash.items():
        roots_here = sorted({r.root_name for r in recs})
        if len(roots_here) < 2:
            continue
        size_bytes = recs[0].size_bytes
        for a, b in itertools.combinations(roots_here, 2):
            overlap_counts[(a, b)]["shared_hashes"] += 1
            overlap_counts[(a, b)]["shared_bytes"] += size_bytes

    overlap_rows = []
    for (a, b), vals in sorted(overlap_counts.items()):
        overlap_rows.append(
            {
                "root_a": a,
                "root_b": b,
                "shared_hashes": vals["shared_hashes"],
                "shared_bytes": vals["shared_bytes"],
            }
        )

    write_csv(
        OUTDIR / "root_overlap.csv",
        overlap_rows,
        ["root_a", "root_b", "shared_hashes", "shared_bytes"],
    )

    # Duplicate of manifest for downstream analysis naming compatibility.
    data_like_rows = [r.__dict__ for r in all_recs]
    write_csv(
        OUTDIR / "file_manifest_data_like.csv",
        data_like_rows,
        ["root_name", "root_path", "path", "rel_path", "ext", "size_bytes", "mtime_utc", "sha256"],
    )

    print(f"Wrote outputs to {OUTDIR}")
    print(f"Files inventoried (analysis-focused): {len(all_recs)}")
    print(f"Duplicate groups: {len(dup_groups)}")
    print(f"Filters: extensions={len(ANALYSIS_EXTS)} max_hash_bytes={MAX_HASH_BYTES}")


if __name__ == "__main__":
    main()
