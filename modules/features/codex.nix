# Codex - AI coding agent CLI
# Uses nixpkgs-unstable for latest version
{ inputs, ... }:

{
  flake.modules.homeManager.codex =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.codex;
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };
    in
    {
      options.features.codex.enable = lib.mkEnableOption "Codex AI coding agent CLI";

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs-unstable.codex ];
      };
    };
}
