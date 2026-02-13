# Hypridle - idle daemon for Hyprland with power-state-aware timeouts
# Automatically switches between AC and battery configurations
{ inputs, ... }:

{
  flake.modules.homeManager.hypridle =
    {
      config,
      pkgs,
      lib,
      ...
    }:
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

      powerMonitorScript = pkgs.writeShellScript "hypridle-power-monitor" ''
        get_power_state() {
          for supply in /sys/class/power_supply/AC /sys/class/power_supply/ACAD /sys/class/power_supply/ADP*; do
            if [ -f "$supply/online" ]; then
              cat "$supply/online"
              return
            fi
          done
          echo "1"
        }

        restart_hypridle() {
          local config="$1"
          ${pkgs.procps}/bin/pkill -x hypridle 2>/dev/null || true
          sleep 0.5
          ln -sf "$config" "$CONFIG_DIR/hypridle.conf"
          ${pkgs.hypridle}/bin/hypridle &
        }

        CURRENT_STATE=""
        CONFIG_DIR="${config.xdg.configHome}/hypr"
        AC_CONFIG="$CONFIG_DIR/hypridle-ac.conf"
        BATTERY_CONFIG="$CONFIG_DIR/hypridle-battery.conf"

        while true; do
          POWER_STATE=$(get_power_state)

          if [ "$POWER_STATE" != "$CURRENT_STATE" ]; then
            CURRENT_STATE="$POWER_STATE"
            if [ "$POWER_STATE" = "1" ]; then
              restart_hypridle "$AC_CONFIG"
            else
              restart_hypridle "$BATTERY_CONFIG"
            fi
          fi

          sleep 5
        done
      '';
    in
    {
      services.hypridle.enable = false;

      xdg.configFile = {
        "hypr/hypridle-ac.conf".text = acConfig;
        "hypr/hypridle-battery.conf".text = batteryConfig;
      };

      systemd.user.services.hypridle-power-monitor = {
        Unit = {
          Description = "Hypridle power-state-aware monitor";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${powerMonitorScript}";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
