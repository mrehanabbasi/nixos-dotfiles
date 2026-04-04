# OBS Studio for streaming and recording
_:

{
  flake.modules.nixos.obs-studio =
    { pkgs, ... }:
    {
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
}
