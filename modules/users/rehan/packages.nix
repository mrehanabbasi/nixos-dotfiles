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
        mediainfo
        ffmpegthumbnailer
        imagemagick

        # CLI tools
        gh
        jq
        jless
        yq

        # Git/shell tooling
        delta
        shellcheck
        shfmt

        # Nix tooling
        nix-tree

        # Encryption
        age

        # Applications
        vesktop
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
