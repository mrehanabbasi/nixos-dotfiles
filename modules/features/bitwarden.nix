# Bitwarden password manager - desktop app and rbw CLI backend
# Uses nixpkgs-unstable for rbw 1.15.0 (--fields type support for dankBitwarden)
{ inputs, ... }:

{
  flake.modules.homeManager.bitwarden =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.bitwarden;
      pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv.hostPlatform) system; inherit (pkgs) config; };
    in
    {
      options.features.bitwarden.enable = lib.mkEnableOption "Bitwarden password manager";

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.bitwarden-desktop ];

        # rbw - Bitwarden CLI backend for dankBitwarden DMS plugin
        programs.rbw = {
          enable = true;
          package = pkgs-unstable.rbw;
          settings = {
            email = "mrehanabbasi@proton.me";
            pinentry = pkgs.pinentry-qt;
            base_url = "https://vaultwarden.mrehanabbasi.com";
          };
        };
      };
    };
}
