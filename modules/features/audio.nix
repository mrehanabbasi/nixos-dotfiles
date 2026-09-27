# Audio configuration with Pipewire
_:

{
  flake.modules.nixos.audio =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.audio;
    in
    {
      options.features.audio = {
        enable = lib.mkEnableOption "audio configuration with Pipewire";

        # Off by default: which interface carries VM audio is a host fact, and
        # enabling this punches a hole in the firewall. Hosts that stream audio
        # out of a VM turn it on; see also features.vm-audio.
        pulseNetwork = {
          enable = lib.mkEnableOption "PulseAudio TCP server, for streaming audio to/from VMs";

          interfaces = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = lib.optional (config.host.vmBridge != null) config.host.vmBridge;
            defaultText = lib.literalExpression "[ config.host.vmBridge ]";
            example = [ "virbr0" ];
            description = ''
              Interfaces the PulseAudio port is reachable on, named rather than
              addressed so nothing has to know a bridge's subnet. Defaults to
              the bridge the host declared its VMs sit on.

              PipeWire's pulse server has no per-interface bind, so it listens
              on every address and the firewall does the scoping: the port is
              opened only on these interfaces. Leaving the list empty means the
              server runs but is unreachable from outside the host.
            '';
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 4713;
            description = "TCP port for the PulseAudio server.";
          };
        };
      };
      config = lib.mkIf cfg.enable {
        # Audio control tools
        environment.systemPackages = with pkgs; [
          pulseaudio # PulseAudio utilities for compatibility with PipeWire-Pulse
          pavucontrol # PulseAudio/PipeWire volume control GUI
          qpwgraph # PipeWire graph manager/patchbay
        ];
        services.pipewire = {
          enable = true;
          audio.enable = true;
          pulse.enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
          jack.enable = true;
          wireplumber.enable = true;

          # Enable high-quality Bluetooth audio codecs
          extraConfig.pipewire."92-low-latency" = {
            "context.properties" = {
              "default.clock.rate" = 48000;
              "default.clock.quantum" = 1024;
              "default.clock.min-quantum" = 512;
              "default.clock.max-quantum" = 2048;
            };
          };

          # Configure Bluetooth codecs for better device compatibility
          wireplumber.configPackages = [
            (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
              bluez_monitor.properties = {
                ["bluez5.enable-sbc-xq"] = true,
                ["bluez5.enable-msbc"] = true,
                ["bluez5.enable-hw-volume"] = true,
                ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]",
              }
            '')
          ];

          # Configure PulseAudio server to listen on network for VM audio streaming
          extraConfig.pipewire-pulse = lib.optionalAttrs cfg.pulseNetwork.enable {
            "50-network" = {
              "pulse.properties" = {
                "server.address" = [
                  "unix:native"
                  "tcp:${toString cfg.pulseNetwork.port}"
                ];
              };
            };
          };
        };

        # Reachability is scoped per interface rather than opened host-wide,
        # since the server itself binds to every address.
        networking.firewall.interfaces = lib.optionalAttrs cfg.pulseNetwork.enable (
          lib.genAttrs cfg.pulseNetwork.interfaces (_: {
            allowedTCPPorts = [ cfg.pulseNetwork.port ];
          })
        );
      };
    };
}
