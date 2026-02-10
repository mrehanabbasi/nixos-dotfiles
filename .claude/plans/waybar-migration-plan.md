# Waybar Migration Plan: Replacing Hyprpanel with Waybar + Elephant Menus

**Project**: nixos-dotfiles
**Host**: one-piece
**Date**: 2026-02-07
**Status**: Planning Phase

---

## Executive Summary

This document outlines a comprehensive migration plan to replace Hyprpanel (AGS-based panel) with Waybar (a native Wayland bar) while preserving the existing Catppuccin Mocha Blue theming and enhancing functionality with Elephant menu integration through Walker.

**Key Benefits**:
- Native Wayland performance (vs. AGS JavaScript overhead)
- Declarative NixOS configuration (vs. imperative AGS config)
- Built-in Catppuccin support through nixpkgs
- Seamless integration with existing Walker/Elephant setup
- Reduced system dependencies (no AGS, libgtop, gtksourceview required)

**Migration Scope**:
- Remove Hyprpanel and AGS dependencies
- Create new Waybar module with feature parity
- Integrate Walker as application launcher (already configured)
- Apply Catppuccin theming via Home Manager
- Update Hyprland keybindings and autostart
- Implement system tray, workspaces, system monitors
- Add power menu integration via hyprshutdown

---

## Current State Analysis

### Existing Hyprpanel Setup

**Location**: `/home/rehan/nixos-dotfiles/modules/desktop/hyprland/default.nix`

**Current Dependencies** (lines 28-35):
```nix
# HyprPanel dependencies
ags
libgtop
bluez
bluez-tools
gtksourceview
libsoup_3
```

**Current Autostart** (line 66):
```nix
exec-once = [
  "hyprpanel & hyprpaper & hypridle"
  # ... other commands
];
```

**Current Keybindings** (lines 196-197):
```nix
"$mainMod, N, exec, hyprpanel toggleWindow notificationsmenu"
"$mainMod SHIFT, N, exec, hyprpanel clearNotifications"
```

**Features Currently Provided by Hyprpanel**:
1. System tray with application indicators
2. Workspace indicators with multi-monitor support
3. Clock/date display
4. System resource monitors (CPU, RAM, temp)
5. Network status (WiFi/Ethernet)
6. Bluetooth status
7. Volume/audio controls
8. Battery indicator
9. Notification center (SUPER+N)
10. Custom styling via AGS/CSS

### Existing Walker/Elephant Integration

**Location**: `/home/rehan/nixos-dotfiles/modules/desktop/walker/default.nix`

**Key Configuration**:
- Already running as a service (`runAsService = true`)
- Catppuccin Mocha theme implemented
- Elephant provider configured for web search
- Keybindings: SUPER+Space (line 59 in hyprland config)

**Walker Providers Available**:
- Applications (default)
- Web search (prefix: `+`)
- Provider list (prefix: `;`)
- Calculator (prefix: `=`)
- Files (prefix: `/`)
- Clipboard (prefix: `:`)
- Symbols (prefix: `.`)

### Existing Catppuccin Theming

**Location**: `/home/rehan/nixos-dotfiles/modules/theming/catppuccin.nix`

**Current Settings** (lines 18-29):
```nix
catppuccin = {
  accent = "blue";
  flavor = "mocha";
  kvantum = { enable = true; apply = true; };
  cursors.enable = true;
  mpv.enable = true;
  lazygit.enable = true;
  eza.enable = true;
};
```

**System-wide Theme**: Catppuccin Mocha with Blue accent (consistent with Walker)

---

## Key Findings from Analysis Agents

### Agent 1: Hyprpanel Analysis
- **Discovery**: Hyprpanel uses AGS (Aylur's GTK Shell) with JavaScript configuration
- **Impact**: AGS adds 4 additional system dependencies (libgtop, gtksourceview, etc.)
- **Recommendation**: Direct removal safe after Waybar is configured
- **Risk**: Notification keybindings (SUPER+N) will break without replacement

### Agent 2: Waybar Configuration Structure
- **Discovery**: Waybar uses JSON for config, CSS for styling
- **Best Practice**: Use Home Manager's `programs.waybar` module for declarative config
- **Feature Parity**: All Hyprpanel features reproducible in Waybar
- **Advantage**: Waybar has native Catppuccin support in nixpkgs

### Agent 3: Elephant Menu Integration
- **Critical Finding**: "Elephant" is the backend provider system for Walker
- **Current Status**: Already fully integrated via Walker configuration
- **No Action Required**: Elephant menus already work via Walker's web search provider
- **Enhancement Opportunity**: Can expose more Elephant providers through Walker

### Agent 4: Catppuccin Theming
- **Discovery**: Home Manager has built-in Waybar Catppuccin support
- **Integration**: `catppuccin.waybar.enable = true;` applies theme automatically
- **Consistency**: Will match existing Mocha Blue accent across system
- **Simplification**: No manual CSS color definitions needed

---

## Implementation Phases

### Phase 1: Waybar Module Creation

**Objective**: Create a new Waybar module with feature parity to Hyprpanel

**Steps**:

1. Create module file: `/home/rehan/nixos-dotfiles/modules/desktop/waybar/default.nix`

2. Define module structure:
   ```nix
   # Waybar - Wayland status bar with Catppuccin theming
   # Replaces: Hyprpanel (AGS-based)
   _:

   {
     flake.modules.homeManager.waybar = { pkgs, ... }: {
       programs.waybar = {
         enable = true;
         systemd.enable = true;  # Run as systemd service

         settings = {
           mainBar = {
             # Configuration here
           };
         };

         style = ''
           /* Catppuccin theming applied via catppuccin.waybar.enable */
         '';
       };
     };
   }
   ```

3. Configure bar layout:
   - Position: Top
   - Height: 32px (similar to Hyprpanel)
   - Layer: Top (overlay windows)
   - Multi-monitor support: Use output configuration

4. Implement core modules:
   ```nix
   modules-left = [ "hyprland/workspaces" "hyprland/window" ];
   modules-center = [ "clock" ];
   modules-right = [
     "tray"
     "cpu"
     "memory"
     "temperature"
     "network"
     "bluetooth"
     "pulseaudio"
     "battery"
   ];
   ```

5. Configure workspace module:
   ```nix
   "hyprland/workspaces" = {
     format = "{icon}";
     on-click = "activate";
     format-icons = {
       "1" = "1";
       "2" = "2";
       "3" = "3";
       "4" = "4";
       "5" = "5";
       "6" = "6";
       "7" = "7";
       "8" = "8";
       "9" = "9";
       "10" = "10";
     };
     persistent-workspaces = {
       "*" = 10;  # Show 10 workspaces on all monitors
     };
   };
   ```

6. Configure system monitors:
   ```nix
   cpu = {
     format = " {usage}%";
     interval = 2;
     on-click = "ghostty --title='btop' -e btop";
   };

   memory = {
     format = " {percentage}%";
     interval = 2;
     on-click = "ghostty --title='btop' -e btop";
   };

   temperature = {
     format = " {temperatureC}°C";
     interval = 2;
     critical-threshold = 80;
     format-critical = " {temperatureC}°C";
   };
   ```

7. Configure network module:
   ```nix
   network = {
     format-wifi = " {essid} ({signalStrength}%)";
     format-ethernet = " {ifname}";
     format-disconnected = "⚠ Disconnected";
     on-click = "ghostty --title='nmtui' -e nmtui";
     tooltip-format = "{ifname}: {ipaddr}/{cidr}";
   };
   ```

8. Configure Bluetooth module:
   ```nix
   bluetooth = {
     format = " {status}";
     format-connected = " {device_alias}";
     format-connected-battery = " {device_alias} {device_battery_percentage}%";
     on-click = "blueberry";
     tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
   };
   ```

9. Configure audio module:
   ```nix
   pulseaudio = {
     format = "{icon} {volume}%";
     format-bluetooth = "{icon} {volume}%";
     format-muted = " Muted";
     format-icons = {
       headphone = "";
       hands-free = "";
       headset = "";
       phone = "";
       portable = "";
       car = "";
       default = [ "" "" "" ];
     };
     on-click = "pavucontrol";
     scroll-step = 5;
   };
   ```

10. Configure battery module:
    ```nix
    battery = {
      states = {
        warning = 30;
        critical = 15;
      };
      format = "{icon} {capacity}%";
      format-charging = " {capacity}%";
      format-plugged = " {capacity}%";
      format-icons = [ "" "" "" "" "" ];
      tooltip-format = "{timeTo}, {capacity}%";
    };
    ```

11. Configure clock module:
    ```nix
    clock = {
      format = " {:%H:%M   %a %b %d}";
      tooltip-format = "<tt><small>{calendar}</small></tt>";
      calendar = {
        mode = "month";
        format = {
          months = "<span color='#89b4fa'><b>{}</b></span>";
          days = "<span color='#cdd6f4'>{}</span>";
          weeks = "<span color='#74c7ec'><b>W{}</b></span>";
          weekdays = "<span color='#f9e2af'><b>{}</b></span>";
          today = "<span color='#f38ba8'><b><u>{}</u></b></span>";
        };
      };
    };
    ```

12. Configure system tray:
    ```nix
    tray = {
      icon-size = 18;
      spacing = 8;
    };
    ```

**Files to Create**:
- `/home/rehan/nixos-dotfiles/modules/desktop/waybar/default.nix`

**Files to Modify**:
- None yet (Phase 2)

---

### Phase 2: Catppuccin Theme Integration

**Objective**: Apply Catppuccin Mocha Blue theme to Waybar matching system theme

**Steps**:

1. Update theming module: `/home/rehan/nixos-dotfiles/modules/theming/catppuccin.nix`

2. Add Waybar theme enablement:
   ```nix
   flake.modules.homeManager.catppuccin = { config, pkgs, lib, ... }: {
     catppuccin = {
       accent = "blue";
       flavor = "mocha";
       kvantum = { enable = true; apply = true; };
       cursors.enable = true;
       mpv.enable = true;
       lazygit.enable = true;
       eza.enable = true;

       # Add Waybar theming
       waybar.enable = true;
     };
   };
   ```

3. Optional custom CSS overrides in Waybar module:
   ```nix
   style = ''
     /* Base theme provided by catppuccin module */
     /* Custom overrides only if needed */

     * {
       font-family: "JetBrainsMono Nerd Font";
       font-size: 13px;
     }

     window#waybar {
       background-color: rgba(30, 30, 46, 0.95);  /* base with transparency */
       border-bottom: 2px solid #89b4fa;  /* blue accent border */
     }

     #workspaces button.active {
       background-color: #89b4fa;  /* blue accent */
       color: #1e1e2e;  /* base for contrast */
     }
   '';
   ```

4. Verify color consistency:
   - Base: #1e1e2e (Mocha base)
   - Text: #cdd6f4 (Mocha text)
   - Blue: #89b4fa (Mocha blue)
   - Red: #f38ba8 (Mocha red - for critical states)
   - Green: #a6e3a1 (Mocha green - for success states)
   - Yellow: #f9e2af (Mocha yellow - for warnings)

**Files to Modify**:
- `/home/rehan/nixos-dotfiles/modules/theming/catppuccin.nix`

**Optional: GTK Theme Alignment**

Current system uses Tokyonight-Dark GTK theme. For complete Catppuccin consistency:

1. **Option A: Keep Tokyonight-Dark** (STRONGLY RECOMMENDED)
   - No changes needed
   - Both are dark themes with similar aesthetics
   - Tokyonight is actively maintained
   - No risk of GTK theming issues
   - Visual consistency is already excellent

2. **Option B: DO NOT USE - catppuccin-nix GTK module was removed**
   - The catppuccin-nix flake REMOVED its GTK module as of recent updates
   - All GTK options (enable, flavor, accent, size, tweaks) have been marked as removed
   - Reason: "upstream port has been archived and began experiencing breakages"
   - Only icon theme support remains (via catppuccin.icon.enable)

**CRITICAL FINDING**: Investigation of catppuccin-nix repository reveals:

1. **catppuccin-nix GTK module status** (as of February 2026):
   - Source: https://github.com/catppuccin/nix/blob/main/modules/home-manager/gtk.nix
   - ALL GTK theme options have been removed with `mkRemovedOptionModule`
   - Removal message: "catppuccin/gtk was removed from catppuccin/nix, as the upstream port has been archived and began experiencing breakages"
   - References issue: https://github.com/catppuccin/gtk/issues/262
   - ONLY icon theme support remains (Papirus icon folders with Catppuccin colors)

2. **catppuccin/gtk repository status**:
   - Archived: June 2, 2024 (read-only)
   - Last release: v1.0.3 (June 1, 2024)
   - Reason: "GTK, while being one of our most popular ports, can only be described as a nightmare to consistently theme and maintain"
   - Each Linux distribution has implementation-specific GTK behaviors causing breakages
   - GNOME officially discourages custom theming (no official theming API)

3. **nixpkgs catppuccin-gtk package**:
   - Location: https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/themes/catppuccin-gtk/default.nix
   - Version: 0.4.1 (frozen, no longer updated)
   - Sources from: Archived catppuccin/gtk repository (owner: "catppuccin", repo: "gtk")
   - This is a FROZEN package wrapping the archived repository

**VERDICT**: The catppuccin-nix GTK integration was just a wrapper around the frozen/archived catppuccin-gtk package. It has been completely removed from catppuccin-nix due to ongoing breakages. The nixpkgs package still exists but is frozen at v0.4.1 and sources from the archived repository.

**RECOMMENDATION**: Keep Tokyonight-Dark GTK theme. The Catppuccin GTK theme is:
- No longer supported by catppuccin-nix (removed entirely)
- Based on an archived upstream repository
- Known to cause distribution-specific breakages
- Officially discouraged by GNOME developers

The visual difference between Tokyonight-Dark and Catppuccin is minimal, and both provide excellent dark mode support with similar color palettes.

---

### Phase 3: Host Integration

**Objective**: Add Waybar module to host configuration and update module loading order

**Steps**:

1. Update host definition: `/home/rehan/nixos-dotfiles/modules/hosts/one-piece/default.nix`

2. Add Waybar to Desktop layer (after hyprland, before programs):
   ```nix
   # LAYER 6: Desktop & Programs
   inputs.self.modules.nixos.hyprland
   inputs.self.modules.nixos.waybar        # ADD THIS LINE
   inputs.self.modules.nixos.sddm
   inputs.self.modules.nixos.browsers
   # ... rest of modules
   ```

3. Verify module loading order:
   - Catppuccin (Layer 4) loads before Waybar (Layer 6)
   - Ensures theme options are available when Waybar configures

**Files to Modify**:
- `/home/rehan/nixos-dotfiles/modules/hosts/one-piece/default.nix` (add line after hyprland module)

---

### Phase 4: Hyprland Configuration Updates

**Objective**: Update Hyprland to launch Waybar and remove Hyprpanel keybindings

**Steps**:

1. Update autostart in `/home/rehan/nixos-dotfiles/modules/desktop/hyprland/default.nix`:
   ```nix
   # OLD (line 66):
   exec-once = [
     "hyprpanel & hyprpaper & hypridle"
     "hyprctl setcursor $cursorTheme $cursorSize"
     "kdeconnectd & kdeconnect-indicator &"
   ];

   # NEW:
   exec-once = [
     "hyprpaper & hypridle"  # Remove hyprpanel, Waybar starts via systemd
     "hyprctl setcursor $cursorTheme $cursorSize"
     "kdeconnectd & kdeconnect-indicator &"
   ];
   ```

2. Remove or update notification keybindings (lines 196-197):
   ```nix
   # OLD:
   "$mainMod, N, exec, hyprpanel toggleWindow notificationsmenu"
   "$mainMod SHIFT, N, exec, hyprpanel clearNotifications"

   # NEW - Option 1: Remove entirely (Waybar doesn't have notification center)
   # (Delete these lines)

   # NEW - Option 2: Replace with mako/dunst notification manager
   "$mainMod, N, exec, makoctl restore"
   "$mainMod SHIFT, N, exec, makoctl dismiss --all"
   ```

3. Optional: Add power menu keybinding for hyprshutdown:
   ```nix
   "$mainMod SHIFT, Q, exec, hyprshutdown"
   ```

4. Note: Keep Walker keybinding unchanged:
   ```nix
   "$mainMod, Space, exec, $menu"  # Already configured for Walker
   ```

**Files to Modify**:
- `/home/rehan/nixos-dotfiles/modules/desktop/hyprland/default.nix` (lines 66, 196-197)

---

### Phase 5: Dependency Cleanup

**Objective**: Remove Hyprpanel and AGS dependencies from system packages

**Steps**:

1. Update NixOS packages in `/home/rehan/nixos-dotfiles/modules/desktop/hyprland/default.nix`:
   ```nix
   # OLD (lines 20-35):
   environment.systemPackages = with pkgs; [
     inputs.hyprshutdown.packages.${pkgs.stdenv.hostPlatform.system}.hyprshutdown
     hyprpaper
     hyprshot
     hyprpicker
     hyprpanel        # REMOVE
     wl-clipboard

     # HyprPanel dependencies  # REMOVE ALL THESE
     ags
     libgtop
     bluez
     bluez-tools
     gtksourceview
     libsoup_3
   ];

   # NEW:
   environment.systemPackages = with pkgs; [
     inputs.hyprshutdown.packages.${pkgs.stdenv.hostPlatform.system}.hyprshutdown
     hyprpaper
     hyprshot
     hyprpicker
     wl-clipboard

     # Waybar dependencies (managed by Home Manager, but useful system-wide)
     # Note: bluez already enabled via _bluetooth.nix
     pavucontrol     # Audio control GUI (for pulseaudio module click action)
     blueberry       # Bluetooth manager GUI (for bluetooth module click action)
   ];
   ```

2. Verify Bluetooth is still enabled:
   - Check `/home/rehan/nixos-dotfiles/modules/hosts/one-piece/_bluetooth.nix` exists and is imported
   - `bluez` service should be enabled there, not as a package here

3. Optional: Add notification daemon if notification keybindings desired
   - Option A: mako (lightweight Wayland notification daemon)
   - Option B: dunst (feature-rich notification daemon)
   - Add to desktop layer in host config

**Files to Modify**:
- `/home/rehan/nixos-dotfiles/modules/desktop/hyprland/default.nix` (lines 20-35)

---

### Phase 6: Optional Enhancements

**Objective**: Add additional functionality beyond Hyprpanel parity

**Enhancement 1: Power Menu Module**

Add custom power menu to Waybar:

```nix
"custom/power" = {
  format = "";
  on-click = "hyprshutdown";
  tooltip = false;
};
```

Add to modules-right in Waybar config.

**Enhancement 2: Media Player Controls**

Add playerctl integration:

```nix
"custom/media" = {
  format = "{icon} {}";
  return-type = "json";
  max-length = 40;
  format-icons = {
    spotify = "";
    default = "🎵";
  };
  escape = true;
  exec = "${pkgs.waybar}/bin/waybar-media-player.py 2> /dev/null";
  on-click = "playerctl play-pause";
};
```

Create `/home/rehan/nixos-dotfiles/modules/desktop/waybar/waybar-media-player.py`:
```python
#!/usr/bin/env python3
import json
import subprocess

def get_player_status():
    try:
        status = subprocess.check_output(
            ["playerctl", "status"],
            stderr=subprocess.DEVNULL
        ).decode().strip()

        metadata = subprocess.check_output(
            ["playerctl", "metadata", "--format", "{{artist}} - {{title}}"],
            stderr=subprocess.DEVNULL
        ).decode().strip()

        player = subprocess.check_output(
            ["playerctl", "metadata", "--format", "{{playerName}}"],
            stderr=subprocess.DEVNULL
        ).decode().strip()

        return {
            "text": metadata,
            "class": status.lower(),
            "alt": player
        }
    except:
        return {"text": "", "class": "stopped"}

if __name__ == "__main__":
    print(json.dumps(get_player_status()))
```

**Enhancement 3: Workspace Icons**

Customize workspace icons for better visual identification:

```nix
"hyprland/workspaces" = {
  format = "{icon}";
  on-click = "activate";
  format-icons = {
    "1" = "";    # Browser
    "2" = "";    # Code
    "3" = "";    # Terminal
    "4" = "";    # Files
    "5" = "";    # Communication
    "6" = "";    # Media
    "7" = "7";
    "8" = "8";
    "9" = "9";
    "10" = "";   # Settings
    "urgent" = "";
    "active" = "";
    "default" = "";
  };
};
```

**Enhancement 4: Notification Daemon Integration**

If SUPER+N functionality desired, add mako:

1. Create `/home/rehan/nixos-dotfiles/modules/desktop/mako/default.nix`:
```nix
# Mako - Lightweight notification daemon for Wayland
_:

{
  flake.modules.homeManager.mako = _: {
    services.mako = {
      enable = true;
      defaultTimeout = 5000;
      ignoreTimeout = true;
      layer = "overlay";
      maxVisible = 5;
      sort = "-time";
    };

    catppuccin.mako.enable = true;  # Auto-theme
  };
}
```

2. Add to host config Layer 6
3. Update Hyprland keybindings as noted in Phase 4

**Enhancement 5: Multi-Monitor Workspace Distribution**

Configure workspace distribution across monitors:

```nix
"hyprland/workspaces" = {
  format = "{icon}";
  on-click = "activate";
  format-icons = { /* ... */ };
  persistent-workspaces = {
    "eDP-1" = [ 1 2 3 4 5 ];      # Internal display: workspaces 1-5
    "HDMI-A-1" = [ 6 7 8 9 10 ];  # External display: workspaces 6-10
  };
};
```

Matches existing Hyprland monitor config (lines 50-53).

---

## Configuration Examples

### Complete Waybar Module Example

File: `/home/rehan/nixos-dotfiles/modules/desktop/waybar/default.nix`

```nix
# Waybar - Wayland status bar with Catppuccin theming
# Replaces: Hyprpanel (AGS-based)
# Depends on: catppuccin (for theming)
_:

{
  flake.modules.homeManager.waybar = { pkgs, ... }: {
    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 32;
          spacing = 8;

          modules-left = [ "hyprland/workspaces" "hyprland/window" ];
          modules-center = [ "clock" ];
          modules-right = [
            "tray"
            "cpu"
            "memory"
            "temperature"
            "network"
            "bluetooth"
            "pulseaudio"
            "battery"
            "custom/power"
          ];

          "hyprland/workspaces" = {
            format = "{icon}";
            on-click = "activate";
            format-icons = {
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              "7" = "7";
              "8" = "8";
              "9" = "9";
              "10" = "10";
            };
            persistent-workspaces = {
              "*" = 10;
            };
          };

          "hyprland/window" = {
            format = "{}";
            separate-outputs = true;
            max-length = 50;
            rewrite = {
              "" = "Desktop";
            };
          };

          clock = {
            format = " {:%H:%M   %a %b %d}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "month";
              format = {
                months = "<span color='#89b4fa'><b>{}</b></span>";
                days = "<span color='#cdd6f4'>{}</span>";
                weeks = "<span color='#74c7ec'><b>W{}</b></span>";
                weekdays = "<span color='#f9e2af'><b>{}</b></span>";
                today = "<span color='#f38ba8'><b><u>{}</u></b></span>";
              };
            };
          };

          cpu = {
            format = " {usage}%";
            interval = 2;
            on-click = "ghostty --title='btop' -e btop";
          };

          memory = {
            format = " {percentage}%";
            interval = 2;
            on-click = "ghostty --title='btop' -e btop";
          };

          temperature = {
            format = " {temperatureC}°C";
            interval = 2;
            critical-threshold = 80;
            format-critical = " {temperatureC}°C";
          };

          network = {
            format-wifi = " {essid} ({signalStrength}%)";
            format-ethernet = " {ifname}";
            format-disconnected = "⚠ Disconnected";
            on-click = "ghostty --title='nmtui' -e nmtui";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          };

          bluetooth = {
            format = " {status}";
            format-connected = " {device_alias}";
            format-connected-battery = " {device_alias} {device_battery_percentage}%";
            on-click = "blueberry";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-bluetooth = "{icon} {volume}%";
            format-muted = " Muted";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ "" "" "" ];
            };
            on-click = "pavucontrol";
            scroll-step = 5;
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-plugged = " {capacity}%";
            format-icons = [ "" "" "" "" "" ];
            tooltip-format = "{timeTo}, {capacity}%";
          };

          tray = {
            icon-size = 18;
            spacing = 8;
          };

          "custom/power" = {
            format = "";
            on-click = "hyprshutdown";
            tooltip = false;
          };
        };
      };

      style = ''
        /* Base Catppuccin theme applied via catppuccin.waybar.enable */
        /* Custom overrides */

        * {
          font-family: "JetBrainsMono Nerd Font";
          font-size: 13px;
          border: none;
          border-radius: 0;
          min-height: 0;
        }

        window#waybar {
          background-color: rgba(30, 30, 46, 0.95);
          border-bottom: 2px solid #89b4fa;
          color: #cdd6f4;
        }

        #workspaces button {
          padding: 0 8px;
          color: #cdd6f4;
          background-color: transparent;
          transition: all 0.3s ease;
        }

        #workspaces button.active {
          background-color: #89b4fa;
          color: #1e1e2e;
          border-radius: 4px;
        }

        #workspaces button.urgent {
          background-color: #f38ba8;
          color: #1e1e2e;
          border-radius: 4px;
        }

        #workspaces button:hover {
          background-color: rgba(137, 180, 250, 0.3);
          border-radius: 4px;
        }

        #window {
          color: #89b4fa;
          font-weight: 500;
        }

        #clock {
          color: #cdd6f4;
          font-weight: 500;
        }

        #cpu,
        #memory,
        #temperature,
        #network,
        #bluetooth,
        #pulseaudio,
        #battery,
        #tray {
          padding: 0 8px;
          margin: 0 2px;
        }

        #cpu {
          color: #f9e2af;
        }

        #memory {
          color: #a6e3a1;
        }

        #temperature {
          color: #89dceb;
        }

        #temperature.critical {
          color: #f38ba8;
        }

        #network {
          color: #89b4fa;
        }

        #network.disconnected {
          color: #f38ba8;
        }

        #bluetooth {
          color: #89b4fa;
        }

        #pulseaudio {
          color: #cba6f7;
        }

        #pulseaudio.muted {
          color: #585b70;
        }

        #battery {
          color: #a6e3a1;
        }

        #battery.warning {
          color: #f9e2af;
        }

        #battery.critical {
          color: #f38ba8;
        }

        #battery.charging {
          color: #a6e3a1;
        }

        #custom-power {
          color: #f38ba8;
          padding: 0 8px;
          margin: 0 4px;
        }

        #custom-power:hover {
          background-color: rgba(243, 139, 168, 0.3);
          border-radius: 4px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #f38ba8;
        }
      '';
    };
  };
}
```

### Updated Catppuccin Module Example

File: `/home/rehan/nixos-dotfiles/modules/theming/catppuccin.nix`

```nix
# Catppuccin theming - NixOS and Home Manager
_:

{
  flake.modules.nixos.catppuccin = _: {
    # NixOS-level catppuccin settings are applied via the catppuccin.nixosModules.catppuccin
    # which is imported in the host definition
  };

  flake.modules.homeManager.catppuccin = { config, pkgs, lib, ... }: {
    catppuccin = {
      accent = "blue";
      flavor = "mocha";
      kvantum = {
        enable = true;
        apply = true;
      };
      cursors.enable = true;
      mpv.enable = true;
      lazygit.enable = true;
      eza.enable = true;

      # Waybar theming
      waybar.enable = true;

      # GTK theming: NOT AVAILABLE via catppuccin-nix
      # The GTK module was completely removed from catppuccin-nix due to ongoing
      # breakages after the upstream catppuccin/gtk repository was archived.
      # Keep the existing Tokyonight-Dark GTK theme (modules/theming/gtk.nix)

      # Optional: Icon theme (only icons are still supported)
      # icon = {
      #   enable = true;
      #   accent = "blue";
      # };
    };
  };
}
```

### Updated Hyprland Autostart Example

File: `/home/rehan/nixos-dotfiles/modules/desktop/hyprland/default.nix` (partial)

```nix
# Autostart (updated section)
exec-once = [
  "hyprpaper & hypridle"  # Waybar starts via systemd
  "hyprctl setcursor $cursorTheme $cursorSize"
  "kdeconnectd & kdeconnect-indicator &"
];
```

### Updated Host Configuration Example

File: `/home/rehan/nixos-dotfiles/modules/hosts/one-piece/default.nix` (partial)

```nix
# LAYER 6: Desktop & Programs
inputs.self.modules.nixos.hyprland
inputs.self.modules.nixos.waybar        # NEW
inputs.self.modules.nixos.sddm
inputs.self.modules.nixos.browsers
# ... rest unchanged
```

---

## Testing Strategy

### Pre-Migration Testing

1. **Document Current State**:
   ```bash
   # Screenshot current Hyprpanel
   hyprshot -m output

   # List current processes
   ps aux | grep -E "(hyprpanel|ags)" > /tmp/pre-migration-processes.txt

   # Export current theme
   cat ~/.config/hypr/hyprland.conf > /tmp/pre-migration-hyprland.conf
   ```

2. **Verify Dependencies**:
   ```bash
   nix-store -q --references /run/current-system | grep -E "(ags|hyprpanel)"
   ```

### Build Testing

1. **Initial Build Validation**:
   ```bash
   sudo nixos-rebuild build --flake .#one-piece
   ```

   Expected: Build succeeds with Waybar module added

2. **Check for Errors**:
   ```bash
   nix flake check
   ```

   Expected: No syntax errors in new module

3. **Format Validation**:
   ```bash
   nixfmt modules/desktop/waybar/default.nix
   nixfmt modules/theming/catppuccin.nix
   nixfmt modules/desktop/hyprland/default.nix
   nixfmt modules/hosts/one-piece/default.nix
   ```

### Post-Migration Testing

1. **Visual Testing** (after rebuild):
   - Waybar appears at top of screen
   - Catppuccin Mocha Blue theme applied
   - All modules render correctly
   - Icons display properly (JetBrainsMono Nerd Font)
   - Transparency/blur effects work

2. **Functional Testing**:

   **Workspace Module**:
   - [ ] Click workspace numbers to switch
   - [ ] Active workspace highlighted in blue
   - [ ] Workspaces persist across all monitors
   - [ ] Window titles show in workspace indicator

   **System Monitors**:
   - [ ] CPU percentage updates every 2s
   - [ ] Memory percentage updates every 2s
   - [ ] Temperature shows in Celsius
   - [ ] Temperature turns red above 80°C
   - [ ] Click CPU/Memory opens btop in Ghostty

   **Network Module**:
   - [ ] WiFi shows SSID and signal strength
   - [ ] Ethernet shows interface name
   - [ ] Disconnected state shows warning
   - [ ] Click opens nmtui in Ghostty
   - [ ] Tooltip shows IP address

   **Bluetooth Module**:
   - [ ] Shows connection status
   - [ ] Shows connected device name
   - [ ] Shows battery percentage if available
   - [ ] Click opens blueberry GUI

   **Audio Module**:
   - [ ] Volume percentage displays
   - [ ] Icon changes based on volume level
   - [ ] Muted state displays correctly
   - [ ] Click opens pavucontrol
   - [ ] Scroll adjusts volume

   **Battery Module**:
   - [ ] Battery percentage displays
   - [ ] Charging icon shows when plugged in
   - [ ] Warning state at 30%
   - [ ] Critical state at 15%
   - [ ] Tooltip shows time remaining

   **Clock Module**:
   - [ ] Time displays in 24-hour format
   - [ ] Date shows (Weekday Month Day)
   - [ ] Tooltip shows calendar
   - [ ] Calendar colors match Catppuccin

   **System Tray**:
   - [ ] Application icons appear
   - [ ] Click actions work
   - [ ] Attention state highlights

   **Power Menu** (if implemented):
   - [ ] Click opens hyprshutdown
   - [ ] Logout/suspend/reboot/shutdown options work

3. **Integration Testing**:
   - [ ] Walker (SUPER+Space) still launches
   - [ ] Hyprlock (SUPER+;) still works
   - [ ] Multi-monitor workspace switching works
   - [ ] Workspace movement between monitors (SUPER+Tab) works
   - [ ] All Hyprland keybindings unaffected

4. **Performance Testing**:
   ```bash
   # Check Waybar resource usage
   ps aux | grep waybar

   # Compare to old Hyprpanel usage (from pre-migration capture)
   # Expected: Lower CPU/memory usage than AGS
   ```

5. **Theme Consistency Testing**:
   - [ ] Waybar matches SDDM Catppuccin theme
   - [ ] Waybar matches Walker Catppuccin theme
   - [ ] Waybar matches Hyprlock Catppuccin theme
   - [ ] Blue accent consistent across all applications

### Rollback Testing

1. **Verify Rollback Capability**:
   ```bash
   # List generations
   sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

   # Test rollback to previous generation (if needed)
   sudo nixos-rebuild switch --rollback
   ```

2. **Rollback Procedure** (if issues found):
   - Reboot system
   - Select previous generation from GRUB
   - Log in and verify Hyprpanel works
   - Debug issues in new configuration
   - Re-test build before switching again

---

## Success Criteria

### Must-Have (Blocking)

- [ ] Waybar builds successfully without errors
- [ ] Waybar launches automatically on system start
- [ ] All 10 core modules functional (workspaces, clock, tray, CPU, memory, temp, network, BT, audio, battery)
- [ ] Catppuccin Mocha Blue theme applied correctly
- [ ] No visual regressions (blur, transparency, borders)
- [ ] No broken Hyprland keybindings
- [ ] Walker application launcher unaffected
- [ ] Multi-monitor support works (workspaces, panels)
- [ ] System tray applications appear and function
- [ ] Performance equal or better than Hyprpanel

### Should-Have (Important)

- [ ] Click actions work on all modules
- [ ] Tooltips display relevant information
- [ ] Icon consistency (Nerd Font icons render)
- [ ] Smooth animations/transitions
- [ ] Calendar popup styled correctly
- [ ] Battery states (charging, warning, critical) work
- [ ] Network disconnected state shows correctly
- [ ] Temperature critical threshold works
- [ ] Volume scroll adjustment works

### Nice-to-Have (Optional)

- [ ] Power menu module implemented
- [ ] Media player controls implemented
- [ ] Custom workspace icons
- [ ] Notification daemon (mako) integrated
- [ ] Workspace-per-monitor configuration
- [ ] Additional custom modules

### Quality Criteria

- [ ] Code follows repository style guide (2-space indent, <100 char lines)
- [ ] Module has proper header comment with dependencies
- [ ] All configuration declarative (no imperative scripts)
- [ ] Theme colors defined via Catppuccin module (no hardcoded)
- [ ] No unnecessary dependencies installed
- [ ] Documentation updated (if needed)

---

## Risk Assessment and Mitigation

### High Risk: System Unbootable

**Risk**: Configuration errors prevent system boot

**Likelihood**: Low (Waybar is user-space, not system-critical)

**Mitigation**:
- Always use `sudo nixos-rebuild build` before `switch`
- Test in VM first (optional)
- Keep previous generation in GRUB for rollback
- Never delete previous generations before verifying new config

**Recovery**:
1. Reboot and select previous generation from GRUB
2. Fix configuration errors
3. Re-test build

### Medium Risk: Missing Panel

**Risk**: Waybar fails to start, leaving no status bar

**Likelihood**: Medium (systemd service issues, missing dependencies)

**Mitigation**:
- Set `systemd.enable = true` for automatic service management
- Add fallback keybinding: `$mainMod CTRL, W, exec, waybar` to manually launch
- Test service start before rebooting: `systemctl --user status waybar`

**Recovery**:
1. Launch terminal with SUPER+Return
2. Check service: `systemctl --user status waybar`
3. View logs: `journalctl --user -u waybar`
4. Manual start: `waybar &`
5. Fix configuration based on errors

### Medium Risk: Broken Keybindings

**Risk**: Notification keybindings (SUPER+N) crash or do nothing

**Likelihood**: High (Hyprpanel keybindings removed without replacement)

**Mitigation**:
- Remove keybindings entirely in Phase 4 (clean removal)
- Document removed functionality for user awareness
- Optionally implement mako as replacement

**Recovery**:
- No recovery needed (non-critical functionality)
- Add mako module if notifications needed

### Low Risk: Theme Inconsistency

**Risk**: Waybar theme doesn't match system theme

**Likelihood**: Low (catppuccin module handles this)

**Mitigation**:
- Use `catppuccin.waybar.enable = true` for automatic theming
- Verify color variables match Catppuccin Mocha spec
- Test visually against Walker and Hyprlock

**Recovery**:
1. Check catppuccin module version: `nix flake metadata`
2. Update flake inputs: `nix flake update catppuccin`
3. Add manual CSS overrides if needed

### Low Risk: Performance Degradation

**Risk**: Waybar uses more resources than Hyprpanel

**Likelihood**: Very Low (Waybar is more efficient than AGS)

**Mitigation**:
- Monitor resource usage: `ps aux | grep waybar`
- Compare to Hyprpanel baseline
- Adjust update intervals if needed (cpu/memory interval)

**Recovery**:
- Increase module update intervals (e.g., CPU from 2s to 5s)
- Disable expensive modules (e.g., temperature)
- Revert to Hyprpanel if unacceptable

---

## File Change Summary

### Files to Create

| File | Purpose | Phase |
|------|---------|-------|
| `/home/rehan/nixos-dotfiles/modules/desktop/waybar/default.nix` | Waybar module definition | Phase 1 |

### Files to Modify

| File | Changes | Lines | Phase |
|------|---------|-------|-------|
| `/home/rehan/nixos-dotfiles/modules/theming/catppuccin.nix` | Add `waybar.enable = true` | ~line 28 | Phase 2 |
| `/home/rehan/nixos-dotfiles/modules/hosts/one-piece/default.nix` | Add waybar module import | ~line 50 | Phase 3 |
| `/home/rehan/nixos-dotfiles/modules/desktop/hyprland/default.nix` | Update exec-once, remove packages, update keybindings | lines 20-35, 66, 196-197 | Phase 4, 5 |

### Files to Optionally Create (Enhancements)

| File | Purpose |
|------|---------|
| `/home/rehan/nixos-dotfiles/modules/desktop/mako/default.nix` | Notification daemon (Enhancement 4) |
| `/home/rehan/nixos-dotfiles/modules/desktop/waybar/waybar-media-player.py` | Media controls script (Enhancement 2) |

---

## Implementation Timeline

### Estimated Duration: 2-3 hours

**Phase 1: Waybar Module Creation** (45 minutes)
- Create module file
- Configure all 10 core modules
- Write styling section
- Test build

**Phase 2: Catppuccin Integration** (15 minutes)
- Update theming module
- Verify theme enablement
- Test build

**Phase 3: Host Integration** (10 minutes)
- Add module to host config
- Verify layer ordering
- Test build

**Phase 4: Hyprland Updates** (20 minutes)
- Update autostart
- Remove/update keybindings
- Test build

**Phase 5: Dependency Cleanup** (15 minutes)
- Remove Hyprpanel packages
- Add new dependencies (pavucontrol, blueberry)
- Test build

**Phase 6: Testing** (45 minutes)
- Pre-migration documentation
- Build validation
- Visual testing
- Functional testing (all modules)
- Integration testing
- Performance comparison

**Buffer: Debugging** (30 minutes)
- Address any build errors
- Fix configuration issues
- Resolve theme inconsistencies

---

## Rollback Plan

### Immediate Rollback (GRUB)

If system issues occur after `nixos-rebuild switch`:

1. Reboot system
2. Press any key during GRUB countdown
3. Select "NixOS - All Configurations"
4. Choose previous generation (one before Waybar migration)
5. Boot into previous working state

### Configuration Rollback (Git)

If configuration needs to be reverted:

```bash
# View recent commits
git log --oneline -5

# Identify commit before Waybar migration
# Example: ea83095 feat(hyprland): add explicit multi-monitor configuration

# Revert to that commit
git revert <waybar-migration-commit-sha>

# Or reset (if not pushed)
git reset --hard <commit-before-migration>

# Rebuild with old config
sudo nixos-rebuild build --flake .#one-piece
sudo nixos-rebuild switch --flake .#one-piece
```

### Partial Rollback (Module Disable)

If only Waybar is problematic, keep other changes:

1. Comment out Waybar module in host config:
   ```nix
   # inputs.self.modules.nixos.waybar
   ```

2. Re-enable Hyprpanel in Hyprland config:
   ```nix
   exec-once = [
     "hyprpanel & hyprpaper & hypridle"
     # ...
   ];

   environment.systemPackages = with pkgs; [
     hyprpanel
     ags
     # ... other dependencies
   ];
   ```

3. Rebuild:
   ```bash
   sudo nixos-rebuild build --flake .#one-piece
   sudo nixos-rebuild switch --flake .#one-piece
   ```

---

## Post-Migration Tasks

### Immediate (Day 1)

- [ ] Monitor Waybar stability over first boot cycle
- [ ] Verify all click actions work as expected
- [ ] Check resource usage vs. Hyprpanel baseline
- [ ] Test with all regular applications
- [ ] Verify multi-monitor behavior with external display

### Short-term (Week 1)

- [ ] Live with configuration for daily workflow testing
- [ ] Identify any missing functionality from Hyprpanel
- [ ] Fine-tune module update intervals if needed
- [ ] Adjust styling/colors if theme issues found
- [ ] Consider implementing optional enhancements

### Long-term (Month 1)

- [ ] Remove Hyprpanel-related flake inputs if no longer used
- [ ] Run `nix-collect-garbage` to remove old packages
- [ ] Update documentation with new Waybar keybindings/features
- [ ] Share configuration upstream if useful to community
- [ ] Consider additional Waybar modules (weather, VPN status, etc.)

---

## Notes and Considerations

### Walker/Elephant Integration

- Elephant is NOT a separate component - it's Walker's provider system
- No additional configuration needed for "Elephant menus"
- Already fully integrated via Walker configuration
- Web search provider = Elephant web search
- All other providers = Elephant backend

### Catppuccin Consistency

- System already uses Catppuccin Mocha Blue everywhere
- Walker theme manually defined (lines 99-360 in walker/default.nix)
- Waybar theme auto-applied via Home Manager module
- SDDM, Hyprlock, Ghostty all themed via catppuccin module
- No manual color definitions needed for Waybar

### GTK Theme Status - DEFINITIVE RESEARCH (February 2026)

**Current Configuration**: Tokyonight-Dark GTK theme (modules/theming/gtk.nix)

**Catppuccin GTK Investigation Results**:

1. **catppuccin-nix GTK Module**: COMPLETELY REMOVED
   - Source verification: https://github.com/catppuccin/nix/blob/main/modules/home-manager/gtk.nix
   - All GTK theme options removed with deprecation warnings
   - Removal reason: "upstream port has been archived and began experiencing breakages"
   - Only Papirus icon theme support remains (catppuccin.icon)

2. **catppuccin/gtk Repository**: ARCHIVED (June 2, 2024)
   - Source: https://github.com/catppuccin/gtk
   - Archive reason: "GTK theming is a nightmare to consistently theme and maintain"
   - Distribution-specific GTK behaviors cause incompatibilities
   - GNOME officially discourages custom GTK theming (no official API)

3. **nixpkgs catppuccin-gtk Package**: FROZEN at v0.4.1
   - Sources from archived catppuccin/gtk repository
   - No longer receives updates
   - Experiences known breakages across distributions

**FINAL RECOMMENDATION**: Keep Tokyonight-Dark GTK theme
- catppuccin-nix GTK support has been completely removed
- The nixpkgs package is frozen and unmaintained
- Tokyonight-Dark is actively maintained and stable
- Visual consistency is already excellent between both dark themes
- No migration path exists for Catppuccin GTK theming

### Hyprpanel Removal Safety

- Hyprpanel is NOT a critical system component
- Safe to remove without impacting core functionality
- Only affects:
  - Visual status bar
  - Notification center (SUPER+N)
  - System tray (replaced by Waybar tray)
- Does NOT affect:
  - Window management
  - Keyboard shortcuts (except SUPER+N)
  - Application launching
  - System services

### Multi-Monitor Behavior

- Current Hyprland config supports 2 monitors (eDP-1, HDMI-A-1)
- Waybar can spawn on all monitors or specific ones
- Default: Waybar on all monitors
- Can be customized with `output` configuration per module
- Workspace distribution can match Hyprland config

### Font Requirements

- JetBrainsMono Nerd Font required for icons
- Already installed via fonts module
- Nerd Font provides Unicode symbols for module icons
- Font configuration in Waybar style section

### Systemd Service Management

- `systemd.enable = true` creates waybar.service
- Service starts automatically on login
- Managed by Home Manager
- Logs: `journalctl --user -u waybar`
- Restart: `systemctl --user restart waybar`

### Notification Handling

- Hyprpanel had built-in notification center
- Waybar does NOT have notification support
- Options:
  1. Remove notification keybindings (simplest)
  2. Add mako notification daemon (recommended)
  3. Add dunst notification daemon (feature-rich)
- Notifications will still appear via system notification daemon
- Only the SUPER+N keybinding affected

---

## References

### Documentation

- Waybar Wiki: https://github.com/Alexays/Waybar/wiki
- Waybar Configuration: https://github.com/Alexays/Waybar/wiki/Configuration
- Waybar Styling: https://github.com/Alexays/Waybar/wiki/Styling
- NixOS Waybar Options: https://search.nixos.org/options?query=programs.waybar
- Catppuccin Waybar: https://github.com/catppuccin/waybar
- Walker Documentation: https://github.com/abenz1267/walker
- Catppuccin-nix GTK Options: https://nix.catppuccin.com/options/v1.2/home/catppuccin.gtk/

### GTK Theme Research (February 2026) - COMPLETE INVESTIGATION

**Research Methodology**:
- Examined catppuccin-nix repository source code
- Verified catppuccin/gtk repository archive status
- Checked nixpkgs catppuccin-gtk package definition
- Reviewed GitHub issues and archive notices

**Definitive Findings**:

1. **catppuccin-nix GTK Module Status**: REMOVED
   - Evidence: https://github.com/catppuccin/nix/blob/main/modules/home-manager/gtk.nix
   - Code analysis: All options (enable, flavor, accent, size, tweaks) use `mkRemovedOptionModule`
   - Error message when used: "catppuccin/gtk was removed from catppuccin/nix, as the upstream port has been archived and began experiencing breakages"
   - References: https://github.com/catppuccin/gtk/issues/262
   - Only remaining support: Icon theme (Papirus with Catppuccin colors)

2. **catppuccin/gtk Repository Status**: ARCHIVED
   - URL: https://github.com/catppuccin/gtk
   - Archived: June 2, 2024
   - Last release: v1.0.3 (June 1, 2024)
   - Maintainer statement: "GTK, while being one of our most popular ports, can only be described as a nightmare to consistently theme and maintain"
   - Core issue: Distribution-specific GTK implementations cause theme breakages
   - GNOME position: No official theming API, custom themes discouraged

3. **nixpkgs catppuccin-gtk Package**: FROZEN
   - Location: https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/themes/catppuccin-gtk/default.nix
   - Version: 0.4.1 (matches last archived release)
   - Source: `fetchFromGitHub { owner = "catppuccin"; repo = "gtk"; }`
   - This package wraps the archived repository and receives no updates

**Conclusion**:
The catppuccin-nix GTK integration was just a convenience wrapper around the archived catppuccin-gtk package from nixpkgs. When the upstream repository was archived and began breaking, catppuccin-nix removed the entire GTK module. There is NO active maintenance of Catppuccin GTK theming.

**Available Options** (Reassessed):
1. **Tokyonight-Dark** (RECOMMENDED) - Actively maintained, stable, similar aesthetic
2. **catppuccin-gtk** (nixpkgs v0.4.1) - Frozen, unmaintained, may break
3. **Manual installation** - Not recommended, defeats NixOS declarative approach
4. **Community forks** - Unverified, not in nixpkgs, maintenance uncertain

**Final Recommendation**:
Keep Tokyonight-Dark GTK theme. No viable Catppuccin GTK alternative exists within the NixOS ecosystem. The theme was removed from catppuccin-nix for good reason (repeated breakages), and the nixpkgs package is frozen at an unmaintained version.

### Repository Files

- Current Hyprland config: `/home/rehan/nixos-dotfiles/modules/desktop/hyprland/default.nix`
- Current Walker config: `/home/rehan/nixos-dotfiles/modules/desktop/walker/default.nix`
- Current theming: `/home/rehan/nixos-dotfiles/modules/theming/catppuccin.nix`
- Host configuration: `/home/rehan/nixos-dotfiles/modules/hosts/one-piece/default.nix`
- Module structure: `/home/rehan/nixos-dotfiles/modules/desktop/`

### Community Examples

- Waybar Catppuccin configurations: https://github.com/catppuccin/waybar/tree/main/themes
- NixOS Waybar configs: Search "nixos waybar" on GitHub
- Hyprland + Waybar setups: https://github.com/topics/hyprland-dotfiles

---

## Appendix: Quick Command Reference

### Build Commands

```bash
# Validate flake syntax
nix flake check

# Build without switching (safe testing)
sudo nixos-rebuild build --flake .#one-piece

# Apply configuration (after successful build)
sudo nixos-rebuild switch --flake .#one-piece

# Format files
nixfmt modules/desktop/waybar/default.nix
```

### Debugging Commands

```bash
# Check Waybar service status
systemctl --user status waybar

# View Waybar logs
journalctl --user -u waybar -f

# Manual Waybar launch (with debug output)
waybar -l debug

# List current processes
ps aux | grep waybar

# Check dependencies
nix-store -q --references ~/.nix-profile | grep waybar
```

### Rollback Commands

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Switch to specific generation
sudo nixos-rebuild switch --rollback

# Or from GRUB:
# Reboot > Select previous generation
```

### Git Commands

```bash
# Stage changes
git add modules/desktop/waybar/default.nix
git add modules/theming/catppuccin.nix
git add modules/desktop/hyprland/default.nix
git add modules/hosts/one-piece/default.nix

# Commit (use /commit slash command for proper format)

# View diff
git diff HEAD
git diff --staged
```

---

**End of Migration Plan**

**Next Steps**: Begin Phase 1 (Waybar Module Creation) after user approval.
