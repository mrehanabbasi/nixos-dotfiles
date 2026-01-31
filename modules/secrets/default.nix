# SOPS secrets management
_:

{
  flake.modules.nixos.sops =
    _:
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
