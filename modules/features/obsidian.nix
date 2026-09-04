# Obsidian - knowledge base app (nixpkgs-unstable for latest release)
{ inputs, ... }:

{
  flake.modules.homeManager.obsidian =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.obsidian;
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };
    in
    {
      options.features.obsidian.enable = lib.mkEnableOption "Obsidian knowledge base app";

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs-unstable.obsidian ];
      };
    };
}
