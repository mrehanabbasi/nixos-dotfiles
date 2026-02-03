# Gaming - Steam, Lutris, and related tools
_:

{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs = {
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };
        gamemode.enable = true;
      };

      environment.systemPackages = with pkgs; [
        lutris
        heroic
        wine
        winetricks
        protonup-qt
        bottles
      ];
    };
}
