# Steam - Valve's gaming platform
_:

{
  flake.modules.nixos.steam =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.steam;
    in
    {
      options.features.steam.enable = lib.mkEnableOption "Steam gaming platform";
      config = lib.mkIf cfg.enable {
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          extraCompatPackages = [ pkgs.proton-ge-bin ];
        };
        # Steam dependencies - 32-bit graphics required for most games
        # mkDefault allows gpu.nix to override if needed
        hardware.graphics.enable = lib.mkDefault true;
        hardware.graphics.enable32Bit = lib.mkDefault true;
      };
    };
}
