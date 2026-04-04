# PIA VPN service
# Depends on: sops (for credentials)
_:

{
  flake.modules.nixos.pia =
    { config, lib, ... }:
    {
      assertions = [
        {
          assertion = config.sops.secrets ? pia;
          message = "PIA module requires sops secret 'pia' to be defined";
        }
      ];

      services.pia = {
        enable = true;
        credentials = {
          credentialsFile = config.sops.secrets.pia.path;
        };
        protocol = "wireguard";
      };
    };
}
