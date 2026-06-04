# Proton Mail desktop client
_:

{
  flake.modules.homeManager.protonmail-desktop =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.protonmail-desktop;
    in
    {
      options.features.protonmail-desktop.enable = lib.mkEnableOption "Proton Mail desktop client";

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.protonmail-desktop ];
      };
    };
}
