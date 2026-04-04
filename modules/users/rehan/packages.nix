# User-specific packages for rehan
_:

{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Core utilities (not managed by feature modules)
        ripgrep
        nixfmt-rfc-style
        gcc

        # Fonts (nerd-fonts.jetbrains-mono is in system/fonts.nix)
        noto-fonts
        nerd-fonts.iosevka
        icomoon-feather

        # Media utilities
        cava
        imv
        mpc
        pamixer
        alsa-utils

        # GUI utilities
        nwg-look
        kdePackages.kalk

        # Neovim-related (LSPs, formatters, build tools)
        gnumake
        just
        zig
        nil
        go
        gopls
        gofumpt
        golangci-lint
        nodePackages_latest.vscode-json-languageserver
        yaml-language-server
        lua-language-server
        docker-language-server
        typescript
        typescript-language-server
        tailwindcss-language-server
        tree-sitter
        nodejs
        statix # nix linter
        markdownlint-cli2
        addlicense

        # Qt theming
        libsForQt5.qtstyleplugin-kvantum
        libsForQt5.qt5ct

        # CLI tools
        jq
        jless
        yq

        # Applications
        vlc
        webcord
        bitwarden-desktop
        notesnook
        claude-code
        blender
        unityhub

        # Communication
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
