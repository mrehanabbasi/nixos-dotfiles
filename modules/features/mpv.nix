# mpv - Media player with Catppuccin theme
_:

{
  flake.modules.homeManager.mpv =
    { config, lib, ... }:
    let
      cfg = config.features.mpv;
    in
    {
      options.features.mpv.enable = lib.mkEnableOption "mpv media player";
      config = lib.mkIf cfg.enable {
        catppuccin.mpv.enable = true;

        programs.mpv = {
          enable = true;
        };
      };
    };
}
