<!-- Paste into the target project's AGENTS.md so all agents and subagents honor the convention. -->

## Project memory (handoff)

- At the start of any task, read `docs/HANDOFF.md` (and `.opencode/handoff.local.md` if present) before acting.
- At the close of any task, update `docs/HANDOFF.md` via the `handoff` skill (sections: Estado actual, En curso, Siguientes pasos, Bloqueos, Decisiones recientes, Secretos y credenciales).
- Append an ADR to `docs/adr/` for architectural decisions; record domain terms in `CONTEXT.md`.
- Commit `docs/` (stage specific files only).
- Never write secret VALUES into `docs/` or `.opencode/handoff.local.md` — references only (`env:VAR`, `1password://vault/item`).
