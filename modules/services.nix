# System services configuration
{ ... }:

{
  services = {
    hypridle.enable = true;

    # Audio with Pipewire
    pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      wireplumber.enable = true;
    };

    # Tailscale VPN
    tailscale.enable = true;

    gvfs.enable = true; # Required for HyprPanel
    upower.enable = true; # Required for HyprPanel
    blueman.enable = true;
    libinput.enable = true;
    power-profiles-daemon.enable = true;
  };
}
