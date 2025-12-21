{ ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = "${../../wallpapers/one_liner.png}";
      wallpaper = [
        ",${../../wallpapers/one_liner.png}"
      ];
    };
  };
}
