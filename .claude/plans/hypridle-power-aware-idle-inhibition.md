# Hypridle Power-Aware Configuration with Comprehensive Idle Inhibition

## Overview

Implement power-state-aware idle timeouts for hypridle with comprehensive inhibitor rules for video playback, video calls, and audio activity.

## Requirements

### Power-State Timeouts

| State | Lock Screen | Display Off | Suspend |
|-------|-------------|-------------|---------|
| AC Power | 5 minutes | 10 minutes | Never |
| Battery | 3 minutes | 7 minutes | 10 minutes |

### Inhibitor Rules (Prevent Idle When...)

- Watching video (local players: mpv, VLC, Celluloid)
- Watching video in browser (YouTube, Netflix, etc.)
- On video calls (Zoom, Google Meet, MS Teams, Discord, Slack)
- Audio playing (music, podcasts)
- Manual override (presentation mode)

## Technical Approach

Hypridle does **not natively support** conditional timeouts based on power state. Solution: Multiple config files with a systemd service that monitors power state and switches configs.

## Files to Create

### 1. `modules/services/idle-inhibit-media.nix`

New module for PipeWire-based camera/microphone detection using `wayland-pipewire-idle-inhibit`.

```nix
# PipeWire-based idle inhibition for video calls and audio playback
_:

{
  flake.modules.homeManager.idle-inhibit-media = { pkgs, ... }: {
    home.packages = [ pkgs.wayland-pipewire-idle-inhibit ];

    xdg.configFile."wayland-pipewire-idle-inhibit/config.toml".text = ''
      [media_class]
      "Audio/Source" = ["idle"]  # Microphone
      "Video/Source" = ["idle"]  # Camera
      "Stream/Output/Audio" = ["idle"]  # Audio playback
    '';

    systemd.user.services.wayland-pipewire-idle-inhibit = {
      Unit = {
        Description = "Inhibit idle when camera/microphone/audio is active";
        After = [ "pipewire.service" "wireplumber.service" "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wayland-pipewire-idle-inhibit}/bin/wayland-pipewire-idle-inhibit";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
```

## Files to Modify

### 2. `modules/desktop/hypridle/default.nix`

Complete rewrite with:
- Two config files (AC and battery)
- Power monitor systemd service
- Explicit inhibitor settings

```nix
# Hypridle with power-state-aware timeouts
{ inputs, ... }:

{
  flake.modules.homeManager.hypridle = { config, pkgs, lib, ... }:
  let
    generalSettings = ''
      general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
      }
    '';

    acConfig = generalSettings + ''
      listener {
        timeout = 300
        on-timeout = loginctl lock-session
      }
      listener {
        timeout = 600
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
      }
    '';

    batteryConfig = generalSettings + ''
      listener {
        timeout = 180
        on-timeout = loginctl lock-session
      }
      listener {
        timeout = 420
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
      }
      listener {
        timeout = 600
        on-timeout = systemctl suspend
      }
    '';
  in {
    services.hypridle.enable = false;  # Managed manually

    xdg.configFile = {
      "hypr/hypridle-ac.conf".text = acConfig;
      "hypr/hypridle-battery.conf".text = batteryConfig;
    };

    systemd.user.services.hypridle-power-monitor = {
      Unit = {
        Description = "Monitor power state and switch hypridle config";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = pkgs.writeShellScript "hypridle-power-monitor" ''
          CONFIG_DIR="${config.xdg.configHome}/hypr"
          LAST_STATE=""

          get_power_state() {
            for ac in /sys/class/power_supply/AC /sys/class/power_supply/ACAD /sys/class/power_supply/ADP*; do
              [[ -f "$ac/online" ]] && cat "$ac/online" && return
            done
            echo "1"  # Default to AC
          }

          restart_hypridle() {
            ${pkgs.procps}/bin/pkill -x hypridle || true
            sleep 0.3
            ${pkgs.hypridle}/bin/hypridle -c "$1" &
          }

          CURRENT=$(get_power_state)
          LAST_STATE=$CURRENT
          [[ "$CURRENT" == "1" ]] && restart_hypridle "$CONFIG_DIR/hypridle-ac.conf" \
                                  || restart_hypridle "$CONFIG_DIR/hypridle-battery.conf"

          while true; do
            sleep 5
            CURRENT=$(get_power_state)
            if [[ "$CURRENT" != "$LAST_STATE" ]]; then
              LAST_STATE=$CURRENT
              [[ "$CURRENT" == "1" ]] && restart_hypridle "$CONFIG_DIR/hypridle-ac.conf" \
                                      || restart_hypridle "$CONFIG_DIR/hypridle-battery.conf"
            fi
          done
        '';
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
```

### 3. `modules/desktop/hyprland/default.nix`

Changes:
1. Remove `hypridle` from `exec-once` (systemd manages it now)
2. Add `idleinhibit` window rules for video conferencing apps

```nix
# Remove from exec-once:
# "hyprpaper & hypridle"  →  "hyprpaper"

# Add to windowrulev2:
windowrulev2 = [
  # Video conferencing - inhibit idle when focused
  "idleinhibit focus, class:^(zoom|Zoom)$"
  "idleinhibit focus, class:^(WebCord)$"
  "idleinhibit focus, class:^(discord|Discord)$"
  "idleinhibit focus, class:^(Slack|slack)$"
  "idleinhibit focus, class:^(teams-for-linux|Microsoft Teams)$"

  # Browser-based meetings (title matching)
  "idleinhibit focus, title:(Google Meet)"
  "idleinhibit focus, title:(Microsoft Teams)"
  "idleinhibit focus, title:(Zoom Meeting)"
];
```

### 4. `modules/desktop/waybar/default.nix`

Add manual idle inhibitor toggle module:

```nix
# Add to modules-right (near tray):
modules-right = [ ... "idle_inhibitor" "tray" ... ];

# Add module config:
"idle_inhibitor" = {
  format = "{icon}";
  format-icons = {
    activated = "󰅶";
    deactivated = "󰾪";
  };
  tooltip-format-activated = "Idle inhibited (presentation mode)";
  tooltip-format-deactivated = "Idle enabled";
};
```

### 5. `modules/users/rehan/default.nix`

Add import for new module:

```nix
imports = [
  # ... existing imports
  inputs.self.modules.homeManager.idle-inhibit-media
];
```

## Inhibitor Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: Manual Toggle (Waybar idle_inhibitor)              │
├─────────────────────────────────────────────────────────────┤
│ Layer 3: PipeWire Detection (wayland-pipewire-idle-inhibit) │
│          → Camera, microphone, audio playback               │
├─────────────────────────────────────────────────────────────┤
│ Layer 2: Hyprland Window Rules (idleinhibit focus)          │
│          → Zoom, Teams, Meet, Discord, Slack                │
├─────────────────────────────────────────────────────────────┤
│ Layer 1: Default Protocol Support                           │
│          → Video players, browsers (Wayland + D-Bus)        │
├─────────────────────────────────────────────────────────────┤
│ Base: Power-Aware Hypridle (AC vs Battery configs)          │
│       → hypridle-power-monitor.service                      │
└─────────────────────────────────────────────────────────────┘
```

## Verification

### Build Test
```bash
sudo nixos-rebuild build --flake .#one-piece
```

### After Applying (User Runs Switch)

1. **Check services are running:**
   ```bash
   systemctl --user status hypridle-power-monitor
   systemctl --user status wayland-pipewire-idle-inhibit
   ```

2. **Test power state switching:**
   ```bash
   # Unplug charger, wait 5s, check config
   pgrep -a hypridle  # Should show hypridle-battery.conf
   # Plug in charger, wait 5s, check again
   pgrep -a hypridle  # Should show hypridle-ac.conf
   ```

3. **Test video playback inhibition:**
   ```bash
   # Play video in mpv, wait >5 minutes
   # Screen should NOT lock
   ```

4. **Test video call inhibition:**
   ```bash
   # Join Zoom/Meet call with camera/mic
   systemd-inhibit --list  # Should show wayland-pipewire-idle-inhibit
   ```

5. **Test Waybar toggle:**
   - Click idle inhibitor icon in Waybar
   - Icon should change, `systemd-inhibit --list` should show manual inhibitor
