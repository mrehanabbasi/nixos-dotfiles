# OpenCode - AI coding assistant
{ inputs, ... }:

{
  flake.modules.homeManager.opencode =
    { pkgs, lib, ... }:
    {
      # catppuccin/nix's opencode module (loaded unconditionally via all-modules.nix)
      # Declare it as a sink so the module system absorbs the definition without error.
      # Theme is applied via settings.theme instead.
      options.programs.opencode.tui = lib.mkSinkUndeclaredOptions { };

      config = {
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
