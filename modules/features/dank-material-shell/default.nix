# DankMaterialShell - Quickshell-based desktop shell for Hyprland
# Replaces: waybar, swaync, hypridle, hyprlock, gtk theming
{ inputs, ... }:

{
  flake.modules.homeManager.dank-material-shell =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features."dank-material-shell";
    in
    {
      imports = [
        inputs.dms.homeModules.dank-material-shell
        inputs.dms-plugin-registry.homeModules.default
      ];

      options.features."dank-material-shell".enable =
        lib.mkEnableOption "DankMaterialShell desktop shell";

      config = lib.mkIf cfg.enable {
        programs.dank-material-shell = {
          enable = true;

          # Patch lock screen: custom wallpaper, reduced blur, halved fonts
          package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              chmod -R u+w $out/share/quickshell/dms/Modules/Lock
              patch -p1 -d $out/share/quickshell/dms < ${./lock-screen-customize.patch}
              substituteInPlace $out/share/quickshell/dms/Modules/Lock/LockScreenContent.qml \
                --replace-fail "@LOCK_WALLPAPER@" "file://${./lock.png}"
              sed -i 's/font\.pixelSize: 120/font.pixelSize: 60/g' \
                $out/share/quickshell/dms/Modules/Lock/LockScreenContent.qml
            '';
          });

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

            # Battery alerts are built into DMS now (the dankBatteryAlerts
            # plugin was dropped from the registry).
            batteryLowThreshold = 30;
            batteryCriticalThreshold = 15;

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
            lockScreenShowProfileImage = false;
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
                  "music"
                  {
                    id = "clock";
                    enabled = true;
                    clockCompactMode = false;
                  }
                  "weather"
                ];
                rightWidgets = [
                  "idleInhibitor"
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

            # The voxtypeActivityOverlay plugin is configured by the voxtype module.
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
                inherit (dmsConfig) enableVPN;
                inherit (dmsConfig) enableDynamicTheming;
                inherit (dmsConfig) enableAudioWavelength;
                inherit (dmsConfig) enableCalendarEvents;
                inherit (dmsConfig) enableClipboardPaste;
                inherit (dmsConfig) enableSystemMonitoring;
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
                # Plugins are loaded through a stable ~/.config path, and every
                # store file carries the same epoch mtime, so Qt's QML disk cache
                # sees "same URL, same timestamp" and serves a stale compile of
                # the previous plugin version. Drop it before restarting.
                rm -rf "${config.xdg.cacheHome}/quickshell/qmlcache"
                ${pkgs.systemd}/bin/systemctl --user restart dms.service
              fi
            fi
            echo "${configHash}" > "${markerFile}"
          '';
      };
    };

  # NixOS module for dms-greeter (replaces SDDM)
  flake.modules.nixos.dms-greeter =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features."dms-greeter";
    in
    {
      imports = [
        inputs.dank-greeter.nixosModules.default
      ];

      options.features."dms-greeter".enable = lib.mkEnableOption "DMS greeter display manager";

      config = lib.mkIf cfg.enable {
        programs.dms-greeter = {
          enable = true;
          # The greeter ships its QML embedded in the Go binary, so the layout
          # patch has to land on the source tree before postPatch bakes it in.
          package =
            inputs.dank-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
              (old: {
                postPatch = ''
                  patch -p1 -d quickshell < ${./greeter-left-align.patch}
                ''
                + (old.postPatch or "");
              });
          compositor.name = "hyprland";
          # Skip upstream configFiles: its preStart does `cp $src .` which preserves
          # nix store hash prefix in basename, but greeter expects exact filenames.
          logs.save = true; # Enable logging for debugging
        };

        # Place settings.json with the exact name the greeter expects.
        # Cleans up stale files left from earlier configFiles experiments.
        systemd.services.greetd.preStart = lib.mkAfter ''
          cd /var/lib/dms-greeter
          # Remove any stale hash-prefixed files (from old configFiles experiments)
          rm -f -- *-session.json *-settings.json *-background.png *-login.png \
            *-greeter_wallpaper_override.jpg greeter_wallpaper_override.jpg
          cp -f ${
            pkgs.writeText "greeter-settings.json" (
              builtins.toJSON {
                # Greeter now reads the lock screen wallpaper keys, not greeterWallpaper*.
                lockScreenWallpaperPath = "${./login.png}";
                lockScreenWallpaperFillMode = "Fill";
                lockScreenShowProfileImage = false;
              }
            )
          } settings.json
          chmod 644 settings.json
          chown greeter: settings.json
        '';

        # Default session
        services.displayManager.defaultSession = "hyprland";

        # Disk management (was in SDDM module)
        services.udisks2.enable = true;
      };
    };
}
