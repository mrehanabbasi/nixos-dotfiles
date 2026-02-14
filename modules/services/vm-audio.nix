# Scream virtual sound card for VM audio passthrough
# Provides low-latency audio from Windows VMs via network
_: {
  flake.modules.nixos.vm-audio =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.scream ];

      networking.firewall.allowedUDPPorts = [ 4010 ];
    };

  flake.modules.homeManager.vm-audio =
    { pkgs, ... }:
    {
      # Virtual sink setup via pactl (runs once at login)
      systemd.user.services.scream-sink-setup = {
        Unit = {
          Description = "Create virtual sink for Scream VM audio";
          After = [ "pipewire-pulse.service" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "scream-sink-setup" ''
            ${pkgs.pulseaudio}/bin/pactl load-module module-null-sink sink_name=scream_sink sink_properties=device.description=Scream_VM
            ${pkgs.pulseaudio}/bin/pactl load-module module-loopback source=scream_sink.monitor latency_msec=20
          '';
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      systemd.user.services.scream-receiver = {
        Unit = {
          Description = "Scream virtual sound card receiver";
          After = [
            "pipewire.service"
            "scream-sink-setup.service"
          ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Environment = [ "PULSE_SINK=scream_sink" ];
          ExecStart = "${pkgs.scream}/bin/scream -i virbr0 -o pulse";
          Restart = "on-failure";
          RestartSec = 3;
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
