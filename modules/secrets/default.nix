# SOPS secrets management
_:

{
  flake.modules.nixos.sops =
    { config, ... }:
    {
      sops = {
        defaultSopsFile = ./secrets.yaml;
        defaultSopsFormat = "yaml";

        age.keyFile = "${config.users.users.rehan.home}/.config/sops/age/keys.txt";

        secrets.pia = {
          format = "yaml";
        };
      };
    };
}
