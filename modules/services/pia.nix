# PIA VPN service
# Depends on: sops (for credentials)
_:

{
  flake.modules.nixos.pia =
    { config, ... }:
    {
      services.pia = {
        enable = true;
        credentials = {
          credentialsFile = config.sops.secrets.pia.path;
        };
        protocol = "wireguard";
      };
    };
}
