# Boot loader configuration
{ pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Use latest kernel for better WiFi 7 (WCN7850) support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel parameters for NVIDIA suspend/resume stability
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
  ];
}
