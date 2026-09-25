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

        # DMS owns idle and lock on this host (see dank-material-shell), so
        # hypridle is not wanted: it fought DMS for the idle inhibitor and
        # core-dumped on every boot until it hit systemd's restart limit.
        #
        # programs.hyprlock.enable is deliberately NOT used - that module hard-sets
        # services.hypridle.enable = true with no mkDefault, so enabling it forces
        # hypridle back on. Installing the package and declaring its PAM service
        # by hand gives the same working escape-hatch locker without the coupling.

        security.polkit.enable = true;
        security.pam.services.hyprlock = { };

        # DMS's lock screen authenticates against /etc/pam.d/dankshell. Without
        # this it falls back to a stack it generates into ~/.local/state, which
        # pins nix store paths and goes stale across rebuilds.
        security.pam.services.dankshell = { };

        environment.systemPackages = with pkgs; [
          hyprpaper
          hyprshot
          hyprpicker
          hyprlock # manual fallback locker; see the hypridle note above
          # Runtime deps for Hyprland keybindings
          brightnessctl
          playerctl
        ];

        # Portals: the hyprland backend only implements Screenshot/ScreenCast/
        # GlobalShortcuts, and gtk.portal is marked UseIn=gnome, so FileChooser
        # has no implementation under XDG_CURRENT_DESKTOP=Hyprland. Apps using
        # native (portal) file dialogs - e.g. OnlyOffice "Save as" - fail with
        # org.freedesktop.portal.FileChooser errors without this.
        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          config.hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          };
        };

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
