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
