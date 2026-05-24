# Boot loader configuration
_:

{
  flake.modules.nixos.boot =
    { config, lib, ... }:
    let
      cfg = config.features.boot;
    in
    {
      options.features.boot.enable = lib.mkEnableOption "boot configuration";

      config = lib.mkIf cfg.enable {
        # Use the systemd-boot EFI boot loader
        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };

        # Use default kernel (6.12 LTS) - linuxPackages_latest (6.19) fixes USB-C DP
        # alt mode but has unstable MLO (Multi-Link Operation) in ath12k causing
        # firmware timeouts and kernel panics on suspend. Revisit when upstream lands.
      };
    };
}
