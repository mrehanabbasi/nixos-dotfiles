# Steam - Valve's gaming platform
_:

{
  flake.modules.nixos.steam =
    { lib, ... }:
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
      # Steam dependencies - 32-bit graphics required for most games
      # mkDefault allows gpu.nix to override if needed
      hardware.graphics.enable = lib.mkDefault true;
      hardware.graphics.enable32Bit = lib.mkDefault true;
    };
}
