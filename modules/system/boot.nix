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

        # boot.kernelPackages is deliberately left at the nixpkgs default here.
        # A host that needs a different kernel for its own hardware sets it in
        # its own hardware module, so one machine's chipset quirk cannot pin
        # the kernel for the whole fleet.
      };
    };
}
