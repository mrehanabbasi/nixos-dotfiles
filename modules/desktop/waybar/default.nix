# Waybar - Wayland status bar with Catppuccin theming
# Depends on: catppuccin (for theming)
_:

{
  flake.modules.homeManager.waybar =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [ cava ];

        file = {
          # Cava wrapper script that continuously monitors audio and hides when stopped
          ".config/waybar/scripts/cava-wrapper.sh" = {
            text = ''
              #!/usr/bin/env bash

              # Function to check if audio is playing
              is_playing() {
                pactl list short sink-inputs 2>/dev/null | grep -q .
              }

              # Start cava in the background and capture its output
              cava -p ~/.config/cava/config_waybar 2>/dev/null | while IFS= read -r line; do
                if is_playing; then
                  # Transform and output the visualization
                  echo "$line" | sed 's/;//g;s/0/▁/g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g;'
                else
                  # No audio - output empty to hide module
                  echo ""
                fi
              done
            '';
            executable = true;
          };

          # VPN status script using PIA CLI
          ".config/waybar/scripts/vpn-status.sh" = {
            text = ''
              #!/usr/bin/env bash

              while true; do
                PIA_STATUS=$(pia status --short 2>/dev/null)

                if echo "$PIA_STATUS" | grep -q "connected:wg"; then
                  echo "PIA:wg"
                elif echo "$PIA_STATUS" | grep -q "connected:ovpn"; then
                  echo "PIA:ovpn"
                else
                  echo ""
                fi

                sleep 2
              done
            '';
            executable = true;
          };

          # Power menu XML definition
          ".config/waybar/power_menu.xml".source = ./power_menu.xml;
        };
      };

      catppuccin.waybar.enable = true;

      programs.waybar = {
        enable = true;
        systemd.enable = true;

        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            height = 32;
            spacing = 4;
            exclusive = true;

            modules-left = [
              "custom/logo"
              "hyprland/workspaces"
              "hyprland/window"
            ];
            modules-center = [ "clock" ];
            modules-right = [
              "tray"
              "custom/cava"
              "memory"
              "custom/vpn"
              "network"
              "bluetooth"
              "pulseaudio"
              "battery"
              "custom/notification"
              "custom/power"
            ];

            "custom/logo" = {
              format = "󱄅";
              tooltip = false;
              on-click = "rofi -show drun";
            };

            "hyprland/workspaces" = {
              format = "{name}";
              on-click = "activate";
              persistent-workspaces = {
                "*" = 5;
              };
            };

            "hyprland/window" = {
              format = "{class}";
              icon = true;
              separate-outputs = true;
              max-length = 50;
              rewrite = {
                "" = "Desktop";
              };
            };

            clock = {
              format = " {:%a %Y-%m-%d %I:%M %p}";
              tooltip-format = "<tt><small>{calendar}</small></tt>";
              calendar = {
                mode = "month";
                format = {
                  months = "<span color='@blue'><b>{}</b></span>";
                  days = "<span color='@text'>{}</span>";
                  weeks = "<span color='@sky'><b>W{}</b></span>";
                  weekdays = "<span color='@yellow'><b>{}</b></span>";
                  today = "<span color='@red'><b><u>{}</u></b></span>";
                };
              };
            };

            memory = {
              format = " {percentage}%";
              interval = 2;
              on-click = "ghostty --title='btop' -e btop";
            };

            network = {
              format-wifi = "{icon} {essid}";
              format-ethernet = " {ifname}";
              format-disconnected = "󰤭 ";
              tooltip-format-wifi = "{icon} {essid}\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}\n{ipaddr}/{cidr}";
              tooltip-format-ethernet = "  {ifname}\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}\n{ipaddr}/{cidr}";
              format-icons = [
                "󰤯"
                "󰤟"
                "󰤢"
                "󰤥"
                "󰤨"
              ];
            };

            bluetooth = {
              format = "󰂯 {status}";
              format-on = "󰂯 On";
              format-off = "󰂯 Off";
              format-connected = "󰂯 Connected ({num_connections})";
              # format-connected-battery = "󰂯 {device_alias} ({device_battery_percentage}%)";
              on-click = "blueberry";
              tooltip-format-connected = "{device_enumerate}";
              tooltip-format-enumerate-connected = "{device_alias}";
              tooltip-format-enumerate-connected-battery = "{device_alias} ({device_battery_percentage}%)";
            };

            pulseaudio = {
              format = "{icon} {volume}%";
              format-bluetooth = "{icon} {volume}%";
              format-muted = " Muted";
              format-icons = {
                headphone = "󰋋";
                hands-free = "󱡏";
                headset = "󰋎";
                phone = "";
                portable = "󰜟";
                car = "";
                default = [
                  "󰕿"
                  "󰖀"
                  "󰕾"
                ];
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
              format-full = "󱟢 {capacity}%";
              format-icons = {
                default = [
                  "󰂎"
                  "󰁺"
                  "󰁻"
                  "󰁼"
                  "󰁽"
                  "󰁾"
                  "󰂀"
                  "󰂁"
                  "󰂂"
                  "󰁹"
                ];
                charging = [
                  "󰢜"
                  "󰂆"
                  "󰂇"
                  "󰂈"
                  "󰢝"
                  "󰂉"
                  "󰢞"
                  "󰂊"
                  "󰂋"
                  "󰂅"
                ];
              };
              tooltip-format = "{timeTo}, {capacity}%";
            };

            tray = {
              icon-size = 18;
              spacing = 8;
              show-passive-items = true;
            };

            "custom/cava" = {
              exec = "~/.config/waybar/scripts/cava-wrapper.sh";
              format = " {}";
              tooltip = false;
              on-click = "pavucontrol";
            };

            "custom/vpn" = {
              exec = "~/.config/waybar/scripts/vpn-status.sh";
              format = " {}";
              tooltip = false;
              on-click = "nm-connection-editor";
            };

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

            "custom/power" = {
              format = "⏻";
              tooltip = false;
              menu = "on-click";
              menu-file = "~/.config/waybar/power_menu.xml";
              menu-actions = {
                suspend = "systemctl suspend";
                logout = "pkill -TERM brave; hyprshutdown -t 'Logging out...' --no-exit && hyprctl dispatch exit";
                reboot = "pkill -TERM brave; hyprshutdown -t 'Rebooting...' --no-exit && systemctl reboot";
                shutdown = "pkill -TERM brave; hyprshutdown -t 'Shutting down...' --noexit && systemctl poweroff";
              };
            };
          };
        };

        style = ''
          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 16px;
            border: none;
            border-radius: 0;
          }

          window#waybar {
            background-color: transparent;
            color: @text;
          }

          /* Workspace buttons */
          #workspaces {
            background-color: @mantle;
            border-radius: 8px;
            margin: 2px 2px;
            padding: 0px 4px;
          }

          #workspaces button {
            background-color: transparent;
            color: @sky;
            padding: 0 8px;
            margin: 0 2px;
            border-radius: 8px;
            transition: all 0.3s ease;
          }

          #workspaces button.active {
            background-color: @blue;
            color: @crust;
          }

          #workspaces button.empty {
            color: @surface2;
          }

          #workspaces button.urgent {
            background-color: @red;
            color: @crust;
          }

          #workspaces button:hover {
            background-color: rgba(245, 194, 231, 0.3);
          }

          /* Window title */
          #window {
            background-color: @mantle;
            color: @pink;
            padding: 0 16px;
            margin: 2px 2px;
            margin-left: 0px;
            border-radius: 8px;
            font-weight: 500;
          }

          /* Clock */
          #clock {
            background-color: @mantle;
            color: @pink;
            padding: 0 16px;
            margin: 2px 2px;
            border-radius: 8px;
            font-weight: 500;
          }

          /* System tray */
          #tray {
            background-color: @mantle;
            padding: 0 12px;
            margin: 2px 2px;
            border-radius: 8px;
          }

          /* Cava audio visualizer */
          #custom-cava {
            background-color: @mantle;
            color: @sky;
            padding: 0 12px;
            margin: 2px 2px;
            border-radius: 8px;
            font-family: "JetBrainsMono Nerd Font";
          }

          /* Memory */
          #memory {
            background-color: @mantle;
            color: @yellow;
            padding: 0 12px;
            margin: 2px 2px;
            border-radius: 8px;
          }

          /* VPN */
          #custom-vpn {
            background-color: @mantle;
            color: @green;
            padding: 0 12px;
            margin: 2px 2px;
            border-radius: 8px;
          }

          /* Network */
          #network {
            background-color: @mantle;
            color: @mauve;
            padding: 0 12px;
            margin: 2px 2px;
            border-radius: 8px;
          }

          #network.disconnected {
            color: @red;
          }

          /* Bluetooth */
          #bluetooth {
            background-color: @mantle;
            color: @sky;
            padding: 0 12px;
            margin: 2px 2px;
            border-radius: 8px;
          }

          /* PulseAudio */
          #pulseaudio {
            background-color: @mantle;
            color: @maroon;
            padding: 0 12px;
            margin: 2px 2px;
            border-radius: 8px;
          }

          #pulseaudio.muted {
            color: @surface2;
          }

          /* Battery */
          #battery {
            background-color: @mantle;
            color: @yellow;
            padding: 0 12px;
            margin: 2px 2px;
            border-radius: 8px;
          }

          #battery.warning {
            color: @peach;
          }

          #battery.critical {
            color: @red;
          }

          #battery.charging {
            color: @green;
          }

          /* Notification center */
          #custom-notification {
            background-color: @mantle;
            color: @sky;
            padding: 0 12px;
            margin: 2px 2px;
            border-radius: 8px;
          }

          #custom-notification:hover {
            background-color: rgba(137, 220, 235, 0.2);
          }

          /* Power menu */
          #custom-power {
            background-color: @mantle;
            color: @red;
            padding: 0 12px;
            margin: 2px 8px 2px 2px;
            border-radius: 8px;
          }

          #custom-power:hover {
            background-color: rgba(243, 139, 168, 0.2);
          }

          #custom-logo {
            background-color: @mantle;
            color: @blue;
            padding: 0 12px;
            margin: 2px 2px 2px 8px;
            border-radius: 8px;
            font-size: 20px;
          }
        '';
      };
    };
}
