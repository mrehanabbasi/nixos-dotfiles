# Core system services
# Essential services for desktop functionality
_:

{
  flake.modules.nixos.core-services = _: {
    services = {
      # Bluetooth manager GUI
      blueman.enable = true;

      # Input device support
      libinput.enable = true;

      # Power management
      power-profiles-daemon.enable = true;
    };
  };
}
