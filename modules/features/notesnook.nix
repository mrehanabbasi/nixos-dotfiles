# Notesnook - encrypted note-taking app
_:

{
  flake.modules.homeManager.notesnook =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.notesnook;
    in
    {
      options.features.notesnook.enable = lib.mkEnableOption "Notesnook note-taking app";

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.notesnook ];
      };
    };
}
