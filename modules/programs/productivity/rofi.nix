# Rofi - Application launcher with plugins (calculator, clipboard, emoji, web search)
# Replaces: Walker
# Depends on: catppuccin (for theming)
_:

{
  flake.modules.homeManager.rofi =
    { config, pkgs, ... }:
    {
      catppuccin.rofi.enable = true;

      # Clipboard manager backend
      services.cliphist.enable = true;

      home.file = {
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
        };

        plugins = with pkgs; [
          rofi-calc
          rofi-emoji
        ];
      };
    };
}
