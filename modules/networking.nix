# Network configuration
{ ... }:

{
  networking = {
    hostName = "one-piece";
    timeServers = [ "pool.ntp.org" ];

    # Configure network connections interactively with nmcli or nmtui.
    networkmanager = {
      enable = true;
      # Switched to wpa_supplicant for WiFi 7 MLO support with Qualcomm FastConnect 7800
      wifi.backend = "wpa_supplicant";
      # wifi.backend = "iwd";  # Previous backend
    };

    # iwd disabled in favor of wpa_supplicant for WiFi 7 MLO support
    wireless.iwd.enable = false;

    # Previous iwd configuration (commented out for rollback if needed)
    # wireless = {
    #   iwd = {
    #     enable = true;
    #     settings = {
    #       Settings = {
    #         AutoConnect = true;
    #       };
    #     };
    #   };
    # };

    # Firewall configuration
    firewall = {
      enable = true;
      # VTube Studio phone app
      allowedTCPPorts = [ 25565 ];
      allowedUDPPorts = [ 25565 ];
    };
  };
}
