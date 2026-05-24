# OBS Studio for streaming and recording
_:

{
  flake.modules.nixos.obs-studio =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features."obs-studio";
    in
    {
      options.features."obs-studio".enable = lib.mkEnableOption "OBS Studio streaming and recording";
      config = lib.mkIf cfg.enable {
        programs.obs-studio = {
          enable = true;
          enableVirtualCamera = true;
          plugins = with pkgs.obs-studio-plugins; [
            wlrobs
            obs-vkcapture
            obs-composite-blur
          ];
        };
      };
    };
}
