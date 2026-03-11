#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MARKER="# >>> hypr-screens >>>"
MARKER_END="# <<< hypr-screens <<<"

info()  { echo -e "\033[1;34m::\033[0m $*"; }
ok()    { echo -e "\033[1;32m::\033[0m $*"; }
warn()  { echo -e "\033[1;33m::\033[0m $*"; }

backup() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.bak.$(date +%s)"
        info "Backed up $file"
    fi
}

# --- 1. Install script ---
info "Installing hypr-screens to ~/.local/bin/"
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/bin/hypr-screens" ~/.local/bin/hypr-screens
chmod +x ~/.local/bin/hypr-screens
mkdir -p ~/.cache/hypr-screens
touch ~/.cache/hypr-screens/disabled
ok "Script installed"

# --- 2. Patch Waybar config ---
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
if [ -f "$WAYBAR_CONFIG" ] && grep -q '"custom/screens"' "$WAYBAR_CONFIG"; then
    warn "Waybar config already has custom/screens, skipping"
else
    info "Patching $WAYBAR_CONFIG"
    backup "$WAYBAR_CONFIG"

    # Add custom/screens to modules-right
    if grep -q '"modules-right"' "$WAYBAR_CONFIG"; then
        sed -i '/"modules-right": \[/,/\]/ { /\[/ a\    "custom/screens",
        }' "$WAYBAR_CONFIG"
        info "Added custom/screens to modules-right"
    fi

    # Inject module definition before the closing }
    if ! grep -q '"custom/screens"' "$WAYBAR_CONFIG" || ! grep -q '"exec": "hypr-screens waybar"' "$WAYBAR_CONFIG"; then
        sed -i '/^}$/i\  ,"custom/screens": {\n    "exec": "hypr-screens waybar",\n    "return-type": "json",\n    "interval": 5,\n    "signal": 12,\n    "on-click": "hypr-screens menu",\n    "on-click-right": "hypr-screens only",\n    "on-click-middle": "hypr-screens all"\n  }' "$WAYBAR_CONFIG"
    fi
    ok "Waybar module added"
fi

# --- 3. Patch Waybar CSS ---
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
if [ -f "$WAYBAR_STYLE" ] && grep -q '#custom-screens' "$WAYBAR_STYLE"; then
    warn "Waybar CSS already patched, skipping"
else
    info "Patching $WAYBAR_STYLE"
    backup "$WAYBAR_STYLE"
    {
        echo ""
        echo "$MARKER"
        echo "#custom-screens {"
        echo "  min-width: 12px;"
        echo "  margin: 0 7.5px;"
        echo "}"
        echo ""
        echo "#custom-screens.focus {"
        echo "  color: #a5b5dd;"
        echo "}"
        echo "$MARKER_END"
    } >> "$WAYBAR_STYLE"
    ok "Waybar CSS patched"
fi

# --- 4. Restart waybar ---
if command -v omarchy-restart-waybar &>/dev/null; then
    info "Restarting waybar..."
    omarchy-restart-waybar
elif command -v killall &>/dev/null; then
    killall waybar 2>/dev/null; waybar &disown
fi

echo ""
ok "hypr-screens installed!"
echo ""
echo "  Waybar (click the monitor indicator):"
echo "    Click        Toggle individual monitors"
echo "    Right-click  Keep only one monitor (picker)"
echo "    Middle-click Enable all monitors"
