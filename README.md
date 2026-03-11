# hypr-screens

Monitor toggle for Hyprland + Waybar. Quickly disable/enable individual monitors for focus mode or different desk setups.

## How it works

A waybar module shows active monitors (e.g., `󰍹 3/3`). Click to toggle individual screens, right-click to keep only one, middle-click to enable all.

Any monitor can be toggled — including the laptop screen. A safety check prevents disabling the last active monitor.

## Requirements

- [Hyprland](https://hyprland.org/)
- [Waybar](https://github.com/Alexays/Waybar)
- [Walker](https://github.com/abenz1267/walker) (for picker dialogs)
- `jq`

Works great with [Omarchy](https://omarchy.org/).

## Install

```bash
git clone https://github.com/Eiley2/hypr-screens.git
cd hypr-screens
bash install.sh
```

## Uninstall

```bash
cd hypr-screens
bash uninstall.sh
```

## Waybar interactions

| Action | Effect |
|--------|--------|
| Click | Toggle individual monitors on/off |
| Right-click | Keep only one monitor (picker) |
| Middle-click | Enable all monitors |

## CLI usage

```bash
hypr-screens toggle DP-1     # Toggle a specific monitor
hypr-screens solo             # Laptop only (disable externals)
hypr-screens only             # Pick one monitor to keep (walker)
hypr-screens only DP-1        # Keep only DP-1
hypr-screens all              # Enable all monitors
hypr-screens menu             # Walker menu to toggle monitors
```

## How it reads monitor config

The script reads `~/.config/hypr/monitors.conf` to know the original resolution, refresh rate, and position for each monitor. When re-enabling a disabled monitor, it restores the exact config from that file.

## License

MIT
