# GPG configuration with public key
_:

{
  flake.modules.nixos.gpg =
    { pkgs, ... }:
    {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-qt;
      };
    };

  flake.modules.homeManager.gpg = _: {
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
}
