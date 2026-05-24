# Core system utilities and tools
# Essential packages that don't belong to specific feature modules
_:

{
  flake.modules.nixos.core-packages =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features."core-packages";
    in
    {
      options.features."core-packages".enable = lib.mkEnableOption "core system utilities and tools";
      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          # Core utilities
          wget
          git
          tree

          # Archive tools
          unzip
          zip
          unrar
          p7zip
          gnutar
          gzip
          xz

          # Network tools
          net-tools
          dnsutils
          networkmanager

          # Hardware tools
          usbutils

          # Process management
          procps
          psmisc

          # Clipboard
          wl-clipboard

          # Build tools
          cmake
          ripgrep
          gnumake
          just
          zig
          gcc

          # Office
          onlyoffice-desktopeditors

          # Container tools
          dive
          podman-tui
          docker-compose

          # Recovery tools
          testdisk
          testdisk-qt
        ];
      };
    };
}
