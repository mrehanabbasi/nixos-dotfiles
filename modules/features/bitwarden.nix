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
        # pkgs.bitwarden-desktop in 26.05 uses electron-39 (EOL/insecure).
        # Use unstable which has 2026.3.1 with a supported electron.
        home.packages = [ pkgs-unstable.bitwarden-desktop ];

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
