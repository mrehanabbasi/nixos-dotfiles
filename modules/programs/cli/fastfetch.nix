# Fastfetch - system information with custom layout
_:

{
  flake.modules.homeManager.fastfetch =
    _:
    {
      programs.fastfetch = {
        enable = true;
        settings = {
          logo = {
            type = "file";
            color = {
              "1" = "blue";
            };
            padding = {
              top = 3;
            };
          };

          display = {
            separator = "    ";
          };

          modules = [
            {
              type = "custom";
              format = "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓";
            }
            "break"
            {
              type = "os";
              key = "  ";
              keyColor = "blue";
            }
            {
              type = "kernel";
              key = "  ";
              keyColor = "white";
            }
            {
              type = "packages";
              key = "  ";
              keyColor = "yellow";
            }
            {
              type = "wm";
              key = "  󰨇";
              keyColor = "blue";
            }
            {
              type = "terminal";
              key = "  ";
              keyColor = "magenta";
            }
            {
              type = "shell";
              key = "  ";
              keyColor = "yellow";
            }
            "break"
            {
              type = "custom";
              format = "┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫";
            }
            "break"
            {
              type = "host";
              key = "  ";
              keyColor = "bright_blue";
            }
            {
              type = "cpu";
              key = "  ";
              keyColor = "bright_green";
            }
            {
              type = "gpu";
              key = "  󱤓";
              keyColor = "red";
            }
            {
              type = "memory";
              key = "  󰍛";
              keyColor = "bright_yellow";
            }
            {
              type = "disk";
              key = "  ";
              keyColor = "bright_cyan";
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
}
