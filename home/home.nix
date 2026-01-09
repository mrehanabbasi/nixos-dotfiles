{
  config,
  pkgs,
  opencode,
  ...
}:

{
  home = {
    username = "rehan";
    homeDirectory = "/home/rehan";
    stateVersion = "25.11";
    pointerCursor = {
      size = 24;
    };
  };

  xdg.enable = true;

  catppuccin = {
    # enable = true; # To prevent applying theme to all
    accent = "blue";
    flavor = "mocha";
    kvantum = {
      enable = true;
      apply = true;
    };
    cursors.enable = true;
    mpv.enable = true;
    lazygit.enable = true;
    eza.enable = true;
  };

  home.packages = with pkgs; [
    ripgrep
    nixpkgs-fmt
    gcc
    fzf
    zoxide
    bat
    nerd-fonts.jetbrains-mono
    noto-fonts
    nerd-fonts.iosevka
    icomoon-feather
    yazi
    eza # better ls
    fastfetch
    cava # audio visualizer
    imv # Image viewer
    # dunst # Notifications
    nwg-look # GTK Theme Manager
    zathura # PDF viewer
    mpc
    pamixer
    alsa-utils
    kdePackages.kalk

    # Neovim-related
    zig
    nil
    go
    gopls
    gofumpt
    nodePackages_latest.vscode-json-languageserver
    yaml-language-server
    lua-language-server
    docker-language-server
    typescript
    typescript-language-server
    tailwindcss-language-server
    tree-sitter
    lazygit
    nodejs

    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct

    jq
    yq
    vlc
    webcord # Discord replacement
    bitwarden-desktop
    notesnook
    claude-code
  ];

  # Enable Catppuccin theme in Qt applications like Dolphin
  # Tell qt to use Kavantum / qtct
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  imports = [
    (import ./modules/tmux.nix { inherit pkgs; })
    (import ./modules/zsh.nix { inherit config pkgs; })
    (import ./modules/neovim.nix { inherit config; })
    (import ./modules/git.nix { inherit pkgs; })
    (import ./modules/gpg.nix { })
    (import ./modules/zoxide.nix { })
    (import ./modules/fzf.nix { })
    (import ./modules/oh-my-posh.nix { inherit pkgs; })
    (import ./modules/ghostty.nix { })
    (import ./modules/opencode.nix { inherit pkgs opencode; })
    (import ./modules/hyprlock.nix { inherit config; })
    (import ./modules/zathura.nix { })
    (import ./modules/bat.nix { })
    (import ./modules/fastfetch.nix { })
    (import ./modules/btop.nix { })
    (import ./modules/cava.nix { inherit config; })
    (import ./modules/yazi.nix { })
    (import ./modules/rofi.nix { })
    (import ./modules/hypridle.nix { })
    (import ./modules/hyprpaper.nix { })
    (import ./modules/kdeconnect.nix { })
    (import ./modules/mime-apps.nix { })
    (import ./modules/hyprland.nix { })
  ];
}
