# Hyprland window manager - NixOS and Home Manager configuration
_:

{
  # NixOS aspect
  flake.modules.nixos.hyprland =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.hyprland;
    in
    {
      options.features.hyprland.enable = lib.mkEnableOption "Hyprland window manager";

      config = lib.mkIf cfg.enable {
        programs.hyprland = {
          enable = true;
          xwayland.enable = true;
        };

        programs.hyprlock.enable = true;
        services.hypridle.enable = true;

        security.polkit.enable = true;
        security.pam.services.hyprlock = { };

        environment.systemPackages = with pkgs; [
          hyprpaper
          hyprshot
          hyprpicker
          # Runtime deps for Hyprland keybindings
          brightnessctl
          playerctl
        ];

        # Note: gvfs.enable is in thunar.nix
        services.upower.enable = true;
      };
    };

  # Home Manager aspect
  flake.modules.homeManager.hyprland =
    { config, lib, ... }:
    let
      cfg = config.features.hyprland;
    in
    {
      options.features.hyprland.enable = lib.mkEnableOption "Hyprland window manager";

      config = lib.mkIf cfg.enable {
        wayland.windowManager.hyprland = {
          enable = true;
          configType = "lua";

          # Lua config lives in ./hyprland.lua for syntax highlighting / LSP support.
          extraConfig = builtins.readFile ./hyprland.lua;
        };
      };
    };
}
