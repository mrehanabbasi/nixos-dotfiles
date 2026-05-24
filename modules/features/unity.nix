# Unity Hub - game engine and editor launcher
_:

{
  flake.modules.homeManager.unity =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.unity;
    in
    {
      options.features.unity.enable = lib.mkEnableOption "Unity Hub game engine launcher";

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.unityhub ];
      };
    };
}
