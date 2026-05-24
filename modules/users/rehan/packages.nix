# User-specific packages for rehan
_:

{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Core utilities (not managed by feature modules)
        nixfmt-rfc-style

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
        claude-code
      ];

      home.pointerCursor = {
        size = 24;
      };
    };
}
