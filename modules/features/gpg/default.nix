# GPG configuration with public key
_:

{
  flake.modules.nixos.gpg =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.gpg;
    in
    {
      options.features.gpg.enable = lib.mkEnableOption "GPG key management";

      config = lib.mkIf cfg.enable {
        programs.gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
          pinentryPackage = pkgs.pinentry-qt;
        };
      };
    };

  flake.modules.homeManager.gpg =
    { config, lib, ... }:
    let
      cfg = config.features.gpg;
    in
    {
      options.features.gpg.enable = lib.mkEnableOption "GPG key management";

      config = lib.mkIf cfg.enable {
        programs.gpg = {
          enable = true;
          publicKeys = [
            {
              source = ./public-key.asc;
              trust = "ultimate";
            }
          ];
        };

        services.gpg-agent = {
          enable = true;
          enableZshIntegration = true;
        };
      };
    };
}
