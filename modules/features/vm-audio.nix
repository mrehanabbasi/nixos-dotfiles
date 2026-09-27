# Scream virtual sound card for VM audio passthrough
# Provides low-latency audio from Windows VMs via network
_:

{
  flake.modules.nixos.vm-audio =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features."vm-audio";
    in
    {
      options.features."vm-audio".enable = lib.mkEnableOption "VM audio passthrough via Scream";
      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ pkgs.scream ];

        networking.firewall.allowedUDPPorts = [ 4010 ];
      };
    };

  flake.modules.homeManager.vm-audio =
    {
      config,
      lib,
      pkgs,
      osConfig ? null,
      ...
    }:
    let
      cfg = config.features."vm-audio";

      # Machine facts from the NixOS side (see modules/system/host.nix).
      host = if osConfig == null then { } else osConfig.host or { };
    in
    {
      options.features."vm-audio" = {
        enable = lib.mkEnableOption "VM audio passthrough via Scream";

        interface = lib.mkOption {
          type = lib.types.str;
          default = host.vmBridge or "virbr0";
          defaultText = lib.literalExpression "osConfig.host.vmBridge";
          example = "br0";
          description = ''
            Network interface the Scream receiver listens on. Follows the
            bridge the host declared its VMs sit on; libvirt's NAT bridge is
            the fallback. Point it somewhere real - bound to an interface that
            does not exist, the unit restart-loops silently.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
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
              # Only create sink if it doesn't already exist
              if ! ${pkgs.pulseaudio}/bin/pactl list sinks short | grep -q scream_sink; then
                ${pkgs.pulseaudio}/bin/pactl load-module module-null-sink sink_name=scream_sink sink_properties=device.description=Scream_VM
                ${pkgs.pulseaudio}/bin/pactl load-module module-loopback source=scream_sink.monitor latency_msec=20
              fi
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
            ExecStart = "${pkgs.scream}/bin/scream -i ${cfg.interface} -o pulse";
            Restart = "on-failure";
            RestartSec = 3;
          };

          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      };
    };
}
