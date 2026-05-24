# Core system services
# Essential services for desktop functionality
_:

{
  flake.modules.nixos.core-services =
    { config, lib, ... }:
    let
      cfg = config.features."core-services";
    in
    {
      options.features."core-services".enable = lib.mkEnableOption "core system services for desktop functionality";
      config = lib.mkIf cfg.enable {
        services = {
          # Input device support
          libinput.enable = true;

          # Power management
          power-profiles-daemon.enable = true;
        };
      };
    };
}
