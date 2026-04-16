#!/usr/bin/env bash
# install.sh — one-time setup for sync-folder
#
# What this does:
#   1. Symlinks sync-folder to ~/.local/bin/ (makes it globally callable)
#   2. Creates ~/.rsync-aliases.sh (stores per-project aliases)
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

# ─── 1. Locate sync-folder script ────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_FOLDER_SCRIPT="$SCRIPT_DIR/sync-folder"

if [[ ! -f "$SYNC_FOLDER_SCRIPT" ]]; then
  err "sync-folder script not found at: $SYNC_FOLDER_SCRIPT"
  err "Make sure install.sh and sync-folder are in the same directory."
  exit 1
fi

chmod +x "$SYNC_FOLDER_SCRIPT"

echo ""
echo -e "${BOLD}sync-folder installer${RESET}"
echo "────────────────────────────────────────"

# ─── 2. Create ~/.local/bin and symlink ──────────────────────────────────────
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

SYMLINK_TARGET="$LOCAL_BIN/sync-folder"

if [[ -L "$SYMLINK_TARGET" ]]; then
  EXISTING_DEST="$(readlink "$SYMLINK_TARGET")"
  if [[ "$EXISTING_DEST" == "$SYNC_FOLDER_SCRIPT" ]]; then
    ok "sync-folder already installed at $SYMLINK_TARGET"
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
  warn "~/.local/bin is not in your PATH — sync-folder won't be callable."
  read -rp "  Add it to $CONFIG_FILE now? [Y/n]: " path_answer
  if [[ "${path_answer,,}" != "n" ]]; then
    {
      echo ""
      echo "# Added by sync-folder install"
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

# ─── 5. Patch shell config to source aliases file ────────────────────────────
ALIASES_FILE="$HOME/.rsync-aliases.sh"
SOURCE_LINE="[ -f \"\$HOME/.rsync-aliases.sh\" ] && source \"\$HOME/.rsync-aliases.sh\""

if grep -q "rsync-aliases.sh" "$CONFIG_FILE" 2>/dev/null; then
  ok "$CONFIG_FILE already sources rsync-aliases.sh"
else
  {
    echo ""
    echo "# rsync project aliases — managed by sync-folder"
    echo "$SOURCE_LINE"
  } >> "$CONFIG_FILE"
  ok "Added source line to $CONFIG_FILE"
fi

# ─── 6. Create ~/.rsync-aliases.sh if missing ────────────────────────────────
if [[ ! -f "$ALIASES_FILE" ]]; then
  {
    echo "# rsync aliases — managed by sync-folder"
    echo "# Each project block is delimited by BEGIN/END markers."
    echo "# Do not edit the BEGIN/END lines manually."
    echo "# To add a project: sync-folder <local> <host:remote> <name>"
    echo "# To remove a project: delete the corresponding BEGIN/END block"
  } > "$ALIASES_FILE"
  ok "Created $ALIASES_FILE"
else
  ok "$ALIASES_FILE already exists"
fi

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
echo -e "    ${BOLD}sync-folder . baobab:~/projects/myproject myproject${RESET}"
echo ""
echo "  This creates two aliases:"
echo "    myproject-up   — push local → remote"
echo "    myproject-down — pull remote → local"
echo ""
