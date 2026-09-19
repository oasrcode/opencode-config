#!/usr/bin/env bash
#
# install.sh — bootstrap the portable opencode config on a new machine.
#
# Idempotent: safe to run multiple times. It:
#   1. Substitutes __HOME__ in opencode.jsonc with the real $HOME (one-time).
#   2. Demotes a live ~/.agents/skills directory so the repo's skills/ is the
#      single source of truth (no duplicate skill loading).
#
# Secrets excluded; config is pushed to a private GitHub remote (origin).
# Never commit credentials.
set -euo pipefail

# Resolve the repo as this script's own directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"

timestamp() { date +%Y%m%d%H%M%S; }

log() { printf '[install] %s\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. opencode.jsonc: __HOME__ -> $HOME (only if the placeholder is present)
# ---------------------------------------------------------------------------
CONFIG="$REPO_DIR/opencode.jsonc"
if [ -f "$CONFIG" ]; then
  if grep -q '__HOME__' "$CONFIG"; then
    backup="$CONFIG.bak.$(timestamp)"
    cp -p "$CONFIG" "$backup"
    log "Placeholder found. Backed up config to $(basename "$backup")"
    # Escape characters special to sed's replacement field.
    home_escaped="${HOME//\\/\\\\}"
    home_escaped="${home_escaped//&/\\&}"
    home_escaped="${home_escaped//|/\\|}"
    sed -i "s|__HOME__|${home_escaped}|g" "$CONFIG"
    log "Substituted __HOME__ with $HOME in opencode.jsonc"
  else
    log "opencode.jsonc already has no __HOME__ placeholder. Nothing to do."
  fi
else
  log "WARNING: $CONFIG not found. Skipping placeholder substitution."
fi

# ---------------------------------------------------------------------------
# 2. Skills: demote a live ~/.agents/skills directory (not a symlink)
# ---------------------------------------------------------------------------
LIVE_SKILLS="$HOME/.agents/skills"
if [ -d "$LIVE_SKILLS" ] && [ ! -L "$LIVE_SKILLS" ]; then
  backup_skills="$LIVE_SKILLS.bak.$(timestamp)"
  mv "$LIVE_SKILLS" "$backup_skills"
  log "Moved live $LIVE_SKILLS to $backup_skills"
  log "Repo skills/ ($REPO_DIR/skills) is now the single source of truth."
elif [ -L "$LIVE_SKILLS" ]; then
  log "$LIVE_SKILLS is a symlink. Leaving it untouched."
else
  log "$LIVE_SKILLS absent. Nothing to do."
fi

# ---------------------------------------------------------------------------
# 3. Preflight hints (non-fatal: never installs, never exits non-zero)
# ---------------------------------------------------------------------------
MCP_BIN="$HOME/.local/bin/codebase-memory-mcp"
if [ ! -e "$MCP_BIN" ]; then
  log "WARNING: $MCP_BIN not found."
  log "         Install codebase-memory-mcp with:"
  log "         curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash"
fi

PLAYWRIGHT_CACHE="$HOME/.cache/ms-playwright"
if [ ! -d "$PLAYWRIGHT_CACHE" ]; then
  log "WARNING: $PLAYWRIGHT_CACHE not found."
  log "         Install Playwright browsers with: npx playwright install chromium"
fi

# ---------------------------------------------------------------------------
# 4. Next steps
# ---------------------------------------------------------------------------
cat <<EOF

[install] Done.

Next steps:
  1. Authenticate on this machine:   opencode auth login
  2. Quit and restart opencode so the new config, agents, and skills load.

Config:  $CONFIG
Skills:  $REPO_DIR/skills  (single source of truth)
EOF
