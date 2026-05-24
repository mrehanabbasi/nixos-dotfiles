# Bat - better cat
_:

{
  flake.modules.homeManager.bat =
    { config, lib, ... }:
    let
      cfg = config.features.bat;
    in
    {
      options.features.bat.enable = lib.mkEnableOption "bat better cat replacement";
      config = lib.mkIf cfg.enable {
        catppuccin.bat.enable = true;

        programs.bat = {
          enable = true;
          config = {
            paging = "never";
          };
        };
      };
    };
}
