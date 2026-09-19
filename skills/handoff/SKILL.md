---
name: handoff
description: Use when starting or ending work in a project repository, when the user says "handoff", "retomemos", "guarda el estado", "nueva sesión", or before context is lost; creates and maintains durable, git-committed project memory in docs/ (HANDOFF.md, docs/adr/ ADRs, CONTEXT.md) with a local gitignored overlay; also use when entering or initializing a repository to check and offer the one-time pre-commit (gitleaks) setup.
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

## Setup check (on start / repo init)

Runs once per repository at entry, **before** `## On start / resume`. Detect and report the committed-memory + secret-scanning setup; if everything is already configured, report briefly — no nagging.

- Skip unless `git rev-parse --is-inside-work-tree` prints `true` (not merely exit 0).
- Skip inside the opencode global config repo (`~/.config/opencode`) — already excluded above.
- Otherwise check each item with a deterministic command and report what is missing:
  - Hook presence: `grep -q gitleaks .pre-commit-config.yaml` (config exists at the repo root and contains the gitleaks hook).
  - `gitleaks` on PATH: `command -v gitleaks`, and `gitleaks version` >= 8.19. The `gitleaks git` subcommand required by the hook was added in 8.19; older distro packages (e.g. apt's 8.16) will not work — recommend the release binary.
  - `pre-commit` on PATH: `command -v pre-commit`.
  - Hook installed: the pre-commit hook file exists at `$(git config --get core.hooksPath)/pre-commit` when `core.hooksPath` is set, otherwise at `.git/hooks/pre-commit` (i.e. `pre-commit install` has run).
- Never overwrite an existing `.pre-commit-config.yaml`: copy `templates/pre-commit-config.yaml` to the repo root ONLY when that file does not exist. If it exists but lacks the gitleaks hook, SHOW it and offer to APPEND the gitleaks repo entry with explicit user confirmation (optionally back it up first).
- If anything is missing: tell the user exactly what is missing and the exact commands to fix it, then OFFER to run the project-level setup (template copy/append as above, then `pre-commit install`) with explicit approval.
- Do NOT run `pre-commit install` while `gitleaks` is missing; warn that commits will fail until gitleaks >= 8.19 is installed.
- Never install system packages (no `sudo`, `apt`, `brew`, `go install`). The skill only detects, guides, and performs project-level setup; the user installs gitleaks/pre-commit themselves.
- Commit `.pre-commit-config.yaml` ONLY with explicit user approval, staging that file alone (`git add .pre-commit-config.yaml`).

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
5. Stage `docs/` (specific files only) and show the diff; commit ONLY on explicit user approval.

## Secret hygiene (mandatory)

Never write secret VALUES. Only references: `env:VAR_NAME` or `1password://vault/item`. Before any write, run the checklist in `reference/secret-hygiene.md`. Redact anything matching token patterns (`sk-`, `ghp_`, `AKIA`, `xoxb-`, JWTs, `password=`, `api_key=`, private keys) to a reference or `<redacted>`.

## Templates

- `templates/HANDOFF.md` — fill-in live-state doc
- `templates/adr.md` — MADR-lite decision record
- `templates/CONTEXT.md` — domain glossary + invariants
- `templates/AGENTS.project.md` — snippet for the target project's `AGENTS.md`
- `templates/pre-commit-config.yaml` — gitleaks hook to commit in the project; it triggers on every commit and scans the full staged index (not only docs)
- `reference/secret-hygiene.md` — pre-write checklist and redaction rule
