# OpenCode - AI coding assistant
{ inputs, ... }:

{
  flake.modules.homeManager.opencode =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.opencode;
    in
    {
      options.features.opencode.enable = lib.mkEnableOption "OpenCode AI coding assistant";

      config = lib.mkIf cfg.enable {
        programs.opencode = {
          enable = true;
          package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
          tui = {
            theme = "catppuccin";
          };
        };
      };
    };
}
