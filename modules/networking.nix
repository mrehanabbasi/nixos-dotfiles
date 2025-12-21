# Network configuration
{ ... }:

{
  networking = {
    hostName = "one-piece";
    timeServers = [ "pool.ntp.org" ];

    # Configure network connections interactively with nmcli or nmtui.
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    wireless = {
      iwd = {
        enable = true;
        settings = {
          Settings = {
            AutoConnect = true;
          };
        };
      };
    };
  };
}
