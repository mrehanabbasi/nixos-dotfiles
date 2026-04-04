# SwayNC notification center with Catppuccin theming
# Depends on: catppuccin (for theming)
_:

{
  flake.modules.homeManager.swaync =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.libnotify ];

      catppuccin.swaync = {
        enable = true;
        flavor = "mocha";
      };

      services.swaync = {
        enable = true;
        settings = {
          positionX = "right";
          positionY = "top";
          control-center-width = 400;
          notification-window-width = 400;
          layer = "overlay";
          timeout = 5;
          timeout-low = 3;
          timeout-critical = 0;
          transition-time = 200;
          hide-on-action = true;
          widgets = [
            "title"
            "dnd"
            "notifications"
            "mpris"
          ];
          widget-config = {
            title = {
              text = "Notifications";
              clear-all-button = true;
              button-text = "Clear All";
            };
            dnd = {
              text = "Do Not Disturb";
            };
          };
        };
      };
    };
}
