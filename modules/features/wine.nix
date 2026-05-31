# Wine - Windows compatibility layer and gaming tools
_:

{
  flake.modules.nixos.wine =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.wine;
    in
    {
      options.features.wine.enable = lib.mkEnableOption "Wine Windows compatibility layer and gaming tools";
      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          # Wine and tools (wineWow64Packages.stable adds 32-bit support for winetricks)
          wineWow64Packages.stable
          winetricks
          # Game launchers
          lutris
          heroic
          bottles
          # Proton management
          protonup-qt
        ];
      };
    };
}
