# Boot loader configuration
{ ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Use default kernel (6.12 LTS) - linuxPackages_latest (6.18+) has unstable
  # MLO (Multi-Link Operation) support in ath12k that causes firmware timeouts
  # and kernel panics on suspend. Revisit when upstream fixes land.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel parameters for NVIDIA suspend/resume stability
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
  ];
}
