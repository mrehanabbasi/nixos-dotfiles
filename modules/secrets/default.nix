# SOPS secrets management
_:

{
  flake.modules.nixos.sops =
    { config, lib, ... }:
    let
      cfg = config.features.sops;
    in
    {
      options.features.sops.enable = lib.mkEnableOption "SOPS secrets management";

      config = lib.mkIf cfg.enable {
        sops = {
          defaultSopsFile = ./secrets.yaml;
          defaultSopsFormat = "yaml";

          age.keyFile = "${config.users.users.rehan.home}/.config/sops/age/keys.txt";

          secrets.pia = {
            format = "yaml";
          };
        };
      };
    };
}
