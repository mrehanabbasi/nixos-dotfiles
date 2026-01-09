# Hardware configuration (Bluetooth, NVIDIA, Graphics)
{ config, ... }:

{
  # Allow unfree packages (needed for NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  hardware = {
    # Bluetooth configuration
    bluetooth = {
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

    # NVIDIA GPU configuration
    nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true; # Use `nvidia-offload %command%` in steam
        };
        amdgpuBusId = "PCI:06:00:0";
        nvidiaBusId = "PCI:01:00:0";
      };
    };

    # Graphics configuration
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # For Qualcomm WiFi 7 card support
    enableRedistributableFirmware = true;
  };

  # NVIDIA video driver
  services.xserver.videoDrivers = [ "nvidia" ];

  # Wayland environment variable for Ozone-based apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
