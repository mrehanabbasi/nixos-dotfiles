# AppImage support
# Enables running AppImage files directly via binfmt
_:

{
  flake.modules.nixos.appimage =
    { config, lib, ... }:
    let
      cfg = config.features.appimage;
    in
    {
      options.features.appimage.enable = lib.mkEnableOption "AppImage support via binfmt";
      config = lib.mkIf cfg.enable {
        programs.appimage = {
          enable = true;
          binfmt = true;
        };
      };
    };
}
