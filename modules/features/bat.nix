# Bat - better cat
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
