# Catppuccin theming - NixOS and Home Manager
_:

{
  flake.modules.nixos.catppuccin =
    { pkgs, ... }:
    {
      # NixOS-level catppuccin settings are applied via the catppuccin.nixosModules.catppuccin
      # which is imported in the host definition

      # Cursor theme
      environment.systemPackages = with pkgs; [
        catppuccin-cursors.mochaBlue
      ];

      # dconf settings for GNOME/GTK apps that read from dconf
      # Note: gtk-theme is set to Tokyonight-Dark in gtk.nix
      programs.dconf.profiles.user.databases = [
        {
          settings."org/gnome/desktop/interface" = {
            icon-theme = "Catppuccin Mocha Blue";
            font-name = "JetBrainsMono Nerd Font";
            document-font-name = "JetBrainsMono Nerd Font";
            monospace-font-name = "JetBrainsMono Nerd Font";
          };
        }
      ];
    };

  flake.modules.homeManager.catppuccin = _: {
    # Global catppuccin settings (app-specific settings are in each app's module)
    catppuccin = {
      accent = "blue";
      flavor = "mocha";
    };
  };
}
