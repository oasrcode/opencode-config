---
name: handoff
description: Use when starting or ending work in a project repository, when the user says "handoff", "retomemos", "guarda el estado", "nueva sesión", or before context is lost; creates and maintains durable, git-committed project memory in docs/ (HANDOFF.md, docs/adr/ ADRs, CONTEXT.md) with a local gitignored overlay.
---

# Handoff

Durable, git-committed project memory so any future session can resume without re-deriving context. `docs/` is the durable memory; scratch is ephemeral.

Announce: "I'm using the handoff skill."

## Target project layout

| Path | Committed | Purpose |
| --- | --- | --- |
| `docs/HANDOFF.md` | yes | Sanitized live state: where we are, what's next |
| `docs/adr/NNNN-*.md` | yes | ADRs, append-only |
| `CONTEXT.md` | yes | Domain terms and invariants |
| `.opencode/handoff.local.md` | no (gitignored) | Sensitive or ephemeral notes (free-form local overlay) |

`docs/HANDOFF.md` is durable memory. `.opencode/plans/`, commits, and diffs stay ephemeral scratch: reference them, do not duplicate their content here.

## Scope exclusion

Do NOT initialize project memory inside the opencode global config repo (`~/.config/opencode`). There, use `.opencode/plans/` instead.

## On start / resume

1. Always ensure `.opencode/handoff.local.md` is listed in the project's `.gitignore` (add it if missing) — unconditionally, on every start/resume.
2. If `docs/HANDOFF.md` does not exist, create the structure from this skill's `templates/`: `docs/HANDOFF.md`, `docs/adr/`, `CONTEXT.md`.
3. If it exists, read `docs/HANDOFF.md` (`Estado actual`, `En curso`, `Siguientes pasos`, `Decisiones recientes`) before acting.
4. Read `.opencode/handoff.local.md` if present.
5. Ensure the project's `AGENTS.md` contains the snippet from `templates/AGENTS.project.md` so subagents honor the convention.

## On close / handoff request

1. Run the pre-write checklist in `reference/secret-hygiene.md`.
2. Rewrite `docs/HANDOFF.md` following `templates/HANDOFF.md` (sections: Estado actual, En curso, Siguientes pasos, Bloqueos, Decisiones recientes, Secretos y credenciales — references only).
3. Write sensitive or ephemeral notes to `.opencode/handoff.local.md` instead.
4. Append an ADR to `docs/adr/` (next number, `templates/adr.md`) when an architectural decision was made. Never rewrite existing ADRs.
5. Commit `docs/` (stage specific files only).

## Secret hygiene (mandatory)

Never write secret VALUES. Only references: `env:VAR_NAME` or `1password://vault/item`. Before any write, run the checklist in `reference/secret-hygiene.md`. Redact anything matching token patterns (`sk-`, `ghp_`, `AKIA`, `xoxb-`, JWTs, `password=`, `api_key=`, private keys) to a reference or `<redacted>`.

## Templates

- `templates/HANDOFF.md` — fill-in live-state doc
- `templates/adr.md` — MADR-lite decision record
- `templates/CONTEXT.md` — domain glossary + invariants
- `templates/AGENTS.project.md` — snippet for the target project's `AGENTS.md`
- `templates/pre-commit-config.yaml` — gitleaks hook to commit in the project; it triggers on every commit and scans the full staged index (not only docs)
- `reference/secret-hygiene.md` — pre-write checklist and redaction rule
