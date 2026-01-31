# Network configuration for one-piece
# Host-specific: hostname, WiFi backend for Qualcomm FastConnect 7800
_:

{
  networking = {
    hostName = "one-piece";

    networkmanager = {
      # Switched to wpa_supplicant for WiFi 7 MLO support with Qualcomm FastConnect 7800
      wifi.backend = "wpa_supplicant";
    };

    # iwd disabled in favor of wpa_supplicant for WiFi 7 MLO support
    wireless.iwd.enable = false;

    firewall = {
      # VTube Studio phone app
      allowedTCPPorts = [ 25565 ];
      allowedUDPPorts = [ 25565 ];
    };
  };
}
