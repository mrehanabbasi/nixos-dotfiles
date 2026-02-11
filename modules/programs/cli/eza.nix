# Eza - modern ls replacement with Catppuccin theme
_:

{
  flake.modules.homeManager.eza = _: {
    catppuccin.eza.enable = true;

    programs.eza = {
      enable = true;
      icons = "auto";
      git = true;
    };
  };
}
