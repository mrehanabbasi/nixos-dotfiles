# NVIDIA GPU configuration for one-piece (hybrid AMD + NVIDIA)
# Host-specific: Bus IDs are unique to this machine
_:

{
  flake.modules.nixos.one-piece-gpu =
    { config, pkgs, ... }:
    {
      hardware = {
        nvidia = {
          modesetting.enable = true;
          open = false;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;

          # Power management for suspend/resume stability
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

          # OpenCL for the AMD iGPU path (DaVinci Resolve and friends). The
          # NVIDIA side gets its ICD from the proprietary driver above.
          extraPackages = [ pkgs.mesa.opencl ];
        };

        # For Qualcomm WiFi 7 card support
        enableRedistributableFirmware = true;
      };

      # NVIDIA video driver
      services.xserver.videoDrivers = [ "nvidia" ];

      # Kernel parameters for NVIDIA suspend/resume stability
      boot.kernelParams = [
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
        "nvidia.NVreg_TemporaryFilePath=/var/tmp"
      ];

      # `nvidia-offload` exists because enableOffloadCmd is set above. Published
      # as a machine fact so apps that benefit from the discrete GPU can offer a
      # launcher, without this module having to know which apps those are.
      host.gpu.offloadCommand = "nvidia-offload";
    };
}
