# System-wide font configuration
# Sets JetBrainsMono Nerd Font as default monospace font
_:

{
  flake.modules.nixos.fonts =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.fonts;
    in
    {
      options.features.fonts.enable = lib.mkEnableOption "system fonts";

      config = lib.mkIf cfg.enable {
        fonts.packages = with pkgs; [
          nerd-fonts.jetbrains-mono
        ];

        fonts.fontconfig = {
          defaultFonts = {
            monospace = [ "JetBrainsMono Nerd Font" ];
          };
        };
      };
    };
}
