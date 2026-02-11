# Catppuccin theming - NixOS and Home Manager
_:

{
  flake.modules.nixos.catppuccin = _: {
    # NixOS-level catppuccin settings are applied via the catppuccin.nixosModules.catppuccin
    # which is imported in the host definition
  };

  flake.modules.homeManager.catppuccin = _: {
    # Global catppuccin settings (app-specific settings are in each app's module)
    catppuccin = {
      accent = "blue";
      flavor = "mocha";
    };
  };
}
