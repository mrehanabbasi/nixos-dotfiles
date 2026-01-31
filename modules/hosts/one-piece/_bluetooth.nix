# Bluetooth configuration for one-piece
_:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true; # Shows battery charge of connected devices
        FastConnectable = true; # Faster connections at cost of power
      };
      Policy = {
        AutoEnable = true; # Enable all controllers when found
      };
    };
  };
}
