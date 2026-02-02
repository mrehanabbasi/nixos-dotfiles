# Hyprpaper - wallpaper daemon for Hyprland
_:

{
  flake.modules.homeManager.hyprpaper = _: {
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = "${./wallpaper.png}";
        wallpaper = [ ",${./wallpaper.png}" ];
      };
    };
  };
}
