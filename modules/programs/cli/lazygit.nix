# Lazygit - terminal UI for git with Catppuccin theme
_:

{
  flake.modules.homeManager.lazygit = _: {
    catppuccin.lazygit.enable = true;

    programs.lazygit = {
      enable = true;
    };
  };
}
