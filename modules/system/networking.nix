# Base network configuration (shared across hosts)
# Host-specific settings (hostname, wifi backend) go in hosts/<name>/network.nix
_:

{
  flake.modules.nixos.networking =
    _:
    {
      networking = {
        timeServers = [ "pool.ntp.org" ];

        # NetworkManager for network management
        # Host-specific wifi.backend configured in host module
        networkmanager.enable = true;

        # Firewall enabled by default
        # Host-specific ports configured in host module
        firewall.enable = true;
      };
    };
}
