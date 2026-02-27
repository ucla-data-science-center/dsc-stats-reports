#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
import shutil
from datetime import datetime
from pathlib import Path


JSON_PATH = Path("/Users/timdennis/Downloads/Administrative/0wp3d1Xr - ucla-datasquad-projects.json")
CSV_PATH = Path("/Users/timdennis/projects/dsc-stats/dsc-stats-reports/data/raw/consultations/ucla-datasquad-projects-trello.csv")


OUTPUT_COLUMNS = [
    "Card ID",
    "Card Name",
    "department",
    "ucla_affiliation",
    "Card URL",
    "Card Description",
    "Labels",
    "Members",
    "Due Date",
    "Attachment Count",
    "Attachment Links",
    "Checklist Item Total Count",
    "Checklist Item Completed Count",
    "Vote Count",
    "Comment Count",
    "Last Activity Date",
    "List ID",
    "List Name",
    "Board ID",
    "Board Name",
    "Archived",
    "Start Date",
    "Due Complete",
    "DSC Contact",
]


def join_nonempty(values):
    vals = [str(v) for v in values if v not in (None, "")]
    return ", ".join(vals) if vals else ""


def main() -> None:
    board = json.loads(JSON_PATH.read_text())

    members_by_id = {m["id"]: m.get("fullName") or m.get("username") for m in board.get("members", [])}
    lists_by_id = {lst["id"]: lst.get("name", "") for lst in board.get("lists", [])}

    rows = []
    for card in board.get("cards", []):
        badges = card.get("badges", {}) or {}
        attachments = card.get("attachments", []) or []
        labels = card.get("labels", []) or []

        member_names = [members_by_id.get(mid, mid) for mid in (card.get("idMembers") or [])]
        label_names = []
        for lbl in labels:
            name = (lbl or {}).get("name")
            color = (lbl or {}).get("color")
            if name and color:
                label_names.append(f"{name} ({color})")
            elif name:
                label_names.append(name)
            elif color:
                label_names.append(color)

        attachment_links = [a.get("url") for a in attachments if a.get("url")]

        rows.append(
            {
                "Card ID": card.get("id", ""),
                "Card Name": card.get("name", ""),
                "department": "",
                "ucla_affiliation": "",
                "Card URL": card.get("url", ""),
                "Card Description": card.get("desc", ""),
                "Labels": join_nonempty(label_names),
                "Members": join_nonempty(member_names),
                "Due Date": card.get("due", ""),
                "Attachment Count": badges.get("attachments", 0),
                "Attachment Links": join_nonempty(attachment_links),
                "Checklist Item Total Count": badges.get("checkItems", 0),
                "Checklist Item Completed Count": badges.get("checkItemsChecked", 0),
                "Vote Count": badges.get("votes", 0),
                "Comment Count": badges.get("comments", 0),
                "Last Activity Date": card.get("dateLastActivity", ""),
                "List ID": card.get("idList", ""),
                "List Name": lists_by_id.get(card.get("idList", ""), ""),
                "Board ID": board.get("id", ""),
                "Board Name": board.get("name", ""),
                "Archived": bool(card.get("closed", False)),
                "Start Date": card.get("start", ""),
                "Due Complete": bool(card.get("dueComplete", False)),
                "DSC Contact": "",
            }
        )

    rows.sort(key=lambda r: r.get("Last Activity Date", ""))

    if CSV_PATH.exists():
        stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        backup = CSV_PATH.with_name(f"{CSV_PATH.stem}.backup-{stamp}{CSV_PATH.suffix}")
        shutil.copy2(CSV_PATH, backup)
        print(f"Backed up existing CSV to {backup}")

    CSV_PATH.parent.mkdir(parents=True, exist_ok=True)
    with CSV_PATH.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=OUTPUT_COLUMNS)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Wrote {len(rows)} rows to {CSV_PATH}")
    if rows:
        print(f"Date range: {rows[0]['Last Activity Date']} .. {rows[-1]['Last Activity Date']}")


if __name__ == "__main__":
    main()
