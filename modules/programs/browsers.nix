# Web browsers
_:

{
  flake.modules.nixos.browsers =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        brave
        librewolf
      ];
    };
}
