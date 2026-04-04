# Wine - Windows compatibility layer and gaming tools
_:

{
  flake.modules.nixos.wine =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Wine and tools
        wine
        winetricks
        # Game launchers
        lutris
        heroic
        bottles
        # Proton management
        protonup-qt
      ];
    };
}
