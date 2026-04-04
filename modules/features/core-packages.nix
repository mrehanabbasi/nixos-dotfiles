# Core system utilities and tools
# Essential packages that don't belong to specific feature modules
_:

{
  flake.modules.nixos.core-packages =
    { pkgs, ... }:
    {
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

        # Process management
        procps
        psmisc

        # Clipboard
        wl-clipboard

        # Build tools
        cmake

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
}
