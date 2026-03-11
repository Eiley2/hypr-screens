#!/bin/bash
set -euo pipefail

MARKER="# >>> hypr-screens >>>"
MARKER_END="# <<< hypr-screens <<<"

info()  { echo -e "\033[1;34m::\033[0m $*"; }
ok()    { echo -e "\033[1;32m::\033[0m $*"; }
warn()  { echo -e "\033[1;33m::\033[0m $*"; }

# --- 1. Remove script ---
if [ -f ~/.local/bin/hypr-screens ]; then
    rm ~/.local/bin/hypr-screens
    ok "Removed ~/.local/bin/hypr-screens"
else
    warn "Script not found, skipping"
fi

# --- 2. Remove CSS ---
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
if [ -f "$WAYBAR_STYLE" ] && grep -q "$MARKER" "$WAYBAR_STYLE"; then
    sed -i "/$MARKER/,/$MARKER_END/d" "$WAYBAR_STYLE"
    ok "Removed styles from $WAYBAR_STYLE"
fi

# --- 3. Waybar config (manual) ---
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
warn "Waybar config ($WAYBAR_CONFIG) needs manual cleanup:"
echo "  - Remove \"custom/screens\" from modules-right"
echo "  - Remove the \"custom/screens\" module definition"
echo "  - Or run: omarchy-refresh-waybar"

# --- 4. Optional: remove state ---
echo ""
read -rp "Remove state (~/.cache/hypr-screens)? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm -rf ~/.cache/hypr-screens
    ok "Removed state"
fi

echo ""
ok "hypr-screens uninstalled!"
echo "Run omarchy-restart-waybar to apply changes."
