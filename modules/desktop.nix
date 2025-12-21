# Desktop environment configuration (Display Manager, Hyprland, etc.)
{ pkgs, ... }:

{
  # Hyprland window manager
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Display manager and theming
  catppuccin.sddm = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
    font = "JetBrainsMono Nerd Font";
    fontSize = "12";
    background = "${../wallpapers/cat-back.png}";
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

  # Authentication
  security.polkit.enable = true;
}
