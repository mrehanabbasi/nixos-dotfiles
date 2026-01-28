# Bat - better cat with Catppuccin theme
{ ... }:

{
  flake.modules.homeManager.bat =
    { ... }:
    {
      catppuccin.bat.enable = true;

      programs.bat = {
        enable = true;
        config = {
          paging = "never";
        };
      };
    };
}
