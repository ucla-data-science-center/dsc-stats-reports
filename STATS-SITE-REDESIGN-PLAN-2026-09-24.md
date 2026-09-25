# Stats-site redesign plan (`dsc_stats_reporting:30`)

Drafted 2026-09-24. Status: plan only, nothing built. Needs Tim's calls on
the decisions in section 2 before phase 1 starts.

## 1. What's already settled

From the 2026-09-12 external validation
(`validation-capture-stats-site-storytelling-redesign-2026-09-12.md`), adopted:

* Three products: a faculty-facing page, a 2-page campus-leadership brief,
  and this Quarto site demoted to the evidence/methods layer.
* Genre: research-support impact report (contribution-focused program
  evaluation), not a narrative-dashboard blend.
* Spine: three impact pathways. **Research enabled**, **Research capability
  built**, **Shared infrastructure sustained**. The current By Year / By
  Department / By Affiliation tables move under each pathway as supporting
  evidence.
* Homepage has two entry points: "Get research support" and "See DSC's
  campus contribution."
* About six case studies across the pathways before cases carry the
  structure. We have 2, both consulting. Infrastructure has none.
* Every headline claim gets a `claim-register.md` entry before it ships.

What this plan adds: the history integration (the original ask in
`:30`), sequencing, and the number-sync problem below.

## 2. Decisions for Tim (blocking)

**Decided 2026-09-24:** (1) reconciled figures ship, sync first; (2) option (b), continuity band + one long-view callout per pathway; (3) faculty page lives in this Quarto site; (5) the brief's ask is a continuity commitment. Item 4 (case studies) still open.

1. **Which numbers ship.** The site and the draft brief still carry the old
   canonical figures: 15,765 attendee-events (2017 to Apr 2024), 741
   consultations (2023-2025 only). `dsc-stats-integration` has since
   reconciled 17,466 (2017 to Apr 2024), about 18,712 lifetime through May
   2026, and an unbroken consultation series of 1,859 (2017-2026). Recommend:
   sync first (phase 1), because a redesign built on superseded numbers
   gets rebuilt twice.
2. **How deep the history goes into the stats site.** Options:
   * (a) Link only. This is what we have now.
   * (b) **Recommended.** A short "since 1961" continuity band on the home
     page, plus one "long view" callout per pathway drawn from
     `history.qmd`. The full history stays its own document.
     * Infrastructure sustained: SSDA archive (1961) through Dataverse,
       Redivis, compute.
     * Capability built: the three instruction eras (local 2017-2019,
       pandemic UC-wide pivot 2020, system-scale 2023-2026).
     * Research enabled: the "Historical traces of reuse" section.
   * (c) Merge into a single site. Considered on 2026-09-12 and deferred.
     Still not worth it.
3. **Where the faculty page lives.** In this Quarto site (fast, we control
   it) or on the Library website (right audience, slower, not ours).
   Recommend here for now, as the "Get research support" landing page, and
   hand the Library a link.
4. **Case study picks and permission.** Candidates from existing evidence,
   to fill the four missing slots:
   * Capability built:
     * UC Carpentries system-wide series. A program case, no individual
       named.
     * One trajectory exemplar (Seul Lee or Qiao Yu). Both are already
       ADOPT-exemplar and publicly findable. Still needs credit or consent.
   * Infrastructure sustained:
     * The deep learning machine. It ran Amanda Robin's SquirrelGazer work
       and the Shapiro helicopter analysis. Note: it overlaps case 1.
     * Or Redivis / the L2 voter file.
   * Research enabled: Digital Turf Project (Casteel), or an aggregate
     Communication honors-thesis pipeline (a dozen or so undergrad
     engagements 2021-2024, social-media data collection and network
     analysis, no students named).
5. **Leadership brief's ask.** Page 1 still has the blank Tim left on
   purpose. The brief can't finish until that's written.

## 3. Information architecture (target)

```
Home
 ├─ Get research support        → faculty page (services, how to book, 3 short examples)
 └─ See DSC's campus contribution
     ├─ Research enabled          (consulting KPIs, case studies, long-view callout)
     │    └─ Evidence: consulting.qmd tables
     ├─ Research capability built (instruction KPIs, trajectory signals, eras callout)
     │    └─ Evidence: instruction.qmd tables
     └─ Shared infrastructure sustained (Dataverse, Redivis, compute, 1961 lineage)
          └─ Evidence: infrastructure.qmd tables
Methods & governance   (about.qmd, metrics-governance.md, claim register summary)
DSC History            (external link to ssda-dsc-history, unchanged)
Leadership brief (PDF) (linked from Home, not in main nav)
```

Keep the existing `consulting.qmd`, `instruction.qmd` and `infrastructure.qmd`
paths live, so external links and the brief's citations don't break. The
pathway pages are new files that pull the headline figures and link down
to the evidence pages.

## 4. Phases

Each phase is one branch and one PR against `dsc-stats-reports` main.

**Phase 0: decisions (Tim, ~30 min).** Section 2 items 1-3 unblock phases
1-3. Items 4-5 can wait.

**Phase 1: number sync.**
* Write a proposal in `dsc-stats-integration/proposals/` covering:
  * the instruction total
  * the lifetime figure
  * the consultation series
  * each with period, unit and caveats
* PR in `dsc-stats-reports`:
  * update the canonical aggregates and KPI inline code
  * add claim-register entries
  * update the brief's findings 2-3 and its Limitations section
* The brief's "consultations cover 2023-2025 only" limitation goes away.
  It's replaced by the mid-2024 capacity-loss explanation (Calendly lapse,
  no LibCal until May 2025, two reorgs), stated as a documented recording
  gap, not a decline in demand.

**Phase 2: IA skeleton, no new content.**
* Restructure `_quarto.yml` navigation.
* Add three pathway pages, each built only from existing KPIs and the 2
  existing case studies.
* Rebuild the home page with the two entry points.
* Render check, link check, accessibility pass (`/web-design-guidelines`).
  The site should look finished even with thin pathways.

**Phase 3: history integration** (per the decision in 2.2).
* Continuity band on the home page.
* Three long-view callouts.
* Every historical claim is lifted from `history.qmd` as corrected on
  2026-09-14, with a claim-register entry. Fix anything in the source repo
  first, never in the copy.
* Add a reciprocal "service record today" pointer in `history.qmd`'s
  research-impact section. That's a PR in `ssda-dsc-history`.

**Phase 4: case studies** (content-gated on decision 2.4).
* Add them to `impact_case_studies.csv` one at a time, each with a
  claim-register entry.
* Label them "illustrative, not representative" until there are 6.

**Phase 5: finish the side products.**
* Faculty page copy.
* Leadership brief: push its 2 local commits, fill in the ask, open a PR.
* `/validate-external` on the finished site plus brief as a pair, before
  anything goes to faculty or the Senate.

## 5. Risks

* **Stale numbers leak.** The brief and site were drafted before the
  2026-09-11 reconciliation. Phase 1 has to land before anything goes out
  (including anything tied to the Groeling / Senate outreach).
* **Named exemplars.** Publicly findable is the floor. Credit or consent
  is better for anything a faculty audience will read.
* **The `single-source-reports-wip` branch** (`dsc_stats_reporting:31`) is
  a separate retrospective page with its own render bugs. Don't fold it in
  here. It stays its own task.
* **Scope creep into a single site.** Deferred on purpose. Revisit only if
  maintaining two sites becomes the bottleneck.

## 6. Housekeeping state at plan time

* `draft-leadership-brief-2026-09-13`: 3 commits beyond `origin/main`, 2
  of them unpushed, no PR.
* Local `main` is 9 commits behind `origin/main`. Pull before branching.
