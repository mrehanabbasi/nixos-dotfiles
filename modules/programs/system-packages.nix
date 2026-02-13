# Core system packages
_:

{
  flake.modules.nixos.system-packages =
    { pkgs, ... }:
    {
      programs = {
        localsend.enable = true;

        appimage = {
          enable = true;
          binfmt = true;
        };

        obs-studio = {
          enable = true;
          enableVirtualCamera = true;
          plugins = with pkgs.obs-studio-plugins; [
            wlrobs
            obs-vkcapture
            obs-composite-blur
          ];
        };

        thunar = {
          enable = true;
          plugins = with pkgs.xfce; [
            thunar-volman
            thunar-archive-plugin
          ];
        };

        dconf.profiles.user.databases = [
          {
            settings."org/gnome/desktop/interface" = {
              gtk-theme = "Catppuccin Mocha Blue";
              icon-theme = "Catppuccin Mocha Blue";
              font-name = "JetBrainsMono Nerd Font";
              document-font-name = "JetBrainsMono Nerd Font";
              monospace-font-name = "JetBrainsMono Nerd Font";
            };
          }
        ];
      };

      environment.systemPackages = with pkgs; [
        # Core utilities
        wget
        git
        unzip
        unrar
        p7zip # 7zip support

        # Archive manager (backend for thunar-archive-plugin)
        xarchiver
        net-tools
        btop
        procps
        psmisc
        wl-clipboard
        tree
        networkmanager
        cmake
        dnsutils

        # Filesystem support
        ntfs3g
        gvfs # Virtual filesystem support for Thunar

        # Theming
        catppuccin-cursors.mochaBlue

        # Media
        mpv
        qpwgraph # PipeWire graph manager/patchbay
        pavucontrol # PulseAudio/PipeWire volume control

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

      services = {
        blueman.enable = true;
        libinput.enable = true;
        power-profiles-daemon.enable = true;
      };
    };
}
