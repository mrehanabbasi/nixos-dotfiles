{ pkgs, ... }:

let
  # Devices to exclude from external keyboard detection (e.g., mouse receivers)
  excludeDevices = [
    {
      vendor = "046d";
      product = "c548";
    } # Logitech USB Receiver
  ];

  # Generate exclusion conditions for udev rules
  excludeConditions = builtins.concatStringsSep ", " (
    map (dev: ''ATTRS{idVendor}!="${dev.vendor}", ATTRS{idProduct}!="${dev.product}"'') excludeDevices
  );

  # Script to check if external USB keyboards are connected
  checkExternalKeyboard = pkgs.writeShellScript "check-external-keyboard" ''
    PATH=${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin

    # Check for external USB keyboards (excluding specific devices)
    for event_dir in /sys/class/input/event*; do
      [ -d "$event_dir" ] || continue
      
      device="$event_dir/device"
      [ -d "$device" ] || continue
      
      # Get device name
      dev_name=$(cat "$device/name" 2>/dev/null || echo "unknown")
      
      # Check if it has keyboard capabilities
      # Try both possible locations for the capabilities file
      cap_file=""
      if [ -f "$device/capabilities/key" ]; then
        cap_file="$device/capabilities/key"
      elif [ -f "$device/../capabilities/key" ]; then
        cap_file="$device/../capabilities/key"
      fi
      
      [ -n "$cap_file" ] || continue
      
      # Read capabilities - keyboard devices have specific bits set
      cap_data=$(cat "$cap_file")
      
      # Check if it's a keyboard by looking for substantial key capabilities
      if echo "$cap_data" | grep -qE "[0-9a-f]{4,}"; then
        # Check if device name contains "keyboard" (case insensitive)
        # Or if it has the platform-i8042 path (internal keyboard)
        if echo "$dev_name" | grep -qi "keyboard" || readlink -f "$device" | grep -q "i8042"; then
          # Check if it's a USB device by looking at the device path
          dev_path=$(readlink -f "$device")
          
          if echo "$dev_path" | grep -q "/usb"; then
            # Get vendor and product IDs
            vendor=$(cat "$device/../id/vendor" 2>/dev/null || echo "")
            product=$(cat "$device/../id/product" 2>/dev/null || echo "")
            
            # Skip if in exclusion list
            ${builtins.concatStringsSep "\n            " (
              map (dev: ''
                if [ "$vendor" = "${dev.vendor}" ] && [ "$product" = "${dev.product}" ]; then
                  continue
                fi'') excludeDevices
            )}
            
            # External USB keyboard found (not in exclusion list)
            echo "External keyboard detected: $dev_name"
            exit 1
          fi
        fi
      fi
    done

    # No external keyboard found
    exit 0
  '';
in
{
  # Enable Kanata keyboard remapper
  services.kanata = {
    enable = true;
    # package = pkgs.kanata-with-cmd;

    keyboards = {
      # Internal laptop keyboard configuration
      internal = {
        # Specify the internal keyboard device
        devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];

        # Additional defcfg settings
        extraDefCfg = "process-unmapped-keys yes";

        # Kanata keyboard configuration
        config = ''
          ;;(defcfg
          ;;  process-unmapped-keys yes
          ;;)

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

  # Override kanata service to check for external keyboards at startup and on restart
  systemd.services.kanata-internal = {
    unitConfig = {
      StartLimitIntervalSec = 0;
    };
    serviceConfig = {
      # ExecCondition runs after ExecStartPre but before ExecStart
      # If it fails (non-zero exit), the service is skipped (not failed!)
      # We need to invert our check: exit 0 if NO external keyboard, exit 1 if external keyboard found
      ExecCondition = "${pkgs.writeShellScript "check-no-external-keyboard" ''
        ${checkExternalKeyboard}
        exit_code=$?

        if [ $exit_code -eq 1 ]; then
          # External keyboard detected - exit 1 to skip service start
          echo "External keyboard detected, skipping service start"
          exit 1
        fi

        # No external keyboard - exit 0 to allow service to start
        exit 0
      ''}";
      # Prevent automatic restart on failure
      Restart = "no";
    };
    # Force actual restart (not reload) on config changes
    restartIfChanged = true;
    stopIfChanged = false;
  };

  # Set up udev rules to automatically stop/start kanata when external keyboards are connected
  services.udev.extraRules = ''
    # When external USB keyboard is added, stop kanata (exclude specific devices)
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_INPUT_KEYBOARD}=="1", \
      SUBSYSTEMS=="usb", ${excludeConditions}, \
      RUN+="${pkgs.systemd}/bin/systemctl stop kanata-internal.service"

    # When external USB keyboard is removed, start kanata (exclude specific devices)
    ACTION=="remove", SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_INPUT_KEYBOARD}=="1", \
      SUBSYSTEMS=="usb", ${excludeConditions}, \
      RUN+="${pkgs.systemd}/bin/systemctl start kanata-internal.service"
  '';
}
