# SDDM display manager with Catppuccin theme
{ ... }:

{
  flake.modules.nixos.sddm =
    { pkgs, ... }:
    {
      catppuccin.sddm = {
        enable = true;
        flavor = "mocha";
        accent = "blue";
        font = "JetBrainsMono Nerd Font";
        fontSize = "12";
        background = ./background.png;
        clockEnabled = true;
        loginBackground = false;
      };

      services = {
        displayManager = {
          sddm = {
            enable = true;
            wayland.enable = true;
            autoNumlock = true;
            theme = "catppuccin-mocha-blue";
            package = pkgs.kdePackages.sddm;
            extraPackages = with pkgs; [
              qt6.qt5compat
              kdePackages.qtsvg
              kdePackages.qtmultimedia
              kdePackages.qtvirtualkeyboard
            ];
          };
          defaultSession = "hyprland";
        };

        # Disk management
        udisks2.enable = true;
      };
    };
}
