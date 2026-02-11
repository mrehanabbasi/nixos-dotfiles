# Catppuccin theming for Waybar
# Depends on: catppuccin
_:

{
  flake.modules.homeManager.waybar-catppuccin = _: {
    catppuccin.waybar.enable = true;
  };
}
