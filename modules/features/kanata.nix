# Kanata keyboard remapper - home-row mods on the built-in keyboard
#
# Only ever bound to the internal keyboard: the layout below assumes a laptop
# staggered board, and an external keyboard is usually plugged in precisely
# because the user wants its own behaviour. A udev rule stops the service while
# a real external keyboard is attached and starts it again on unplug, ignoring
# devices the host flagged as not-really-keyboards (host.input.ignoredKeyboards).
_:

{
  flake.modules.nixos.kanata =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.kanata;

      inherit (cfg) excludeDevices;

      excludeConditions = builtins.concatStringsSep ", " (
        map (dev: ''ATTRS{idVendor}!="${dev.vendor}", ATTRS{idProduct}!="${dev.product}"'') excludeDevices
      );

      checkExternalKeyboard = pkgs.writeShellScript "check-external-keyboard" ''
        PATH=${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin

        for event_dir in /sys/class/input/event*; do
          [ -d "$event_dir" ] || continue

          device="$event_dir/device"
          [ -d "$device" ] || continue

          dev_name=$(cat "$device/name" 2>/dev/null || echo "unknown")

          cap_file=""
          if [ -f "$device/capabilities/key" ]; then
            cap_file="$device/capabilities/key"
          elif [ -f "$device/../capabilities/key" ]; then
            cap_file="$device/../capabilities/key"
          fi

          [ -n "$cap_file" ] || continue

          cap_data=$(cat "$cap_file")

          if echo "$cap_data" | grep -qE "[0-9a-f]{4,}"; then
            if echo "$dev_name" | grep -qi "keyboard" || readlink -f "$device" | grep -q "i8042"; then
              dev_path=$(readlink -f "$device")

              if echo "$dev_path" | grep -q "/usb"; then
                vendor=$(cat "$device/../id/vendor" 2>/dev/null || echo "")
                product=$(cat "$device/../id/product" 2>/dev/null || echo "")

                ${builtins.concatStringsSep "\n              " (
                  map (dev: ''
                    if [ "$vendor" = "${dev.vendor}" ] && [ "$product" = "${dev.product}" ]; then
                      continue
                    fi'') excludeDevices
                )}

                echo "External keyboard detected: $dev_name"
                exit 1
              fi
            fi
          fi
        done

        exit 0
      '';
    in
    {
      options.features.kanata = {
        enable = lib.mkEnableOption "Kanata home-row mods on the internal keyboard";

        device = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = config.host.input.internalKeyboard;
          defaultText = lib.literalExpression "config.host.input.internalKeyboard";
          description = ''
            Keyboard to remap. Follows the machine's built-in keyboard; null
            means this machine has none and the feature cannot do anything, so
            enabling it then is an error rather than a silent no-op.
          '';
        };

        excludeDevices = lib.mkOption {
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                vendor = lib.mkOption { type = lib.types.str; };
                product = lib.mkOption { type = lib.types.str; };
              };
            }
          );
          default = config.host.input.ignoredKeyboards;
          defaultText = lib.literalExpression "config.host.input.ignoredKeyboards";
          description = ''
            USB devices that must not count as an external keyboard. Without
            this a unifying receiver for a mouse reads as a keyboard being
            plugged in, and the remap switches itself off.
          '';
        };

        layout = lib.mkOption {
          type = lib.types.lines;
          description = ''
            Kanata configuration. The default puts home-row mods on asdf/jkl;
            and turns caps into tap-escape / hold-control.

            Each mod also emits f24 on tap, which is a no-op key used purely as
            a marker other tools can watch for.
          '';
          default = ''
            (defsrc
              caps a s d f j k l ;
            )

            (defvar
              tap-time 150
              hold-time 200
            )

            (defalias
              escctrl (tap-hold 100 100 esc lctl)
              a (multi f24 (tap-hold $tap-time $hold-time a lmet))
              s (multi f24 (tap-hold $tap-time $hold-time s lalt))
              d (multi f24 (tap-hold $tap-time $hold-time d lsft))
              f (multi f24 (tap-hold $tap-time $hold-time f lctl))
              j (multi f24 (tap-hold $tap-time $hold-time j rctl))
              k (multi f24 (tap-hold $tap-time $hold-time k rsft))
              l (multi f24 (tap-hold $tap-time $hold-time l ralt))
              ; (multi f24 (tap-hold $tap-time $hold-time ; rmet))
            )

            (deflayer base
              @escctrl @a @s @d @f @j @k @l @;
            )
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.device != null;
            message = "features.kanata is enabled but no keyboard was given: set host.input.internalKeyboard, or features.kanata.device.";
          }
        ];

        services.kanata = {
          enable = true;

          keyboards = {
            internal = {
              devices = [ cfg.device ];
              extraDefCfg = "process-unmapped-keys yes";
              config = cfg.layout;
            };
          };
        };

        systemd.services.kanata-internal = {
          unitConfig.StartLimitIntervalSec = 0;
          serviceConfig = {
            ExecCondition = "${pkgs.writeShellScript "check-no-external-keyboard" ''
              ${checkExternalKeyboard}
              exit_code=$?
              if [ $exit_code -eq 1 ]; then
                echo "External keyboard detected, skipping service start"
                exit 1
              fi
              exit 0
            ''}";
            Restart = "no";
          };
          restartIfChanged = true;
          stopIfChanged = false;
        };

        services.udev.extraRules = ''
          ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_INPUT_KEYBOARD}=="1", \
            SUBSYSTEMS=="usb", ${excludeConditions}, \
            RUN+="${pkgs.systemd}/bin/systemctl stop kanata-internal.service"

          ACTION=="remove", SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_INPUT_KEYBOARD}=="1", \
            SUBSYSTEMS=="usb", ${excludeConditions}, \
            RUN+="${pkgs.systemd}/bin/systemctl start kanata-internal.service"
        '';
      };
    };
}
