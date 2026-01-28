# SOPS secrets management
{ ... }:

{
  flake.modules.nixos.sops =
    { ... }:
    {
      sops = {
        defaultSopsFile = ./secrets.yaml;
        defaultSopsFormat = "yaml";

        age.keyFile = "/home/rehan/.config/sops/age/keys.txt";

        secrets.pia = {
          format = "yaml";
        };
      };
    };
}
