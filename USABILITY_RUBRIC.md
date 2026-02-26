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

### Scoring notes

**A — Orientation**
- All pages: -1 on A2 because date range appears in KPI sub-notes (small text) not a visible banner; -1 or -2 on A4 because audience framing is implicit at best
- about.qmd scores well because it was written explicitly for this rubric

**B — KPI quality**
- All pages score 1/2 on B1 (units present, denominators partial)
- All pages score 0/2 on B2 — no comparisons exist yet (YoY or T12M). This is the single highest-ROI gap.
- infrastructure.qmd gets +1 on B2 because the Dataverse charts show trend implicitly

**C — Visual clarity**
- Consulting/instruction: -1 on C1 (bar labels can be small on mobile)
- Infrastructure: -2 on C2 (dual-axis matplotlib charts are hard to read; left/right Y-axes use different colors with no legend on one of them)

**D — Navigability**
- All pages: -1 on D1 (tabsets help but there's no "see also" or cross-page link from charts)
- Consulting/instruction: -2 on D2 (all tables are kable; no sort/filter on the coverage table which has 10+ rows)

**E — Trust and governance**
- All pages: 0/2 on E4 (no citation block on individual pages, only in about.qmd)
- instruction.qmd: -2 on E3 (no coverage table at all; only consulting.qmd has one)

---

## Recommended Next Actions (by ROI)

### High impact, low effort

1. **Add YoY comparison to all KPI cards** (B2 +2 across all pages)
   - Requires by-year data to already exist (it does in `audit_summary` and `audit_task_mode`)
   - Pattern: show current period value + `↑ +12% vs prior year` in `.kpi-note`

2. **Add date-range badge near KPIs** (A2 +1 across all pages)
   - A single line like `Data: Jan 2021 – Feb 2026` directly below the KPI row
   - Already computed in audit_coverage; just needs surfacing higher on the page

3. **Add coverage table to instruction.qmd** (E3 +2)
   - Straightforward: same pattern as consulting.qmd coverage chunk

4. **Add citation block to each page footer** (E4 +1–2 across all pages)
   - One-liner callout: "To cite: UCLA Library DSC. (Year). *Page title*. Retrieved from [URL]."

### Medium impact, medium effort

5. **Replace kable coverage table with DT** (D2 +1–2 on consulting/instruction)
   - `DT::datatable()` — already in pixi dependencies (`r-dt >= 0.30`)
   - Sortable, searchable, no extra dependency to add

6. **Fix infrastructure dual-axis charts** (C2 +1–2 on infrastructure)
   - Separate into two stacked panels instead of dual Y-axes
   - Easier to read, especially on mobile

7. **Audience framing on each page** (A4 +1–2 across all pages)
   - One sentence at top: "This page is for library administration and DSC staff."

### Requires new data or significant work

8. **YoY KPI comparisons for instruction** — needs prior-year workshop data structured the same way
9. **DT tables for department/affiliation breakdowns** — large enough to benefit from search
10. **Alt text for all ggplot/matplotlib charts** — requires `fig.alt=` chunk option or post-render injection

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
