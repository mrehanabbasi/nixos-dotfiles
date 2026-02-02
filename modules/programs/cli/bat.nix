# Bat - better cat with Catppuccin theme
_:

{
  flake.modules.homeManager.bat = _: {
    catppuccin.bat.enable = true;

    programs.bat = {
      enable = true;
      config = {
        paging = "never";
      };
    };
  };
}
