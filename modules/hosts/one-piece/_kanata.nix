# Kanata keyboard remapper for one-piece laptop
# Host-specific: Internal keyboard device path is laptop-specific
{ pkgs, ... }:

let
  # Devices to exclude from external keyboard detection (e.g., mouse receivers)
  excludeDevices = [
    {
      vendor = "046d";
      product = "c548";
    } # Logitech USB Receiver
  ];

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
            
            ${builtins.concatStringsSep "\n            " (
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
  services.kanata = {
    enable = true;

    keyboards = {
      internal = {
        # Internal laptop keyboard device path (specific to this laptop)
        devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
        extraDefCfg = "process-unmapped-keys yes";

        config = ''
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
}
