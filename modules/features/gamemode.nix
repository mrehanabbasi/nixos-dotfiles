# GameMode - Feral Interactive's game optimizer
_:

{
  flake.modules.nixos.gamemode =
    { config, lib, ... }:
    let
      cfg = config.features.gamemode;
    in
    {
      options.features.gamemode.enable = lib.mkEnableOption "GameMode game optimizer";
      config = lib.mkIf cfg.enable {
        programs.gamemode.enable = true;
      };
    };
}
