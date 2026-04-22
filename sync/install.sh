#!/usr/bin/env bash
# install.sh — one-time setup for hpc-sync
#
# What this does:
#   1. Symlinks hpc-sync to ~/.local/bin/ (makes it globally callable)
#   2. Creates ~/.rsync-aliases.sh (stores per-project sync commands)
#   3. Patches your shell config to source ~/.rsync-aliases.sh on login
#   4. Optionally adds ~/.local/bin to your PATH if it's missing
#
# Run from any directory:
#   bash /path/to/hpc-unige/sync/install.sh

set -euo pipefail

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
BOLD='\033[1m'; RESET='\033[0m'

err()  { echo -e "${RED}ERROR:${RESET} $*" >&2; }
warn() { echo -e "${YELLOW}WARN:${RESET}  $*"; }
ok()   { echo -e "${GREEN}✓${RESET} $*"; }
info() { echo "  $*"; }

# ─── 1. Locate hpc-sync script ───────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_FOLDER_SCRIPT="$SCRIPT_DIR/sync-folder"

if [[ ! -f "$SYNC_FOLDER_SCRIPT" ]]; then
  err "hpc-sync script source not found at: $SYNC_FOLDER_SCRIPT"
  err "Make sure install.sh and sync-folder are in the same directory."
  exit 1
fi

chmod +x "$SYNC_FOLDER_SCRIPT"

echo ""
echo -e "${BOLD}hpc-sync installer${RESET}"
echo "────────────────────────────────────────"

# ─── 2. Create ~/.local/bin and symlink ──────────────────────────────────────
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

SYMLINK_TARGET="$LOCAL_BIN/hpc-sync"

if [[ -L "$SYMLINK_TARGET" ]]; then
  EXISTING_DEST="$(readlink "$SYMLINK_TARGET")"
  if [[ "$EXISTING_DEST" == "$SYNC_FOLDER_SCRIPT" ]]; then
    ok "hpc-sync already installed at $SYMLINK_TARGET"
  else
    warn "Symlink exists but points to: $EXISTING_DEST"
    warn "Updating to: $SYNC_FOLDER_SCRIPT"
    ln -sf "$SYNC_FOLDER_SCRIPT" "$SYMLINK_TARGET"
    ok "Symlink updated."
  fi
elif [[ -f "$SYMLINK_TARGET" ]]; then
  warn "$SYMLINK_TARGET exists as a regular file. Replacing with symlink."
  ln -sf "$SYNC_FOLDER_SCRIPT" "$SYMLINK_TARGET"
  ok "Replaced with symlink."
else
  ln -s "$SYNC_FOLDER_SCRIPT" "$SYMLINK_TARGET"
  ok "Created symlink: $SYMLINK_TARGET → $SYNC_FOLDER_SCRIPT"
fi

# ─── 3. Detect shell ─────────────────────────────────────────────────────────
echo ""
DETECTED_SHELL="$(basename "${SHELL:-bash}")"
echo -e "${BOLD}Shell configuration${RESET}"
info "Detected shell: $DETECTED_SHELL"
read -rp "  Press Enter to use '$DETECTED_SHELL', or type 'bash'/'zsh' to override: " shell_override

if [[ -n "$shell_override" ]]; then
  TARGET_SHELL="$shell_override"
else
  TARGET_SHELL="$DETECTED_SHELL"
fi

case "$TARGET_SHELL" in
  zsh)  CONFIG_FILE="$HOME/.zshrc" ;;
  bash) CONFIG_FILE="$HOME/.bashrc" ;;
  *)
    warn "Unknown shell '$TARGET_SHELL'. Falling back to ~/.bashrc"
    CONFIG_FILE="$HOME/.bashrc"
    ;;
esac

if [[ ! -f "$CONFIG_FILE" ]]; then
  touch "$CONFIG_FILE"
  ok "Created $CONFIG_FILE"
else
  ok "Using $CONFIG_FILE"
fi

# ─── 4. Check ~/.local/bin in PATH ───────────────────────────────────────────
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
  echo ""
  warn "~/.local/bin is not in your PATH — hpc-sync won't be callable."
  read -rp "  Add it to $CONFIG_FILE now? [Y/n]: " path_answer
  if [[ "${path_answer,,}" != "n" ]]; then
    {
      echo ""
      echo "# Added by hpc-sync install"
      echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
    } >> "$CONFIG_FILE"
    ok "Added ~/.local/bin to PATH in $CONFIG_FILE"
    # Also export for the current session
    export PATH="$LOCAL_BIN:$PATH"
  else
    warn "Skipped. You'll need to add ~/.local/bin to your PATH manually."
  fi
else
  ok "~/.local/bin is already in PATH"
fi

# ─── 5. Patch shell config to source commands file ───────────────────────────
ALIASES_FILE="$HOME/.rsync-aliases.sh"
SOURCE_LINE="[ -f \"\$HOME/.rsync-aliases.sh\" ] && source \"\$HOME/.rsync-aliases.sh\""
DISPATCHER_START="# BEGIN HPC DISPATCHERS"
DISPATCHER_END="# END HPC DISPATCHERS"
DISPATCHER_BLOCK="$(cat <<'EOF'
# BEGIN HPC DISPATCHERS
hpc-up() {
  local name="${1:-}"
  if [[ -z "$name" ]]; then
    echo "Usage: hpc-up <project-name>" >&2
    return 1
  fi
  local fn="__hpc_up_$(printf '%s' "$name" | sed -e 's/_/__us__/g' -e 's/-/__dash__/g')"
  if typeset -f "$fn" >/dev/null 2>&1; then
    "$fn" "$@"
    return $?
  fi
  local legacy_alias="${name}-up"
  if alias "$legacy_alias" >/dev/null 2>&1; then
    local legacy_cmd
    legacy_cmd="$(alias "$legacy_alias" 2>/dev/null)"
    legacy_cmd="${legacy_cmd#*=}"
    eval "$legacy_cmd"
    return $?
  fi
  echo "Unknown project: $name" >&2
  return 1
}

hpc-down() {
  local name="${1:-}"
  if [[ -z "$name" ]]; then
    echo "Usage: hpc-down <project-name>" >&2
    return 1
  fi
  local fn="__hpc_down_$(printf '%s' "$name" | sed -e 's/_/__us__/g' -e 's/-/__dash__/g')"
  if typeset -f "$fn" >/dev/null 2>&1; then
    "$fn" "$@"
    return $?
  fi
  local legacy_alias="${name}-down"
  if alias "$legacy_alias" >/dev/null 2>&1; then
    local legacy_cmd
    legacy_cmd="$(alias "$legacy_alias" 2>/dev/null)"
    legacy_cmd="${legacy_cmd#*=}"
    eval "$legacy_cmd"
    return $?
  fi
  echo "Unknown project: $name" >&2
  return 1
}
# END HPC DISPATCHERS
EOF
)"

if grep -q "rsync-aliases.sh" "$CONFIG_FILE" 2>/dev/null; then
  ok "$CONFIG_FILE already sources rsync-aliases.sh"
else
  {
    echo ""
    echo "# rsync project commands — managed by hpc-sync"
    echo "$SOURCE_LINE"
  } >> "$CONFIG_FILE"
  ok "Added source line to $CONFIG_FILE"
fi

# ─── 6. Create ~/.rsync-aliases.sh if missing ────────────────────────────────
if [[ ! -f "$ALIASES_FILE" ]]; then
  {
    echo "# rsync project commands — managed by hpc-sync"
    echo "# Use hpc-up <name> and hpc-down <name> after registering a project."
    echo "# Each project block is delimited by BEGIN/END markers."
    echo "# Do not edit the BEGIN/END lines manually."
    echo "# To add a project: hpc-sync <local> <host:remote> <name>"
    echo "# To remove a project: delete the corresponding BEGIN/END block"
    echo ""
    printf '%s\n' "$DISPATCHER_BLOCK"
  } > "$ALIASES_FILE"
  ok "Created $ALIASES_FILE"
else
  ok "$ALIASES_FILE already exists"
fi

if grep -q "^${DISPATCHER_START}$" "$ALIASES_FILE" 2>/dev/null; then
  sed -i "/^${DISPATCHER_START}$/,/^${DISPATCHER_END}$/d" "$ALIASES_FILE"
fi
{
  printf '%s\n' "$DISPATCHER_BLOCK"
  echo ""
  cat "$ALIASES_FILE"
} > "${ALIASES_FILE}.tmp"
mv "${ALIASES_FILE}.tmp" "$ALIASES_FILE"
ok "Ensured hpc-up / hpc-down commands exist in $ALIASES_FILE"

# ─── 7. Create logs directory ─────────────────────────────────────────────────
mkdir -p "$HOME/.rsync-logs"
ok "Created ~/.rsync-logs/ (cron job output goes here)"

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────${RESET}"
echo -e "${BOLD}${GREEN}Installation complete!${RESET}"
echo -e "${BOLD}────────────────────────────────────────${RESET}"
echo ""
echo "  Reload your shell config to activate:"
echo -e "    ${BOLD}source $CONFIG_FILE${RESET}"
echo ""
echo "  Then register a project from its directory:"
echo -e "    ${BOLD}hpc-sync . baobab:~/projects/myproject myproject${RESET}"
echo ""
echo "  This enables two commands:"
echo "    hpc-up myproject   — push local → remote"
echo "    hpc-down myproject — pull remote → local"
echo ""
