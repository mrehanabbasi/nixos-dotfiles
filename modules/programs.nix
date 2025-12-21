# System programs configuration
{
  pkgs,
  hyprshutdown,
  system,
  ...
}:

{
  programs = {
    hyprlock.enable = true;

    # Shell
    zsh.enable = true;

    # Editors
    neovim = {
      enable = true;
      defaultEditor = true;
    };

    # GPG Agent
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };

    # Device connectivity
    kdeconnect.enable = true;

    # AppImage support
    appimage = {
      enable = true;
      binfmt = true;
    };

    # OBS Studio
    obs-studio.enable = true;

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

  # System packages
  environment.systemPackages = with pkgs; [
    # Core utilities
    wget
    git
    unzip
    net-tools
    btop
    procps
    psmisc
    wl-clipboard
    tree
    networkmanager
    cmake

    # Terminal
    ghostty

    # Hyprland ecosystem
    hyprpaper
    hyprshot
    hyprpicker
    rofi
    hyprpanel
    hyprshutdown.packages.${system}.hyprshutdown

    # HyprPanel dependencies
    ags # aylurs-gtk-shell-git
    # wireplumber # via services.pipewire.wireplumber.enable
    libgtop
    bluez
    bluez-tools # bluez-utils
    # networkmanager
    # dart-sass # Might need nix-dart
    # wl-clipboard
    # upower # via service.upower.enable
    # gvfs # via services.gvfs.enable
    gtksourceview # gtksourceview3
    libsoup_3

    # Browsers
    brave
    librewolf # Firefox replacement

    # File managers
    kdePackages.dolphin

    # Filesystem support
    ntfs3g
    kdePackages.kio
    kdePackages.kio-extras

    # Theming
    catppuccin-cursors.mochaBlue

    # Media
    mpv

    # Office
    onlyoffice-desktopeditors

    # Container tools
    dive
    podman-tui
    docker-compose

    testdisk
    testdisk-qt
  ];
}
