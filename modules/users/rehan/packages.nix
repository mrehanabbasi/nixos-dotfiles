# User-specific packages for rehan
_:

{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ripgrep
        nixfmt-rfc-style
        gcc
        fzf
        zoxide
        bat
        nerd-fonts.jetbrains-mono
        noto-fonts
        nerd-fonts.iosevka
        icomoon-feather
        yazi
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
        statix # nix linter
        markdownlint-cli2

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

        zoom-us
        slack
      ];

      home.pointerCursor = {
        size = 24;
      };

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
        [Appearance]
        style=kvantum-dark

        [Fonts]
        fixed="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
        general="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
      '';
    };
}
