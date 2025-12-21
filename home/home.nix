{ config, pkgs, ... }:

{
  home = {
    username = "rehan";
    homeDirectory = "/home/rehan";
    stateVersion = "25.11";
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

    opencode
    jq
    yq
    vlc
    webcord # Discord replacement
    bitwarden-desktop
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
    (import ./modules/opencode.nix { })
    (import ./modules/hyprlock.nix { inherit config; })
    (import ./modules/zathura.nix { })
    (import ./modules/bat.nix { })
    (import ./modules/fastfetch.nix { })
    (import ./modules/btop.nix { })
    (import ./modules/cava.nix { inherit config; })
    (import ./modules/yazi.nix { })
    (import ./modules/rofi.nix { })
  ];

  services.kdeconnect = {
    enable = true;
    indicator = true; # optional: tray icon (needs a tray)
  };

  xdg.desktopEntries.neovimGhostty = {
    name = "Neovim in Ghostty";
    exec = "ghostty -e nvim %F";
    terminal = false;
    mimeType = [ "text/plain" ];
    icon = "utilities-terminal";
    comment = "Edit text files in Neovim using Ghostty";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = [ "neovimGhostty.desktop" ];
      "text/html" = [ "brave-browser.desktop" ];
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
      "x-scheme-handler/about" = [ "brave-browser.desktop" ];
      "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session"; # lock before suspend
        after_sleep_cmd = "hyprctl dispatch dpms one";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpmn on";
        }
        # {
        #   timeout = 900;
        #   on-timeout = "systemctl suspend";
        # }
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = "${../wallpapers/one_liner.png}";
      wallpaper = [
        ",${../wallpapers/one_liner.png}"
      ];
    };
  };
}
