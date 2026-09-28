# Validation capture: dean briefs vs. a division selector (2026-09-28)

ChatGPT was asked whether to build a one-page dean brief or a view parameterized by department or division. Adjudicated by Claude against the repo; Tim adopted every ADOPT row on 2026-09-28.

| ChatGPT claim | Verdict | Check / where it landed |
|---|---|---|
| Generate dean briefs from one Quarto template, rendered per division | ADOPT | `briefs/dean-brief.qmd` + `briefs/divisions.yml`; `pixi run render-briefs` writes Humanities and Social Sciences to `briefs/out/` (gitignored, not on the public site). Supersedes the hand-built `dean-update-social-sciences-2026.qmd`. |
| Division coverage is thin; say "at least X records with known affiliation" | ADOPT | Only 838 of 1,575 UCLA attendance records map to a school or division (claim #6). Brief says counts are floors and unmapped records are not counted anywhere. |
| Keep 1,908 campus-wide only | ADOPT | Claim #13 is person-level and provisional, with no validated division assignment. Brief states it as campus-wide. |
| Separate verified local use from services available to the division | ADOPT | Two sections: "Research DSC has supported" (claim-register examples only) and "What the division relies on that DSC runs for all of UCLA". |
| Public division selector later, from precomputed, suppressed summaries only | DEFER | Revisit after two briefs are tested with readers who know each division. Interactive widgets embed their data, so no row-level data in the page. |
| No department or chair dropdown | ADOPT | Cells too small; identification risk. Department rows in briefs use `suppress_small_cells()` (under 5 folded). |

Counts at first render (2026-09-28): Humanities 49 workshop attendance records (Nov 2020 to Apr 2024, 14 departments) and 28 consultation records (Jan 2021 to Jun 2024; 22 Digital Humanities). Social Sciences 177 and 82.

Before sharing any brief: have someone who knows the division check it. Does it name research they recognize? What dependency is missing? Does any count imply fuller coverage than we have?
