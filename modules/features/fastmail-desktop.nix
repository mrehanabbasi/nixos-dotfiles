# Fastmail desktop client
# Uses nixpkgs-unstable; overrides src to 1.6.0 (1.4.0 AppImage was pulled from CDN)
{ inputs, ... }:

{
  flake.modules.homeManager.fastmail-desktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.fastmail-desktop;
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };
      fastmail-desktop =
        (pkgs-unstable.callPackage (pkgs-unstable.path + "/pkgs/by-name/fa/fastmail-desktop/linux.nix") {
          pname = "fastmail-desktop";
          version = "1.6.0";
          src = pkgs-unstable.fetchurl {
            url = "https://dl.fastmailcdn.com/desktop/production/linux/x64/com.fastmail.Fastmail-1.6.0.AppImage";
            hash = "sha256-FOmxv40+3t0/Y9+Mz7dhUzAiewDbexl3mZAD5tLGZMs=";
          };
          passthru = { };
          meta = pkgs-unstable.fastmail-desktop.meta;
        }).overrideAttrs
          (_: {
            preFixup = ''
              rm -rf "$out/opt/fastmail/app.asar.unpacked/node_modules/@img/sharp-linuxmusl-x64" || true
              rm -rf "$out/opt/fastmail/app.asar.unpacked/node_modules/@img/sharp-libvips-linuxmusl-x64" || true
            '';
          });
    in
    {
      options.features.fastmail-desktop.enable = lib.mkEnableOption "Fastmail desktop client";

      config = lib.mkIf cfg.enable {
        home.packages = [ fastmail-desktop ];
      };
    };
}
