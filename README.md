# opencode config

Portable, version-controlled configuration for [opencode](https://opencode.ai):
global config, agents, skills, and MCP server definitions. It is synced to a
**private GitHub repository** (`https://github.com/oasrcode/opencode-config`).
Secrets are excluded from version control, and credentials must never be
committed.

## What's inside

| Path                | Purpose                                                        |
| ------------------- | -------------------------------------------------------------- |
| `opencode.jsonc`    | Global config: models, MCP servers, compaction, default agent.  |
| `AGENTS.md`         | Global agent rules (graph-first discovery, delegation, safety). |
| `agents/*.md`       | Subagents: backend, devops, frontend, orchestrator, researcher, reviewer. |
| `skills/`           | Skills auto-loaded from `~/.config/opencode/skills`.            |
| `.skill-lock.json`  | Installed-skill lockfile (source + hash tracking).             |
| `package.json` / `package-lock.json` | Plugin dependencies (pinned).                |
| `install.sh`        | Idempotent bootstrap for a new machine.                        |

## Clone onto a new WSL machine

If `~/.config/opencode` does **not** exist yet:

```bash
git clone https://github.com/oasrcode/opencode-config.git ~/.config/opencode
cd ~/.config/opencode && ./install.sh
```

If it already exists, clone to a temp dir and copy only the working files in —
never nest a second `.git` inside `~/.config/opencode`:

```bash
git clone https://github.com/oasrcode/opencode-config.git /tmp/opencode-config
mkdir -p ~/.config/opencode
rsync -a --exclude .git /tmp/opencode-config/ ~/.config/opencode/
cd ~/.config/opencode && ./install.sh
```

## Bootstrap

```bash
cd ~/.config/opencode
./install.sh
```

`install.sh` is idempotent. It:

1. Replaces the `__HOME__` placeholder in `opencode.jsonc` with the real
   `$HOME` (one-time, with a `opencode.jsonc.bak.<timestamp>` backup).
2. If `~/.agents/skills` exists as a real directory, moves it to
   `~/.agents/skills.bak.<timestamp>` so the repo's `skills/` becomes the
   single source of truth (avoids duplicate skills loading). Symlinks or an
   absent directory are left untouched.
3. Runs `npm ci` when `package.json` exists and `node_modules` is missing.
4. Prints non-fatal preflight hints if the MCP binary or Playwright browsers
   are missing (it never installs them for you and never fails on absence).

## MCP: `codebase-memory-mcp`

`codebase-memory-mcp` is **not** versioned in this repo — only its launch path is
referenced (`~/.local/bin/codebase-memory-mcp`). Install it per machine with:

```bash
curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash
```

This places the binary at `~/.local/bin/codebase-memory-mcp`. `install.sh` warns
(but does not install) if it is missing.

Playwright browsers are also machine-local; install them with:

```bash
npx playwright install chromium
```

## Re-authenticate

Credentials are never versioned. On each new machine:

```bash
opencode auth login
```

Then **quit and restart** opencode so the new config, agents, and skills load.

## Intentionally NOT versioned

- `auth.json` — credentials.
- `*.db`, `*.db-shm`, `*.db-wal` — local state databases.
- `node_modules/` — recreated by `npm ci`.
- `log/`, `*.log` — runtime logs.
- `.opencode/` — local plans/scratch.
- `*.bak`, `*.bak.*` — install-time backups.

## Skills: single source of truth

`skills/` in this repo is the **only** source of skills. It is auto-loaded from
`~/.config/opencode/skills`. Do not keep a second copy under `~/.agents/skills`
on any machine, or skills will load twice.

## Updating

After `install.sh` runs, `opencode.jsonc` becomes **locally modified** on
purpose: the tracked file keeps the `__HOME__` placeholder while the working copy
holds the real path. Discard that substitution before pulling, then re-apply it:

```bash
cd ~/.config/opencode
git checkout -- opencode.jsonc   # discard local __HOME__ substitution
git pull --ff-only
./install.sh                     # re-apply substitution
```

The `__HOME__` substitution and skills demotion make re-running `install.sh` a
no-op when the machine state is already correct.
