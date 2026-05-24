# Discord via Vesktop - better Wayland screenshare via PipeWire, Vencord pre-bundled
_:

{
  flake.modules.homeManager.discord =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.discord;
    in
    {
      options.features.discord.enable = lib.mkEnableOption "Discord via Vesktop";

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.vesktop ];

        # Hyprland idle inhibit rule co-located with the app it governs
        wayland.windowManager.hyprland.settings.windowrule = [
          "idleinhibit focus, class:^(WebCord)$"
          "idleinhibit focus, class:^(discord|Discord)$"
        ];
      };
    };
}
