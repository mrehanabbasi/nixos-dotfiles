# Catppuccin theming - NixOS and Home Manager
# DMS handles GTK/Qt theming via Matugen; this module provides cursor and base settings
_:

{
  flake.modules.nixos.catppuccin =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.features.catppuccin;
    in
    {
      options.features.catppuccin.enable = lib.mkEnableOption "Catppuccin theme";

      config = lib.mkIf cfg.enable {
        # Cursor theme (DMS handles GTK/Qt theming, but cursor is set system-wide)
        environment.systemPackages = with pkgs; [
          catppuccin-cursors.mochaBlue
        ];

        catppuccin.gtk.icon.enable = false;
      };
    };

  flake.modules.homeManager.catppuccin =
    { lib, config, ... }:
    let
      cfg = config.features.catppuccin;
    in
    {
      options.features.catppuccin.enable = lib.mkEnableOption "Catppuccin theme";

      config = lib.mkIf cfg.enable {
        # Base catppuccin settings for accent/flavor (DMS uses these for Matugen)
        catppuccin = {
          accent = "blue";
          flavor = "mocha";
        };

        # Catppuccin cursor theme (DMS handles GTK/Qt, but cursor needs explicit config)
        catppuccin.cursors.enable = true;

        # Pointer cursor with GTK integration
        home.pointerCursor.gtk.enable = true;
      };
    };
}
