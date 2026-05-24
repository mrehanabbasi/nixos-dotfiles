# Eza - modern ls replacement with Catppuccin theme
_:

{
  flake.modules.homeManager.eza =
    { config, lib, ... }:
    let
      cfg = config.features.eza;
    in
    {
      options.features.eza.enable = lib.mkEnableOption "eza modern ls replacement";
      config = lib.mkIf cfg.enable {
        catppuccin.eza.enable = true;

        programs.eza = {
          enable = true;
          icons = "auto";
          git = true;
        };
      };
    };
}
