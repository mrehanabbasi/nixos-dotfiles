# Gaming configuration
{ pkgs, ... }:

{
  programs = {
    # Steam with firewall rules
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    # GameMode for performance optimization
    gamemode.enable = true;
  };

  # Gaming packages
  environment.systemPackages = with pkgs; [
    lutris
    mangohud
    protonup-qt
    bottles
    heroic

    # Wine and tools for running Windows apps (via Bottles/Lutris)
    wineWowPackages.stable
    winetricks
    cabextract
  ];
}
