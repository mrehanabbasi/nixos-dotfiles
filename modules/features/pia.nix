# PIA VPN service
# Depends on: sops (for credentials)
_:

{
  flake.modules.nixos.pia =
    { config, lib, ... }:
    let
      cfg = config.features.pia;
    in
    {
      options.features.pia.enable = lib.mkEnableOption "PIA VPN service";
      config = lib.mkIf cfg.enable {
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
    };
}
