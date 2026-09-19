# Secret hygiene (pre-write checklist)

Run this before writing `docs/HANDOFF.md`, an ADR, the glossary, or the local overlay. The rule: **reference, never value.**

## Checklist

1. Scan the content you are about to write for the patterns below.
2. Replace any match with a reference (`env:VAR_NAME`, `1password://vault/item`) or `<redacted>`.
3. Never paste raw tokens, keys, passwords, connection strings, or `.env` contents.
4. If a value is truly ephemeral, put it in `.opencode/handoff.local.md` (gitignored) — still prefer a reference.
5. Commit only after the scan is clean.

## Patterns to catch and redact

| Pattern | Example / note |
| --- | --- |
| `sk-` | API secret keys (OpenAI-style and similar) |
| `ghp_` | GitHub personal access tokens |
| `glpat-` | GitLab personal access tokens |
| `npm_` | npm access tokens |
| `pypi-` | PyPI API tokens |
| `AKIA` | AWS access key IDs |
| AWS secret access keys | 40-char base64 value near `aws_secret_access_key` / `AKIA...` |
| GCP service-account JSON | `"private_key": "-----BEGIN PRIVATE KEY-----"` in a service-account file |
| `xoxb-` | Slack bot tokens (`xoxp-`, `xoxa-` too) |
| Slack webhook URLs | `https://hooks.slack.com/services/...` |
| JWT | Three base64url segments: `xxxxx.yyyyy.zzzzz` |
| `password=` | Inline credentials in URLs/config |
| `api_key=` | Inline API keys |
| Generic private-key blocks | `-----BEGIN ... PRIVATE KEY-----` (RSA, EC, OPENSSH, PGP) |

Also redact obvious connection strings (`postgres://user:pass@...`, `redis://:pass@...`) and any high-entropy string of 20+ chars that looks like a token.

## Redaction rule

- Bad: `OPENAI_API_KEY=sk-abc123...`
- Good: `OpenAI key → env:OPENAI_API_KEY`
- Bad: `db password is hunter2`
- Good: `DB password → 1password://infra/prod-db`
