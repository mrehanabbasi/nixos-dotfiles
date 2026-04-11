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
        imv
        mpc
        alsa-utils

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
    };
}
