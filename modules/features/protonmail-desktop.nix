# Proton Mail desktop client
# Uses nixpkgs-unstable for latest version
{ inputs, ... }:

{
  flake.modules.homeManager.protonmail-desktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.protonmail-desktop;
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };
    in
    {
      options.features.protonmail-desktop.enable = lib.mkEnableOption "Proton Mail desktop client";

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs-unstable.protonmail-desktop ];
      };
    };
}
