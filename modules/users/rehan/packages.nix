# User-specific packages for rehan
_:

{
  flake.modules.homeManager.packages =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.features.packages;
    in
    {
      options.features.packages.enable = lib.mkEnableOption "user packages for rehan";

      config = lib.mkIf cfg.enable {
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
        ];

        home.pointerCursor = {
          size = 24;
        };
      };
    };
}
