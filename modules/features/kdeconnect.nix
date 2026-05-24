# KDE Connect - phone connectivity
_:

{
  flake.modules.nixos.kdeconnect =
    { config, lib, ... }:
    let
      cfg = config.features.kdeconnect;
    in
    {
      options.features.kdeconnect.enable = lib.mkEnableOption "KDE Connect phone connectivity";

      config = lib.mkIf cfg.enable {
        programs.kdeconnect.enable = true;
      };
    };

  flake.modules.homeManager.kdeconnect =
    { config, lib, ... }:
    let
      cfg = config.features.kdeconnect;
    in
    {
      options.features.kdeconnect.enable = lib.mkEnableOption "KDE Connect phone connectivity";

      config = lib.mkIf cfg.enable {
        services.kdeconnect = {
          enable = true;
          indicator = true;
        };
      };
    };
}
