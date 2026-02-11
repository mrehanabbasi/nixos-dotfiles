# Waybar Notifications with SwayNC

## Summary

Add a modern notification system using SwayNC (Sway Notification Center) with Catppuccin Mocha theming. The notification bell icon in waybar will show all notifications in a dropdown when clicked.

## Current State

- **Waybar**: Has a `custom/notification` module (lines 244-262 in `waybar/default.nix`) that calls `swaync-client` commands, but swaync is not installed
- **Notification daemon**: None installed (no dunst, mako, or swaync)
- **Icon position**: Notification icon is already positioned before the power button in `modules-right`

## Why SwayNC over dunst/mako

1. **Native notification center dropdown** - exactly matches the requirement for "dropdown showing all notifications"
2. **Already partially configured** - waybar module exists, just needs the daemon
3. **Built-in Catppuccin support** - via catppuccin/nix flake (already in use)
4. **Modern Wayland-native** - designed for compositors like Hyprland

## Changes Required

### 1. Create swaync module

**File**: `modules/desktop/swaync/default.nix`

Create a new Home Manager module that:

- Enables `services.swaync`
- Configures Catppuccin Mocha theming via `catppuccin.swaync.enable = true`
- Sets notification center position (right, top)
- Configures widgets (title, dnd, notifications, mpris, volume)
- Uses JetBrainsMono Nerd Font

### 2. Update waybar notification icons

**File**: `modules/desktop/waybar/default.nix` (lines 244-262)

Change `format-icons` to use the requested icons:

- `󰂚` for no notifications
- `󱅫` for has notifications

Current uses red dot indicator (`<span foreground='red'><sup></sup></span>`), replace with cleaner icon-based approach.

### 3. Import swaync in user config

**File**: `modules/users/rehan/default.nix`

Add before waybar import (line 46):

```nix
inputs.self.modules.homeManager.swaync
```

### 4. Add swaync to Hyprland autostart

**File**: `modules/desktop/hyprland/default.nix` (line 60-64)

Add `"swaync"` to `exec-once` list.

### 5. Optional: Add keyboard shortcut

**File**: `modules/desktop/hyprland/default.nix`

Add binding to toggle notification center:

```nix
"$mainMod, N, exec, swaync-client -t -sw"
```

## Files to Modify

| File | Action |
|------|--------|
| `modules/desktop/swaync/default.nix` | Create new |
| `modules/desktop/waybar/default.nix` | Edit icons (lines 246-254) |
| `modules/users/rehan/default.nix` | Add import (after line 46) |
| `modules/desktop/hyprland/default.nix` | Add autostart (line 60-64) |

## Implementation Details

### swaync module structure

```nix
# SwayNC notification center with Catppuccin theming
_:

{
  flake.modules.homeManager.swaync = _: {
    catppuccin.swaync = {
      enable = true;
      flavor = "mocha";
    };

    services.swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "top";
        control-center-width = 400;
        notification-window-width = 400;
        layer = "overlay";
        timeout = 5;
        timeout-low = 3;
        timeout-critical = 0;
        transition-time = 200;
        hide-on-action = true;
        widgets = [ "title" "dnd" "notifications" "mpris" ];
        widget-config = {
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = "Clear All";
          };
          dnd = { text = "Do Not Disturb"; };
        };
      };
    };
  };
}
```

### Updated waybar icons

```nix
"custom/notification" = {
  format = "{icon}";
  format-icons = {
    notification = "󱅫";
    none = "󰂚";
    dnd-notification = "󱅫";
    dnd-none = "󰂛";
    inhibited-notification = "󱅫";
    inhibited-none = "󰂚";
    dnd-inhibited-notification = "󱅫";
    dnd-inhibited-none = "󰂛";
  };
  return-type = "json";
  exec = "swaync-client -swb";
  on-click = "swaync-client -t -sw";
  on-click-right = "swaync-client -d -sw";
  escape = true;
  tooltip = false;
};
```

## Verification

1. Build validation:

   ```bash
   sudo nixos-rebuild build --flake .#one-piece
   ```

2. After applying (user runs switch):

   ```bash
   # Test notification
   notify-send "Test" "Notification system working"

   # Check swaync running
   pgrep swaync

   # Toggle notification center
   swaync-client -t
   ```

3. Verify waybar integration:
   - Bell icon shows 󰂚 when no notifications
   - Bell icon changes to 󱅫 when notifications arrive
   - Click bell to open notification center dropdown
   - Right-click to toggle Do Not Disturb mode
