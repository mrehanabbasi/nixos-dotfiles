# mpv - Media player with Catppuccin theme
_:

{
  flake.modules.homeManager.mpv = _: {
    catppuccin.mpv.enable = true;

    programs.mpv = {
      enable = true;
    };
  };
}
