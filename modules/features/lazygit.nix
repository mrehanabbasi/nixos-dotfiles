# Lazygit - terminal UI for git with Catppuccin theme
_:

{
  flake.modules.homeManager.lazygit =
    { config, lib, ... }:
    let
      cfg = config.features.lazygit;
    in
    {
      options.features.lazygit.enable = lib.mkEnableOption "lazygit terminal UI for git";
      config = lib.mkIf cfg.enable {
        catppuccin.lazygit.enable = true;

        programs.lazygit = {
          enable = true;
        };
      };
    };
}
