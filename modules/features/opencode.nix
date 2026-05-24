# OpenCode - AI coding assistant
{ inputs, ... }:

{
  flake.modules.homeManager.opencode =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.opencode;
    in
    {
      options.features.opencode.enable = lib.mkEnableOption "OpenCode AI coding assistant";

      # catppuccin/nix's opencode module (loaded unconditionally via all-modules.nix)
      # Declare it as a sink so the module system absorbs the definition without error.
      # Theme is applied via settings.theme instead.
      options.programs.opencode.tui = lib.mkSinkUndeclaredOptions { };

      config = lib.mkIf cfg.enable {
        # If true, tries to set programs.opencode.tui, which does not exist in home-manager 25.11.
        catppuccin.opencode.enable = false;

        programs.opencode = {
          enable = true;
          package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
          settings = {
            theme = "catppuccin";
          };
        };
      };
    };
}
