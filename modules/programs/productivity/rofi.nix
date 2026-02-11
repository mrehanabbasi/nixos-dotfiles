# Rofi - Application launcher with plugins (calculator, clipboard, emoji, web search, bitwarden)
# Replaces: Walker
# Depends on: catppuccin (for theming)
_:

{
  flake.modules.homeManager.rofi =
    { config, pkgs, ... }:
    {
      # Note: catppuccin.rofi.enable has incorrect import order, using custom theme instead

      # Clipboard manager backend
      services.cliphist.enable = true;

      # rbw - Bitwarden CLI for rofi-rbw
      programs.rbw = {
        enable = true;
        settings = {
          email = "mrehanabbasi@proton.me";
          pinentry = pkgs.pinentry-gnome3;
          base_url = "https://vaultwarden.mrehanabbasi.com";
        };
      };

      # rofi-rbw for Bitwarden integration (wtype required for Wayland typing)
      home.packages = with pkgs; [
        rofi-rbw
        wtype
      ];

      home.file = {
        # Custom Catppuccin Mocha theme for rofi
        ".local/share/rofi/themes/catppuccin-mocha-custom.rasi" = {
          text = ''
            * {
              /* Catppuccin Mocha colors */
              rosewater: #f5e0dc;
              flamingo: #f2cdcd;
              pink: #f5c2e7;
              mauve: #cba6f7;
              red: #f38ba8;
              maroon: #eba0ac;
              peach: #fab387;
              yellow: #f9e2af;
              green: #a6e3a1;
              teal: #94e2d5;
              sky: #89dceb;
              sapphire: #74c7ec;
              blue: #89b4fa;
              lavender: #b4befe;
              text: #cdd6f4;
              subtext1: #bac2de;
              subtext0: #a6adc8;
              overlay2: #9399b2;
              overlay1: #7f849c;
              overlay0: #6c7086;
              surface2: #585b70;
              surface1: #45475a;
              surface0: #313244;
              base: #1e1e2e;
              mantle: #181825;
              crust: #11111b;

              /* Theme variables */
              background: @base;
              foreground: @text;
              selected-background: @blue;
              selected-foreground: @crust;
              active: @green;
              urgent: @red;

              background-color: transparent;
            }

            window {
              background-color: @background;
              border: 2px;
              border-color: @blue;
              border-radius: 8px;
              padding: 12px;
              width: 600px;
            }

            mainbox {
              background-color: transparent;
              children: [ inputbar, message, listview, mode-switcher ];
              spacing: 10px;
            }

            inputbar {
              background-color: @surface0;
              border-radius: 6px;
              padding: 8px 12px;
              children: [ prompt, textbox-prompt-colon, entry ];
              spacing: 8px;
            }

            prompt {
              background-color: transparent;
              text-color: @blue;
            }

            textbox-prompt-colon {
              expand: false;
              str: "";
              background-color: transparent;
              text-color: @overlay1;
            }

            entry {
              background-color: transparent;
              text-color: @text;
              placeholder: "Search...";
              placeholder-color: @overlay0;
            }

            message {
              background-color: @surface0;
              border-radius: 6px;
              padding: 8px 12px;
            }

            textbox {
              background-color: transparent;
              text-color: @subtext1;
            }

            listview {
              background-color: transparent;
              columns: 1;
              lines: 8;
              spacing: 4px;
              fixed-height: true;
              scrollbar: false;
            }

            element {
              background-color: transparent;
              border-radius: 6px;
              padding: 8px 12px;
              spacing: 10px;
            }

            element normal.normal {
              background-color: transparent;
              text-color: @text;
            }

            element normal.active {
              background-color: transparent;
              text-color: @active;
            }

            element normal.urgent {
              background-color: transparent;
              text-color: @urgent;
            }

            element selected.normal {
              background-color: @selected-background;
              text-color: @selected-foreground;
            }

            element selected.active {
              background-color: @green;
              text-color: @crust;
            }

            element selected.urgent {
              background-color: @urgent;
              text-color: @crust;
            }

            element alternate.normal {
              background-color: transparent;
              text-color: @text;
            }

            element alternate.active {
              background-color: transparent;
              text-color: @active;
            }

            element alternate.urgent {
              background-color: transparent;
              text-color: @urgent;
            }

            element-icon {
              background-color: transparent;
              size: 24px;
            }

            element-text {
              background-color: transparent;
              text-color: inherit;
              highlight: bold underline;
            }

            mode-switcher {
              background-color: @surface0;
              border-radius: 6px;
              padding: 4px;
              spacing: 4px;
            }

            button {
              background-color: transparent;
              text-color: @subtext0;
              border-radius: 4px;
              padding: 6px 12px;
            }

            button selected {
              background-color: @blue;
              text-color: @crust;
            }
          '';
        };

        # Clipboard history helper script
        ".local/bin/cliphist-rofi" = {
          text = ''
            #!/usr/bin/env bash
            cliphist list | rofi -dmenu | cliphist decode | wl-copy
          '';
          executable = true;
        };

        # Web search helper script
        ".local/bin/rofi-websearch" = {
          text = ''
            #!/usr/bin/env bash
            # Rofi web search script
            # Usage: rofi -show websearch -modi websearch:rofi-websearch

            SEARCH_ENGINE="https://duckduckgo.com/?q="

            if [ -z "$@" ]; then
              echo -en "DuckDuckGo\0icon\x1fsearch\n"
              echo -en "Google\0icon\x1fsearch\n"
              echo -en "GitHub\0icon\x1fgithub\n"
              echo -en "YouTube\0icon\x1fyoutube\n"
            else
              query="$@"

              # Determine search engine based on input
              case "$query" in
                "DuckDuckGo")
                  echo "Type your search query..."
                  ;;
                "Google")
                  SEARCH_ENGINE="https://www.google.com/search?q="
                  echo "Type your search query..."
                  ;;
                "GitHub")
                  SEARCH_ENGINE="https://github.com/search?q="
                  echo "Type your search query..."
                  ;;
                "YouTube")
                  SEARCH_ENGINE="https://www.youtube.com/results?search_query="
                  echo "Type your search query..."
                  ;;
                *)
                  # Encode the query and open in browser
                  encoded=$(echo "$query" | sed 's/ /+/g')
                  xdg-open "''${SEARCH_ENGINE}''${encoded}" &
                  ;;
              esac
            fi
          '';
          executable = true;
        };
      };

      programs.rofi = {
        enable = true;
        terminal = "ghostty";
        location = "center";
        theme = "catppuccin-mocha-custom";

        extraConfig = {
          modi = "drun,run,window,calc,emoji,cliphist:${config.home.homeDirectory}/.local/bin/cliphist-rofi,websearch:${config.home.homeDirectory}/.local/bin/rofi-websearch";
          show-icons = true;
          drun-display-format = "{name}";
          disable-history = false;
          hide-scrollbar = true;
          display-drun = " Apps";
          display-run = " Run";
          display-window = " Window";
          display-calc = " Calc";
          display-emoji = " Emoji";
          display-cliphist = " Clipboard";
          display-websearch = " Search";
          sidebar-mode = false;
          matching = "fuzzy";

          # Vim-style keybindings
          kb-row-up = "Up,Control+k,Control+p";
          kb-row-down = "Down,Control+j,Control+n";
          kb-accept-entry = "Return,Control+m,KP_Enter";
          kb-remove-to-eol = ""; # Conflicts with Ctrl+k
          kb-mode-next = "Shift+Right,Control+Tab";
          kb-mode-previous = "Shift+Left,Control+ISO_Left_Tab";
          kb-remove-char-back = "BackSpace,Shift+BackSpace";
          kb-move-char-back = "Left,Control+b";
          kb-move-char-forward = "Right,Control+f";
          kb-row-first = "Control+Home"; # Clear Home from default
          kb-row-last = "Control+End"; # Clear End from default
          kb-move-front = "Control+a,Home";
          kb-move-end = "Control+e,End";
          kb-move-word-back = "Alt+b,Control+Left";
          kb-move-word-forward = "Alt+f,Control+Right";
          kb-clear-line = "Control+w";
          kb-cancel = "Escape,Control+g,Control+bracketleft";
        };

        plugins = with pkgs; [
          rofi-calc
          rofi-emoji
        ];
      };
    };
}
