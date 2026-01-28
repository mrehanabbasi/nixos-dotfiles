# Kdenlive - Video editor with plugin dependencies
{ ... }:

{
  flake.modules.homeManager.kdenlive = { pkgs, ... }: {
    home.packages = with pkgs; [
      kdePackages.kdenlive
      ffmpeg
      frei0r
      ladspaPlugins
      movit
    ];

    home.sessionVariables = {
      FREI0R_PATH = "${pkgs.frei0r}/lib/frei0r-1";
      LADSPA_PATH = "${pkgs.ladspaPlugins}/lib/ladspa";
      MLT_PROFILES_PATH = "${pkgs.mlt}/share/mlt-7/profiles";
    };
  };
}
