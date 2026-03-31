# AGENTS.md

## Purpose
This file provides starter operating guidance for AI agents working on this project.
Use it with `project-registry.yaml` and repo-local documentation to stay aligned with canonical project context.

## Canonical Repository
- Project key: `dsc_stats_reporting`
- Canonical repository path: `/Users/timdennis/projects/dsc-stats/dsc-stats-reports`
- Status: active

## Context Loading Order
1. `~/projects/project-registry.yaml` for canonical project metadata
2. Repo-local `GEMINI.md` (agent-specific guidance)
3. Repo-local `AGENTS.md` (this file)

## Related Paths
- Website paths:
  - (none)
- Data paths:
  - (none)
- Non-canonical paths:
  - (none)

## Repo-Local Signals
- `_quarto.yml` detected: a Quarto workflow may be in use.
- `pixi.toml` detected: a pixi-managed environment may be in use.
- `GEMINI.md` detected: include it when working with Gemini CLI.

## Rules For Agents
- Work in the canonical repository unless explicitly told otherwise.
- Avoid creating duplicate working copies in Downloads or Documents.
- If registry metadata conflicts with stale notes, prefer `project-registry.yaml`.
- Prefer repo-local `README.md`, `CONTEXT.md`, and `AGENTS.md` when present.

## File Placement Guidance
- Keep this file at repository root as `AGENTS.md`.
- Keep project-level policy updates in `~/projects/project-registry.yaml`.
- Keep implementation details and task plans in repo-local docs where possible.

## Output Expectations For Agents
- Confirm target files before editing.
- Prefer minimal, additive patches.
- Report what changed, why, and any unresolved risks.
- Do not move, rename, or delete repositories unless explicitly instructed.

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:ca08a54f -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

## Session Completion

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
<!-- END BEADS INTEGRATION -->
