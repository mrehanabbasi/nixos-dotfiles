# Fastfetch - system information with custom layout
_:

{
  flake.modules.homeManager.fastfetch =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.fastfetch;

      # fastfetch's own terminal/terminalfont detection walks the parent process
      # tree, which dead-ends at the detached tmux server ("Unknown terminal:
      # tmux: server"). Resolve the real terminal through the tmux client
      # instead, then read the font out of that terminal's live config.
      terminalFont = pkgs.writeShellApplication {
        name = "fastfetch-terminal-font";
        runtimeInputs = with pkgs; [
          coreutils
          gawk
          gnused
          tmux
        ];
        text = ''
          resolve_terminal() {
            local pid=$1 comm depth=0
            while [[ -r /proc/$pid/status && $depth -lt 12 ]]; do
              comm=$(< "/proc/$pid/comm")
              case $comm in
                *ghostty*) echo ghostty; return 0 ;;
              esac
              pid=$(awk '/^PPid:/{print $2}' "/proc/$pid/status")
              [[ -n $pid && $pid -gt 1 ]] || return 1
              depth=$((depth + 1))
            done
            return 1
          }

          start=$PPID
          if [[ -n ''${TMUX:-} ]]; then
            start=$(tmux display-message -p '#{client_pid}' 2>/dev/null) || start=$PPID
          fi

          if ! term=$(resolve_terminal "$start"); then
            echo unknown
            exit 0
          fi

          case $term in
            ghostty)
              cfg="''${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
              if [[ ! -r $cfg ]]; then
                echo ghostty
                exit 0
              fi
              family=$(sed -n 's/^font-family[[:space:]]*=[[:space:]]*//p' "$cfg" | head -n 1)
              size=$(sed -n 's/^font-size[[:space:]]*=[[:space:]]*//p' "$cfg" | head -n 1)
              printf '%s (%spt)\n' "''${family:-default}" "''${size:-?}"
              ;;
            *)
              echo "$term"
              ;;
          esac
        '';
      };
    in
    {
      options.features.fastfetch.enable = lib.mkEnableOption "fastfetch system information display";
      config = lib.mkIf cfg.enable {
        programs.fastfetch = {
          enable = true;
          settings = {
            logo = {
              # type = "file";
              color = {
                "1" = "blue";
              };
              height = 15;
              width = 15;
              padding = {
                top = 1;
              };
            };

            display = {
              separator = " ➜  ";
            };

            modules = [
              {
                type = "custom";
                format = "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓";
              }
              "break"
              {
                type = "os";
                key = " DISTRO";
                keyColor = "blue";
              }
              {
                type = "kernel";
                key = " ├  ";
                keyColor = "white";
              }
              {
                type = "packages";
                key = " ├ 󰏖 ";
                keyColor = "yellow";
              }
              {
                type = "shell";
                key = " └  ";
                keyColor = "yellow";
              }
              "break"
              {
                type = "wm";
                key = " DE/WM";
                keyColor = "blue";
              }
              {
                type = "wmtheme";
                key = " ├ 󰉼 ";
                keyColor = "blue";
              }
              {
                type = "icons";
                key = " ├ 󰀻 ";
                keyColor = "blue";
              }
              {
                type = "cursor";
                key = " ├  ";
                keyColor = "blue";
              }
              {
                type = "terminal";
                key = " ├  ";
                keyColor = "magenta";
              }
              {
                type = "command";
                text = lib.getExe terminalFont;
                key = " └  ";
                keyColor = "magenta";
              }
              "break"
              {
                type = "custom";
                format = "┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫";
              }
              "break"
              {
                type = "host";
                format = "{2}";
                key = "󰌢 SYSTEM";
                keyColor = "bright_blue";
              }
              {
                type = "cpu";
                format = "{1} ({3}) @ {7} GHz";
                key = " ├  ";
                keyColor = "bright_green";
              }
              {
                type = "gpu";
                format = "{2}";
                key = " ├ 󰢮 ";
                keyColor = "red";
              }
              {
                type = "memory";
                key = " ├  ";
                keyColor = "bright_yellow";
              }
              {
                type = "disk";
                key = " ├ 󰋊 ";
                keyColor = "bright_cyan";
              }
              {
                type = "display";
                key = " └  ";
                compactType = "original-with-refresh-rate";
                keyColor = "cyan";
              }
              "break"
              {
                type = "custom";
                format = "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛";
              }
            ];
          };
        };
      };
    };
}
