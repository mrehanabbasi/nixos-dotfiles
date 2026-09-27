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

        security = {
          polkit.enable = true;
          pam.services = {
            hyprlock = { };

            # DMS's lock screen authenticates against /etc/pam.d/dankshell.
            # Without this it falls back to a stack it generates into
            # ~/.local/state, which pins nix store paths and goes stale
            # across rebuilds.
            dankshell = { };
          };
        };

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

        # Ozone-based apps (Electron, Chromium) only pick the Wayland backend
        # when told to. A property of running a Wayland session, not of any
        # particular GPU.
        environment.sessionVariables.NIXOS_OZONE_WL = "1";
      };
    };

  # Home Manager aspect
  flake.modules.homeManager.hyprland =
    {
      config,
      lib,
      osConfig ? null,
      ...
    }:
    let
      cfg = config.features.hyprland;
      inherit (cfg) displays;

      # Machine facts from the NixOS side (see modules/system/host.nix). Absent
      # when this module is evaluated as standalone Home Manager, hence the
      # empty fallback - the option defaults below then stand on their own.
      host = if osConfig == null then { } else osConfig.host or { };
      hostDisplays = host.displays or { };

      luaStr = s: ''"${lib.escape [ ''"'' "\\" ] s}"'';
      luaList = xs: "{ ${lib.concatMapStringsSep ", " luaStr xs} }";

      # Host display facts, handed to hyprland.lua as a global. Keeping them out
      # of the Lua keeps that file the same on every machine.
      displayPrelude = ''
        DISPLAY_CONFIG = {
          internal = ${if displays.internal == null then "nil" else luaStr displays.internal},
          internal_width = ${toString displays.internalWidth},
          external_models = ${luaList displays.externalModels},
          disable_internal_at = ${toString displays.disableInternalAt},
          lid_switch = ${lib.boolToString displays.lidSwitch},
        }
      '';
    in
    {
      options.features.hyprland = {
        enable = lib.mkEnableOption "Hyprland window manager";

        # These all default to the machine facts the host declared, so a host
        # never has to mention Hyprland to get its monitors laid out. Set one
        # explicitly only to deviate from the machine's own description.
        displays = {
          internal = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = hostDisplays.internal or null;
            defaultText = lib.literalExpression "osConfig.host.displays.internal";
            example = "eDP-1";
            description = ''
              Connector name of the built-in panel, or null on a machine with no
              built-in display. When set it is placed at 0x0 and externals tile
              to its right.
            '';
          };

          internalWidth = lib.mkOption {
            type = lib.types.ints.positive;
            default = hostDisplays.internalWidth or 1920;
            defaultText = lib.literalExpression "osConfig.host.displays.internalWidth";
            description = ''
              Width used to offset externals while the internal panel is absent
              from hyprctl output (it reports nothing while disabled).
            '';
          };

          externalModels = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = hostDisplays.external or [ ];
            defaultText = lib.literalExpression "osConfig.host.displays.external";
            example = [
              "DELL U2424HE"
              "DELL SE2422H"
            ];
            description = ''
              External monitors to lay out, ordered left to right. Matched
              against the monitor description rather than the connector, so a
              display keeps its position whichever port it lands on. List the
              available strings with: hyprctl monitors all | grep description

              Monitors not named here are left to Hyprland's auto placement.
            '';
          };

          disableInternalAt = lib.mkOption {
            type = lib.types.ints.positive;
            default = hostDisplays.disableInternalAt or 2;
            defaultText = lib.literalExpression "osConfig.host.displays.disableInternalAt";
            description = ''
              How many of {option}`externalModels` must be connected before the
              internal panel is switched off. Ignored when
              {option}`internal` is null.
            '';
          };

          lidSwitch = lib.mkOption {
            type = lib.types.bool;
            default = (host.formFactor or "desktop") == "laptop";
            defaultText = lib.literalExpression ''osConfig.host.formFactor == "laptop"'';
            description = ''
              Bind the lid switch to lock-then-suspend, skipped while any
              monitor from {option}`externalModels` is connected. Follows the
              machine's form factor, since only laptops have a lid.
            '';
          };
        };
      };

      config = lib.mkIf cfg.enable {
        wayland.windowManager.hyprland = {
          enable = true;
          configType = "lua";

          # Lua config lives in ./hyprland.lua for syntax highlighting / LSP support.
          extraConfig = displayPrelude + builtins.readFile ./hyprland.lua;
        };
      };
    };
}
