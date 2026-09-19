<!-- Paste into the target project's AGENTS.md so all agents and subagents honor the convention. -->

## Project memory (handoff)

- At the start of any task, follow the handoff setup: read `docs/HANDOFF.md` (and `.opencode/handoff.local.md` if present) before acting, and verify the pre-commit (gitleaks) setup, offering the one-time setup if missing (see the `handoff` skill's setup check).
- At the close of any task, update `docs/HANDOFF.md` via the `handoff` skill (sections: Estado actual, En curso, Siguientes pasos, Bloqueos, Decisiones recientes, Secretos y credenciales).
- Append an ADR to `docs/adr/` for architectural decisions; record domain terms in `CONTEXT.md`.
- Stage `docs/` (specific files only); commit only with explicit user approval.
- Never write secret VALUES into `docs/` or `.opencode/handoff.local.md` — references only (`env:VAR`, `1password://vault/item`).
