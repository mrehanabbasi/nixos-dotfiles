# DankMaterialShell - Quickshell-based desktop shell for Hyprland
# Replaces: waybar, swaync, hypridle, hyprlock, gtk theming
{ inputs, ... }:

{
  flake.modules.homeManager.dank-material-shell =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.dms.homeModules.dank-material-shell
        inputs.dms-plugin-registry.modules.default
      ];

      programs.dank-material-shell = {
        enable = true;

        # Systemd integration
        systemd = {
          enable = true;
          restartIfChanged = true;
        };

        # Feature toggles
        enableSystemMonitoring = true;
        enableVPN = true;
        enableDynamicTheming = true; # Enable Matugen for Catppuccin theming
        enableAudioWavelength = true; # Audio visualizer (replaces cava)
        enableCalendarEvents = true;
        enableClipboardPaste = true;

        dgop.package = inputs.dgop.packages.${pkgs.system}.default;

        # Main settings
        settings = {
          # Theme - Catppuccin Mocha Blue (via Matugen)
          currentThemeName = "custom";
          currentThemeCategory = "registry";
          customThemeFile = "${config.xdg.configHome}/DankMaterialShell/themes/catppuccin/theme.json";
          registryThemeVariants = {
            catppuccin = {
              dark = {
                flavor = "mocha";
                accent = "blue";
              };
            };
          };

          # Matugen settings for Catppuccin Mocha Blue
          matugenScheme = "scheme-tonal-spot";
          runDmsMatugenTemplates = true;
          runUserMatugenTemplates = true;

          # Enable DMS theming for GTK/Qt (Catppuccin Mocha Blue)
          gtkThemingEnabled = true;
          qtThemingEnabled = true;
          syncModeWithPortal = true; # Sync dark mode with XDG portal

          # Font
          fontFamily = "JetBrainsMono Nerd Font";
          monoFontFamily = "JetBrainsMono Nerd Font";
          fontWeight = 400;
          fontScale = 1.0;

          # Bar visibility
          showLauncherButton = true;
          showWorkspaceSwitcher = true;
          showFocusedWindow = true;
          showClock = true;
          showBattery = true;
          showSystemTray = true;
          showNotificationButton = true;
          showCpuUsage = true;
          showMemUsage = true;
          showCpuTemp = true;
          showMusic = true;
          showClipboard = true;
          launcherLogoMode = "os";

          # Clock and date settings
          use24HourClock = false;
          showSeconds = false;
          padHours12Hour = true;
          clockDateFormat = "ddd d MMM yyyy";
          lockDateFormat = "ddd d MMM yyyy";

          # Workspace configuration
          showWorkspaceIndex = true;
          workspaceFollowFocus = true;
          showOccupiedWorkspacesOnly = false;

          # Hyprland layout overrides (match current settings)
          hyprlandLayoutGapsOverride = 2; # gaps_in
          hyprlandLayoutRadiusOverride = 4; # rounding
          hyprlandLayoutBorderSize = 1; # border_size

          # Visual effects
          cornerRadius = 8;
          popupTransparency = 1.0;
          dockTransparency = 1.0;
          blurEnabled = true;
          m3ElevationEnabled = true;
          enableRippleEffects = true;

          # Power management (matching hypridle)
          acMonitorTimeout = 600; # 10 min DPMS on AC
          acLockTimeout = 300; # 5 min lock on AC
          acSuspendTimeout = 0; # No suspend on AC

          batteryMonitorTimeout = 420; # 7 min DPMS on battery
          batteryLockTimeout = 180; # 3 min lock on battery
          batterySuspendTimeout = 600; # 10 min suspend on battery

          lockBeforeSuspend = true;
          loginctlLockIntegration = true;
          fadeToLockEnabled = true;
          fadeToDpmsEnabled = true;

          # Notifications (matching swaync)
          notificationOverlayEnabled = true; # Enable toast popups (disabled by default)
          notificationTimeoutNormal = 5000;
          notificationTimeoutLow = 3000;
          notificationTimeoutCritical = 0;
          notificationHistoryEnabled = true;
          notificationHistoryMaxCount = 50;
          notificationPopupPosition = 0; # Top-right

          # Lock screen
          lockScreenShowTime = true;
          lockScreenShowDate = true;
          lockScreenShowProfileImage = true;
          lockScreenShowPasswordField = true;
          lockScreenShowMediaPlayer = true;
          lockScreenShowPowerActions = true;

          # Launcher
          appLauncherViewMode = "list";
          sortAppsAlphabetically = false;

          # Audio
          audioVisualizerEnabled = true;
          waveProgressEnabled = true;

          # OSD
          osdVolumeEnabled = true;
          osdBrightnessEnabled = true;
          osdCapsLockEnabled = true;
          osdMicMuteEnabled = true;

          # Power menu actions
          powerActionConfirm = true;
          customPowerActionLogout = "pkill -TERM brave; hyprctl dispatch exit";
          customPowerActionReboot = "pkill -TERM brave; systemctl reboot";
          customPowerActionPowerOff = "pkill -TERM brave; systemctl poweroff";

          # Wallpaper (replaces hyprpaper)
          wallpaperPath = "${./wallpaper.png}";
          wallpaperFillMode = "Fill";

          # Greeter wallpaper
          greeterWallpaperPath = "${./background.png}";
          greeterWallpaperFillMode = "Fill";

          # Bar config
          barConfigs = [
            {
              id = "default";
              name = "Main Bar";
              enabled = true;
              position = 0;
              screenPreferences = [ "all" ];
              showOnLastDisplay = true;
              leftWidgets = [
                "launcherButton"
                "workspaceSwitcher"
                "focusedWindow"
              ];
              centerWidgets = [
                {
                  id = "voxtype-status";
                  enabled = true;
                }
                "music"
                {
                  id = "clock";
                  enabled = true;
                  clockCompactMode = false;
                }
                "weather"
              ];
              rightWidgets = [
                "systemTray"
                {
                  id = "dankKDEConnect";
                  enabled = true;
                }
                "clipboard"
                "cpuUsage"
                "memUsage"
                "battery"
                "controlCenterButton"
                "notificationButton"
                {
                  id = "sessionPower";
                  enabled = true;
                }
              ];
              noBackground = false; # Background for widgets
            }
          ];
        };

        # Clipboard settings
        clipboardSettings = {
          maxHistory = 25;
          maxEntrySize = 5242880;
          autoClearDays = 1;
          clearAtStartup = false;
        };

        # Plugins
        plugins = {
          mediaPlayer = {
            enable = true;
            settings = {
              preferredSource = "auto";
            };
          };

          dankBatteryAlerts = {
            enable = true;
            settings = {
              warningLevel = 30;
              criticalLevel = 15;
            };
          };

          # dankBitwarden - Password manager integration
          # Trigger: [ (default) - launches Bitwarden search in DMS launcher
          # Uses rbw backend (configured below)
          dankBitwarden = {
            enable = true;
            settings = {
              # Trigger key to open Bitwarden search (default: "[")
              triggerKey = "[";
            };
          };

          # sessionPower - Power/session management plugin
          sessionPower = {
            enable = true;
          };

          # calculator - Calculator in DMS launcher (replaces rofi-calc)
          calculator = {
            enable = true;
          };

          dankKDEConnect = {
            enable = true;
          };

          webSearch = {
            enable = true;
          };

          # Custom voxtype status widget
          voxtype-status = {
            enable = true;
            src = ./voxtype-widget;
          };
        };
      };

      # rbw - Bitwarden CLI backend for dankBitwarden (moved from rofi.nix)
      programs.rbw = {
        enable = true;
        settings = {
          email = "mrehanabbasi@proton.me";
          pinentry = pkgs.pinentry-qt;
          base_url = "https://vaultwarden.mrehanabbasi.com";
        };
      };

      # GTK theming - adw-gtk3 is required for Matugen to theme GTK3 apps like Thunar
      gtk = {
        enable = true;

        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };

        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
      };

      # dconf settings for GTK apps that read from dconf
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
          icon-theme = "Papirus-Dark";
        };
      };

      # GTK4 theming - import DMS-generated colors for libadwaita apps (pavucontrol, etc.)
      xdg.configFile."gtk-4.0/gtk.css".text = ''
        @import url("dank-colors.css");
      '';

      # Packages for theming integration
      home.packages = with pkgs; [
        # Qt platform theme plugins for DMS theming integration
        libsForQt5.qtstyleplugins # Qt5 GTK3 platform theme plugin
        kdePackages.qt6ct # Qt6 configuration tool (KDE variant for better Dolphin support)
      ];

      # Restart DMS only when its config changes
      # Uses a hash marker to track config changes across rebuilds
      home.activation.restartDms =
        let
          dmsConfig = config.programs.dank-material-shell;
          # Hash all DMS config options that would require a restart
          configHash = builtins.hashString "sha256" (
            builtins.toJSON {
              inherit (dmsConfig) settings plugins clipboardSettings;
              # Include feature flags
              enableVPN = dmsConfig.enableVPN;
              enableDynamicTheming = dmsConfig.enableDynamicTheming;
              enableAudioWavelength = dmsConfig.enableAudioWavelength;
              enableCalendarEvents = dmsConfig.enableCalendarEvents;
              enableClipboardPaste = dmsConfig.enableClipboardPaste;
              enableSystemMonitoring = dmsConfig.enableSystemMonitoring;
            }
          );
          markerDir = "${config.xdg.stateHome}/dms-activation";
          markerFile = "${markerDir}/config-hash";
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "${markerDir}"
          if ${pkgs.systemd}/bin/systemctl --user is-active --quiet dms.service; then
            old_hash=$(cat "${markerFile}" 2>/dev/null || echo "")
            if [ "$old_hash" != "${configHash}" ]; then
              ${pkgs.systemd}/bin/systemctl --user restart dms.service
            fi
          fi
          echo "${configHash}" > "${markerFile}"
        '';
    };

  # NixOS module for dms-greeter (replaces SDDM)
  flake.modules.nixos.dms-greeter =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.dms.nixosModules.greeter
      ];

      programs.dank-material-shell.greeter = {
        enable = true;
        compositor.name = "hyprland";
        configFiles = [ "${./background.png}" ]; # Greeter wallpaper
        logs.save = true; # Enable logging for debugging
      };

      # Default session
      services.displayManager.defaultSession = "hyprland";

      # Disk management (was in SDDM module)
      services.udisks2.enable = true;
    };
}
