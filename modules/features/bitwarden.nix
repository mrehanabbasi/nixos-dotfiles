# Bitwarden password manager - desktop app and rbw CLI backend
_:

{
  flake.modules.homeManager.bitwarden =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.bitwarden;
    in
    {
      options.features.bitwarden.enable = lib.mkEnableOption "Bitwarden password manager";

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.bitwarden-desktop ];

        # rbw - Bitwarden CLI backend for dankBitwarden DMS plugin
        programs.rbw = {
          enable = true;
          settings = {
            email = "mrehanabbasi@proton.me";
            pinentry = pkgs.pinentry-qt;
            base_url = "https://vaultwarden.mrehanabbasi.com";
          };
        };
      };
    };
}
