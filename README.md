# opencode config

Portable, version-controlled configuration for [opencode](https://opencode.ai):
global config, agents, skills, and MCP server definitions. This repo is **local
only** — there is no remote and nothing is pushed.

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
git clone <url> ~/.config/opencode
```

If it already exists, clone to a temp dir and copy the contents in:

```bash
git clone <url> /tmp/opencode-config
mkdir -p ~/.config/opencode
cp -a /tmp/opencode-config/. ~/.config/opencode/
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
3. Runs `npm install` when `package.json` exists and `node_modules` is missing.

## Re-authenticate

Credentials are never versioned. On each new machine:

```bash
opencode auth login
```

Then **quit and restart** opencode so the new config, agents, and skills load.

## Intentionally NOT versioned

- `auth.json` — credentials.
- `*.db`, `*.db-shm`, `*.db-wal` — local state databases.
- `node_modules/` — recreated by `npm install`.
- `log/`, `*.log` — runtime logs.
- `.opencode/` — local plans/scratch.
- `*.bak`, `*.bak.*` — install-time backups.

## Skills: single source of truth

`skills/` in this repo is the **only** source of skills. It is auto-loaded from
`~/.config/opencode/skills`. Do not keep a second copy under `~/.agents/skills`
on any machine, or skills will load twice.

## Updating

On any machine:

```bash
git pull && ./install.sh
```

The one-time `__HOME__` substitution and skills demotion make re-running
`install.sh` a no-op when state is already correct.
