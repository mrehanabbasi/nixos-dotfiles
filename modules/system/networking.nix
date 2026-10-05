# Base network configuration (shared across hosts)
# Host-specific settings (hostname, wifi backend) go in hosts/<name>/network.nix
_:

{
  flake.modules.nixos.networking =
    { config, lib, ... }:
    let
      cfg = config.features.networking;
    in
    {
      options.features.networking.enable = lib.mkEnableOption "system networking";

      config = lib.mkIf cfg.enable {
        networking = {
          timeServers = [ "pool.ntp.org" ];

          # NetworkManager for network management
          # Host-specific wifi.backend configured in host module
          networkmanager = {
            enable = true;

            # Leave the radio awake. rtw89 (and most drivers) stall an
            # associated link when power save parks the RX path, which reads as
            # "WiFi connected, no traffic".
            wifi.powersave = false;

            # WARN hides roam and connection-switch events, which are exactly
            # what a silent drop needs to be diagnosed from.
            logLevel = "INFO";
          };

          # Firewall enabled by default
          # Host-specific ports configured in host module
          firewall.enable = true;
        };

        # Use systemd-resolved for DNS
        # Provides proper split DNS support (Tailscale domains via MagicDNS, rest via normal DNS)
        services.resolved.enable = true;
      };
    };
}
