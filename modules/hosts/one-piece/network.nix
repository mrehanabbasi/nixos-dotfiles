# Network configuration for one-piece
# Host-specific: hostname, WiFi backend for Qualcomm FastConnect 7800
_:

{
  flake.modules.nixos.one-piece-network = _: {
    # Guests sit on libvirt's default NAT network. Features that need to reach
    # a VM scope themselves to this interface rather than to an address.
    host.vmBridge = "virbr0";

    networking = {
      hostName = "one-piece";

      networkmanager = {
        # Switched to wpa_supplicant for WiFi 7 MLO support with Qualcomm FastConnect 7800
        wifi.backend = "wpa_supplicant";
      };

      # iwd disabled in favor of wpa_supplicant for WiFi 7 MLO support
      wireless.iwd.enable = false;
    };
  };
}
