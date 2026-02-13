# PipeWire-based idle inhibition for media playback
# Inhibits idle when microphone, camera, or audio playback is active
_: {
  flake.modules.homeManager.idle-inhibit-media =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.wayland-pipewire-idle-inhibit ];

      xdg.configFile."wayland-pipewire-idle-inhibit/config.toml".text = ''
        [media_role."Audio/Source"]
        actions = ["idle"]

        [media_role."Video/Source"]
        actions = ["idle"]

        [media_role."Stream/Output/Audio"]
        actions = ["idle"]
      '';

      systemd.user.services.wayland-pipewire-idle-inhibit = {
        Unit = {
          Description = "PipeWire-based idle inhibitor for media activity";
          After = [
            "pipewire.service"
            "wireplumber.service"
            "graphical-session.target"
          ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.wayland-pipewire-idle-inhibit}/bin/wayland-pipewire-idle-inhibit";
          Restart = "on-failure";
          RestartSec = 5;
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
