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
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };
    in
    {
      options.features.opencode.enable = lib.mkEnableOption "OpenCode AI coding assistant";

      config = lib.mkIf cfg.enable {
        programs.opencode = {
          enable = true;
          package = pkgs-unstable.opencode;
          tui = {
            theme = "catppuccin";
          };
        };
      };
    };
}
