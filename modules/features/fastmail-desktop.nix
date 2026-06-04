# Fastmail desktop client
_:

{
  flake.modules.homeManager.fastmail-desktop =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.fastmail-desktop;
    in
    {
      options.features.fastmail-desktop.enable = lib.mkEnableOption "Fastmail desktop client";

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.fastmail-desktop ];
      };
    };
}
