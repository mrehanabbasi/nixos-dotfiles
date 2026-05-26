# SOPS secrets management
_:

{
  flake.modules.nixos.sops =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.sops;
    in
    {
      options.features.sops.enable = lib.mkEnableOption "SOPS secrets management";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ sops age ];

        sops = {
          defaultSopsFile = ./secrets.yaml;
          defaultSopsFormat = "yaml";

          age.keyFile = "${config.users.users.rehan.home}/.config/sops/age/keys.txt";
        };
      };
    };
}
