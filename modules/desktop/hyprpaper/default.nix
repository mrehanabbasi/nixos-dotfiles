# Hyprpaper - wallpaper daemon for Hyprland
{ ... }:

{
  flake.modules.homeManager.hyprpaper =
    { ... }:
    {
      services.hyprpaper = {
        enable = true;
        settings = {
          preload = "${./wallpaper.png}";
          wallpaper = [ ",${./wallpaper.png}" ];
        };
      };
    };
}
