# Web browsers
{ ... }:

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
