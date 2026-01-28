# GTK theming - Tokyo Night with dark mode
# Catppuccin GTK theme repo is archived
{ ... }:

{
  flake.modules.homeManager.gtk =
    { pkgs, ... }:
    {
      gtk = {
        enable = true;
        colorScheme = "dark";

        theme = {
          name = "Tokyonight-Dark";
          package = pkgs.tokyonight-gtk-theme;
        };

        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
      };

      # Pointer cursor with GTK integration
      home.pointerCursor = {
        gtk.enable = true;
      };

      # dconf settings for GNOME/GTK apps that read from dconf
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Tokyonight-Dark";
          icon-theme = "Papirus-Dark";
        };
      };
    };
}
