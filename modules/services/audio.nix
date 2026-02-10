# Audio configuration with Pipewire
_:

{
  flake.modules.nixos.audio =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      # PulseAudio utilities for compatibility with PipeWire-Pulse
      environment.systemPackages = with pkgs; [ pulseaudio ];
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
        extraConfig.pipewire-pulse."50-network" = {
          "pulse.properties" = {
            "server.address" = [
              "unix:native"
              "tcp:192.168.122.1:4713"
            ];
          };
        };
      };

      # Open firewall for PulseAudio TCP
      networking.firewall.allowedTCPPorts = [ 4713 ];
    };
}
