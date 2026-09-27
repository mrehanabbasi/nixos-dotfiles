# Input devices for one-piece
# Host-specific: the built-in keyboard's device node, and the USB receiver that
# would otherwise be mistaken for an external keyboard.
_:

{
  flake.modules.nixos.one-piece-input = _: {
    host.input = {
      # Laptop's own keyboard, on the legacy i8042 controller.
      internalKeyboard = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";

      ignoredKeyboards = [
        {
          vendor = "046d";
          product = "c548";
        } # Logitech USB Receiver - a mouse dongle that reports keyboard caps
      ];
    };
  };
}
