# Catppuccin theming - NixOS and Home Manager
# DMS handles GTK/Qt theming via Matugen; this module provides cursor and base settings
_:

{
  flake.modules.nixos.catppuccin =
    { pkgs, lib, ... }:
    {
      # Compatibility shim: define services.displayManager.generic for catppuccin gtk module
      # This option was removed in NixOS 25.11 but catppuccin/nix still references it
      options.services.displayManager.generic.environment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Compatibility shim for catppuccin/nix (unused)";
      };

      config = {
        # Cursor theme (DMS handles GTK/Qt theming, but cursor is set system-wide)
        environment.systemPackages = with pkgs; [
          catppuccin-cursors.mochaBlue
        ];

        # Disable catppuccin gtk icon (uses the shimmed option above)
        catppuccin.gtk.icon.enable = false;
      };
    };

  flake.modules.homeManager.catppuccin = _: {
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
}
