# Communication apps - Zoom and Slack with Hyprland idle rules
_:

{
  flake.modules.homeManager.communication =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.communication;
    in
    {
      options.features.communication.enable = lib.mkEnableOption "communication apps (Zoom, Slack)";

      config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          zoom-us
          slack
        ];

        # Hyprland idle inhibit rules co-located with the apps they govern
        wayland.windowManager.hyprland.settings.windowrule = [
          "idleinhibit focus, class:^(zoom|Zoom)$"
          "idleinhibit focus, class:^(Slack|slack)$"
          "idleinhibit focus, class:^(teams-for-linux|Microsoft Teams)$"
          "idleinhibit focus, title:(Google Meet)"
          "idleinhibit focus, title:(Microsoft Teams)"
          "idleinhibit focus, title:(Zoom Meeting)"
        ];
      };
    };
}
