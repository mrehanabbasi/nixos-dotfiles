# Fastmail desktop client
# Uses nixpkgs-unstable; overrides src to 1.8.0 (older AppImages get pulled from
# the CDN, so unstable's pinned 1.4.0 no longer downloads)
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
          version = "1.8.0";
          src = pkgs-unstable.fetchurl {
            url = "https://dl.fastmailcdn.com/desktop/production/linux/x64/com.fastmail.Fastmail-1.8.0.AppImage";
            hash = "sha512-t5Ygan37PcUpt2z4bAEpUbtEO4TlBM4QLkP2ycfhaBxQD9L/pJH4iWI+SL4emg4oWZSJk0GnehlWhCosayiIlQ==";
          };
          passthru = { };
          meta = pkgs-unstable.fastmail-desktop.meta;
        }).overrideAttrs
          (_: {
            # Upstream only drops the musl sharp builds here. The glibc ones are
            # kept and autoPatchelf'd, but loading them segfaults the Electron
            # main process before any window is created, so the app silently
            # never starts. sharp is optional (lib/app/sharp-shim.js catches the
            # require and carries on), so remove it outright.
            preFixup = ''
              rm -rf "$out/opt/fastmail/app.asar.unpacked/node_modules/@img"
              rm -rf "$out/opt/fastmail/app.asar.unpacked/node_modules/sharp"
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
