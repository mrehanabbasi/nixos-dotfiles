# Catppuccin theming - NixOS and Home Manager
_:

{
  flake.modules.nixos.catppuccin =
    _:
    {
      # NixOS-level catppuccin settings are applied via the catppuccin.nixosModules.catppuccin
      # which is imported in the host definition
    };

  flake.modules.homeManager.catppuccin =
    { config, pkgs, lib, ... }:
    {
      catppuccin = {
        accent = "blue";
        flavor = "mocha";
        kvantum = {
          enable = true;
          apply = true;
        };
        cursors.enable = true;
        mpv.enable = true;
        lazygit.enable = true;
        eza.enable = true;
      };

    };
}
