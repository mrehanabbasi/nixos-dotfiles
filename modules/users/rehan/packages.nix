# User-specific packages for rehan
{ ... }:

{
  flake.modules.homeManager.packages = { pkgs, ... }: {
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
      eza
      fastfetch
      cava
      imv
      nwg-look
      zathura
      mpc
      pamixer
      alsa-utils
      kdePackages.kalk

      # Neovim-related
      gnumake
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
      webcord
      bitwarden-desktop
      notesnook
      claude-code
      blender
      unityhub
    ];

    home.pointerCursor = { size = 24; };

    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    xdg.configFile."qt5ct/qt5ct.conf".text = ''
      [Fonts]
      fixed="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
      general="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
    '';
    xdg.configFile."qt6ct/qt6ct.conf".text = ''
      [Fonts]
      fixed="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
      general="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
    '';
  };
}
