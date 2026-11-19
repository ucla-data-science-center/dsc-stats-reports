# Session Handoff - 2026-11-19

(Replaces the 2026-11-04 handoff. That text is in git history.)

## Accomplished
- 2026-11-04: filled the `social_sciences` entry in `briefs/divisions.yml` (SSDA in Dataverse, L2 voter file on Redivis, Carceral Ecologies, BioCritical Studies Lab), appended Social Sciences rows to `briefs/spine-aggregates-2026-10-24.csv` (272 attendance records from 105 people; 192 consult records from 78 people), added the optional `subtitle` field.
- 2026-11-19 (Tim): aligned the Social Sciences brief with the petition and the 11/13 responsibilities one-pager.
  - New optional template fields in `briefs/dean-brief.qmd`: `team_line`, `changes_line`, `ask_short`, `extra_sections`, `asks_lead`, `asks`. Defaults keep Humanities and Cotsen unchanged (Humanities text diff after re-render: date only).
  - Social Sciences: asks now lead with reinstatement (petition link), archive lead for Dataverse and geospatial collections, a named person per service including who pays to renew ICPSR and Roper, review date and written answer before Dec 31.
  - New sections: "Memberships and data access" (ICPSR founding member 1962; ICPSR role = pipeline into ICPSR, education, local support; ICPSR paid through June 2028, Roper through April 2027, LARIAC 8 2026 to 2028, Redivis) and "Geospatial data stewardship and spatial methods" (2019 Spatial Data Science Librarian posting vs the 2026 posting, text only).
  - BioCritical Studies Lab example rewritten as general support (Tim: do not overclaim). L2 "more than 10 terabytes" removed (unsourced).
  - PDF: `briefs/out/2026-11-19_data-science-center_social-sciences-research.pdf` (headless Chrome print of the HTML; copy in `~/Documents/dsc-reorg-response/service-impact/send/`). Sent to Martha Bailey (CCPR) for the 11/20 call.

## Decisions made
- Who pays for ICPSR and Roper is not stated. Why: Tim 11/19, no one has said who pays; the Library's 10/22 "Research Services holds the budget" statement is not used.
- "Official Representative" (ICPSR's term) not used until Tim confirms he holds it.
- Posting comparison describes the two texts only. The 2026 duties do say "methods" and "managing geospatial platform access", so the brief does not claim either is absent.
- Do not name students. Funding sources (gift fund vs membership fund) stay out; the registry and claim #22 disagree.

## Open
1. Doug is still listed as an author. Tim to confirm.
2. Carceral Ecologies (ISG) and BioCritical Studies Lab: confirm they count toward the Social Sciences Division.
3. Template intro still says "The research belongs to the faculty and students named". Tim cut that kind of line from the Keel email; decide for all briefs.
4. Cotsen not re-rendered after the template change (defaults should keep it identical).
5. Topics line (needs a second export) still not done.

## Files modified
- `briefs/dean-brief.qmd`, `briefs/divisions.yml`, `briefs/spine-aggregates-2026-10-24.csv`, `briefs/dean-brief.css` (print tightening, predates 11/19), `HANDOFF.md`
