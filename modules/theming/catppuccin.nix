# Catppuccin theming - NixOS and Home Manager
{ ... }:

{
  flake.modules.nixos.catppuccin =
    { ... }:
    {
      # NixOS-level catppuccin settings are applied via the catppuccin.nixosModules.catppuccin
      # which is imported in the host definition
    };

  flake.modules.homeManager.catppuccin =
    { ... }:
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
