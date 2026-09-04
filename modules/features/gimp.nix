# GIMP - image editor
_:

{
  flake.modules.homeManager.gimp =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.gimp;
    in
    {
      options.features.gimp.enable = lib.mkEnableOption "GIMP image editor";

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.gimp3 ];
      };
    };
}
