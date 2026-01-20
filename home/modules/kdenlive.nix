# Kdenlive - Video editor with plugin dependencies
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.kdenlive
    ffmpeg
    # Plugin dependencies
    frei0r # Video effects plugins
    ladspaPlugins # Audio effects plugins (LADSPA)
    movit # GPU-accelerated video filters
  ];

  # Environment variables for kdenlive to find plugins
  home.sessionVariables = {
    # Frei0r video effects plugins path
    FREI0R_PATH = "${pkgs.frei0r}/lib/frei0r-1";
    # LADSPA audio effects plugins path
    LADSPA_PATH = "${pkgs.ladspaPlugins}/lib/ladspa";
    # MLT plugins (kdenlive's backend)
    MLT_PROFILES_PATH = "${pkgs.mlt}/share/mlt-7/profiles";
  };
}
