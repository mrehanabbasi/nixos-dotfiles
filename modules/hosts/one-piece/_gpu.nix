# NVIDIA GPU configuration for one-piece (hybrid AMD + NVIDIA)
# Host-specific: Bus IDs are unique to this machine
{ config, ... }:

{
  hardware = {
    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Critical for suspend/resume stability with dynamic power management
      powerManagement = {
        enable = true;
        finegrained = true; # GPU powers off completely when not in use
      };

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true; # Use `nvidia-offload %command%` in Steam
        };
        # Bus IDs specific to this laptop
        amdgpuBusId = "PCI:06:00:0";
        nvidiaBusId = "PCI:01:00:0";
      };
    };

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

  # Kernel parameters for NVIDIA suspend/resume stability
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
  ];
}
