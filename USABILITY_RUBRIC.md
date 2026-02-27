# Dashboard Usability Rubric

Score each page 0–2 per item. Maximum per page: **40 points**.

Scoring key:
- **0** — Not present or clearly fails
- **1** — Partially present or inconsistent
- **2** — Fully present and works well

Target: no page below 28/40 in a release. No individual section below 4/8.

---

## Rubric

### A. Orientation (0–8)
| # | Item | Guidance |
|---|---|---|
| A1 | Page purpose is explicit | Can a new reader state in one sentence what decision this page supports? |
| A2 | Date range + "last updated" visible without scrolling | Both the data coverage window AND render date should be at or near the top |
| A3 | Definitions/data notes accessible in ≤1 click | Collapsible callout, tooltip, or prominent link — not buried at the bottom |
| A4 | Intended audience is clear | Admin vs staff vs external — at least implicit from framing |

### B. KPI Quality (0–8)
| # | Item | Guidance |
|---|---|---|
| B1 | KPIs have units and denominators | "741 consultations" not just "741"; note what's excluded |
| B2 | KPIs have comparisons (YoY, T12M, or target) | A number without context is trivia, not a metric |
| B3 | KPI titles are plain language | No jargon, no metric IDs, no system names |
| B4 | KPI values reconcile with underlying tables | Spot-check: does the KPI match what the data table shows? |

### C. Visual Clarity (0–8)
| # | Item | Guidance |
|---|---|---|
| C1 | Labels readable on laptop + mobile | Min ~11px effective; bar labels, axis tick marks, legends |
| C2 | Axes/titles are consistent and unambiguous | Same time windows, same units across related charts |
| C3 | Color used sparingly and consistently | UCLA blue = primary metric; gold = secondary; not both for same series |
| C4 | No chartjunk, no redundant charts | Every chart earns its space; no decorative data |

### D. Navigability and Drill-down (0–8)
| # | Item | Guidance |
|---|---|---|
| D1 | Obvious next step from each chart | "So what?" is answerable — link to tab, table, or detail page |
| D2 | Tables allow lookup (search/sort/filter) where needed | kable is fine for small static tables; DT needed for >20 rows |
| D3 | Cross-page navigation is consistent | Navbar, footer, and internal links work and agree |
| D4 | Users can get back without losing context | Browser back works; tabset state is predictable |

### E. Trust and Governance (0–8)
| # | Item | Guidance |
|---|---|---|
| E1 | Sources listed | Which system(s) and export/API each metric comes from |
| E2 | Known limitations stated | At minimum: undercounting risks, dedup caveats, bot traffic |
| E3 | Coverage/missingness shown where relevant | Date range per source; rows available vs expected |
| E4 | Versioning/citation guidance provided | How to cite; where to find historical versions |

---

## Baseline Scores (post Phase 1 PR1–PR5)

*Scored: 2026-02-26*

| Page | A | B | C | D | E | **Total** | Top gaps |
|---|---|---|---|---|---|---|---|
| index.qmd | 5 | 3 | 8 | 6 | 5 | **27** | B2 (no YoY), A2 (date range not at top), E4 (no citation) |
| consulting.qmd | 5 | 3 | 7 | 5 | 7 | **27** | B2 (no YoY), D2 (kable tables), A4 (audience not stated) |
| instruction.qmd | 5 | 3 | 7 | 5 | 5 | **25** | B2 (no YoY), D2 (kable absent, no detail table), E3 (no coverage table) |
| infrastructure.qmd | 5 | 4 | 6 | 6 | 6 | **27** | B2 (no YoY on KPIs), C2 (dual-axis charts ambiguous), E2 (bot download caveat buried) |
| about.qmd | 7 | n/a | n/a | 6 | 8 | **—** | A4 (audience described but not framed per section) |

## Updated Scores (post Phase 2 accessibility + rubric improvements)

*Scored: 2026-02-26*

| Page | A | B | C | D | E | **Total** | Changes |
|---|---|---|---|---|---|---|---|
| index.qmd | 7 | 5 | 8 | 6 | 7 | **33** | A2+1 (date badge), A4+2 (audience framing), B2+2 (YoY on 2 KPIs), E4+2 (citation) |
| consulting.qmd | 7 | 5 | 7 | 7 | 8 | **34** | A2+1, A4+2, B2+2, D2+2 (DT table), E4+2 (citation) |
| instruction.qmd | 7 | 3 | 7 | 5 | 8 | **30** | A2+2 (date badge added), A4+2, E3+2 (coverage table), E4+2 (citation) |
| infrastructure.qmd | 7 | 4 | 6 | 6 | 8 | **31** | A2+1 (date badge), A4+2, E4+2 (citation) |
| about.qmd | 7 | n/a | n/a | 6 | 8 | **—** | unchanged |

### Scoring notes (updated)

**A — Orientation**
- All pages now have audience framing (+2 on A4) and visible date badge (+1 A2)
- A1 still -1 on some pages (purpose statement exists but not framed as decision-support)

**B — KPI quality**
- index.qmd + consulting.qmd: B2 now +2 (YoY on direct consultations + task cards)
- instruction.qmd: still 0/2 on B2 — no prior-year workshop data available for comparison
- infrastructure.qmd: still +1 on B2 (trend charts exist; no explicit KPI comparison)

**C — Visual clarity**
- Unchanged; dual-axis infrastructure charts still ambiguous (C2 gap remains)

**D — Navigability**
- consulting.qmd: D2 +2 (DT::datatable() on coverage table — sortable/searchable)
- instruction.qmd: D2 still -2 (coverage table uses kable; DT upgrade would help but workshop data is small)

**E — Trust and governance**
- All pages: E4 +2 (citation callout added to every page)
- instruction.qmd: E3 +2 (coverage table computed from loaded data)
- Remaining E4 gap closed; E3 gap closed on all pages with data

---

## Recommended Next Actions (by ROI)

### High impact, low effort — COMPLETED

1. ~~**Add YoY comparison to all KPI cards**~~ ✓ Done (index + consulting; instruction needs data)
2. ~~**Add date-range badge near KPIs**~~ ✓ Done (all pages)
3. ~~**Add coverage table to instruction.qmd**~~ ✓ Done
4. ~~**Add citation block to each page footer**~~ ✓ Done (all pages)
5. ~~**Audience framing on each page**~~ ✓ Done
6. ~~**Replace kable coverage table with DT**~~ ✓ Done (consulting.qmd)
7. ~~**Alt text for all chart images**~~ ✓ Done (WCAG 2.1 AA, all pages)

### Remaining gaps

- **Fix infrastructure dual-axis charts** (C2 +1–2 on infrastructure)
  - Separate into two stacked panels instead of dual Y-axes; easier to read on mobile

- **YoY KPI comparisons for instruction** — needs prior-year workshop data structured by year

- **DT tables for department/affiliation breakdowns** — large enough to benefit from search (consulting, instruction)

- **D1: "See also" cross-page links** — no "next step" link from charts on any page

- **Quarto framework accessibility bugs** (unfixable without upstream fix):
  - WCAG 4.1.1: Duplicate IDs (`quarto-text-highlighting-styles`, `quarto-bootstrap`)
  - WCAG 4.1.2: GitHub nav icon anchor has no accessible name on `<a>`

---

## Usage in PRs

Add this to PR descriptions when layout/data changes are involved:

```
## Usability rubric delta
| Page | Before | After | Items changed |
|---|---|---|---|
| consulting.qmd | 27 | 30 | B2 (+2 YoY KPIs), E4 (+1 citation) |
```

Require total ≥ 28/40 for merge on any page touched by the PR.
