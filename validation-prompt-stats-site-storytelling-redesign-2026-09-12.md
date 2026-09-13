# Validation request: repositioning a university data-service dashboard as an impact narrative

## What this project is

`dsc-stats-reports` is a public Quarto static site (GitHub Pages) for the UCLA
Library Data Science Center (DSC), a research-computing/data-support unit
inside a university library. DSC runs three kinds of service: one-on-one
research consultations, instructional workshops (in-house and joint
UC-wide series), and infrastructure (a research data repository, cloud
storage). The site currently reports metrics on all three.

A sibling project, `ssda-dsc-history`, is a single narrative document (prose,
footnoted, Chicago-style citations) telling the institutional history of this
unit and its predecessor archive back to 1961. The two sites are separate
Quarto projects, now both hosted under the same GitHub org, cross-linked by
navbar, but structurally and stylistically unrelated. No merge of the two is
planned right now.

## The current approach (stats site)

The site is a metrics dashboard, not a narrative. Pages: Home, Consulting,
Instruction, Infrastructure, About. Every page follows the same pattern
regardless of who's reading it:

- An "At a Glance" KPI strip (counts, year-over-year deltas)
- A sequence of breakdown tables/charts: **By Year**, **By Department**,
  **By Affiliation**, **By Team** (Consulting) / **UC-Wide Series**, **By
  Organizational Parent** (Instruction)
- A closing prose section

The site's own stated audience (from `about.qmd`) is: "DSC leadership and
library administration (annual reporting, program review, resource
planning); DSC staff (service load, trends); Researchers and partners (how
DSC tracks and reports impact)." One page, one format, all audiences.

There is already one narrative element, underused: a "Research Impact"
section at the *bottom* of the Consulting page, after five tables, backed by
a small CSV (`impact_case_studies.csv`). It currently holds exactly 2 rows:

```
Carceral Ecologies — UCLA Institute for Society and Genetics (Nicholas
Shapiro). Multi-year support: R server infrastructure, data processing,
student training on a helicopter-surveillance dataset. Measurable outcome:
processing time cut from ~318 min to ~2 min (~159x). Impact signal: national
media coverage (LA Times, New Yorker, Bloomberg), award-recognized UCLA
public-impact research.

BioCritical Studies Lab — UCLA (Grace Sosa; Terence Keel). Multi-year
collaboration: data integration, statistical analysis, visualization for a
deaths-in-custody dataset. Measurable outcome: substantial cleanup/transform
for geographic analysis, workflows built for reuse. Impact signal: UCLA's
2024 Public Impact Research Awards.
```

Separately, a different internal project has been running identity-resolution
work on workshop attendee rosters (not yet surfaced on the public site) that
tracks a different kind of impact: whether people who came through DSC
workshops (mostly grad students, some staff) later show up in
research/data-intensive roles. Two completed passes found at least 10 of 43
qualifying 2025 attendees, and at least 29 of 123 qualifying 2021-2024
attendees, confirmed in such roles later. This is closer to a tracer/alumni
study than a service-log metric.

Governance rules already in force, from `metrics-governance.md`, that should
NOT be relitigated: consultations, tasks, and tickets are different units
and must never be summed into one unlabeled "total work" figure; missing
department/affiliation is reported as "unknown," never inferred or folded
into a default category; an `organizational_parent` crosswalk maps known
UCLA departments to schools/divisions/institutes but leaves ~29 attendance
records deliberately unresolved. AWS dollar figures were just removed from
the public Infrastructure page (relative usage-share trend kept instead) —
that's a settled call, not up for debate here.

## The proposed redesign

Tim (DSC director) wants to reposition this site: from a reporting layer
built for his own management chain, to something that tells the story of
DSC's impact over time, for two specific external audiences:

1. **Faculty** — potential/current research partners
2. **Campus administrators** — deans, department chairs (people who make
   resourcing and support decisions about DSC, but don't run its day-to-day
   metrics)

He's also asked us to name the *genre* of what this actually is: it spans
aggregated service statistics, departmental engagement patterns, and now a
tracer-study element (trajectory of learners/clients/scholars who used DSC's
products and services over time, not just whether they showed up once).

## What we want challenged

1. **Is bundling "faculty" and "deans/chairs" into one redesign a mistake?**
   Faculty plausibly want relevance ("will this help my lab/students, who do
   I contact"); deans/chairs plausibly want resource-allocation signal
   ("return on our support, comparison across units, budget justification").
   Should this become two distinct entry points/framings sharing one data
   backend, rather than one blended narrative? What's the concrete failure
   mode of shipping one narrative to both?

2. **What genre is this, actually?** Is the right reference class an annual
   impact report (ACRL "Value of Academic Libraries," ARL statistics
   framing), a research core-facility annual report, an NSF/NIH
   broader-impacts narrative, an alumni/tracer study, or something else? Name
   the closest existing genre(s) and what conventions from them this project
   should adopt or explicitly reject, rather than inventing a format from
   scratch.

3. **Does a browsable multi-tab Quarto website even fit the audience?** A
   dean or department chair may be far more likely to read a 1-2 page PDF
   one-pager or a slide than click through a five-tab dashboard. Is the
   current site format (data-dashboard, click-to-explore) a poor match for
   this audience regardless of content changes, and if so what format
   should carry the "story" instead (the website could stay as the detailed
   backing evidence, similar to how `ssda-dsc-history`'s narrative document
   points to a companion evidence document)?

4. **What's the overclaiming risk?** The underlying data has real,
   documented unknowns (missing department for a majority of some
   categories, aggregate-only attendance for some Carpentries events, no
   unique-person dedup across years). A narrative "impact over time" framing
   invites compression and rounding that a table doesn't. What specific
   failure mode should we design against so a dean doesn't walk away
   quoting a number the data doesn't actually support?

5. **Is 2 case studies and 2 identity-resolution passes enough raw material
   to lead a redesign with narrative/anecdote, or is this fundamentally a
   content-collection problem (need more case studies, more tracer-study
   coverage) that should be solved before the site structure changes?** If
   the latter, what's a defensible order of operations?

6. **Should the existing "Research Impact" case-study block become the
   structural spine of the redesign** (lead with it, not bury it after five
   tables), and if so, what does that imply for how the tabular/dashboard
   content gets demoted or reorganized around it?

Give a confidence score for your overall read, and concrete corrections
(which audience split, which genre, which format) rather than general
design commentary. Assume the reader has zero context beyond this document.
