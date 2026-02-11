# System-wide font configuration
# Sets JetBrainsMono Nerd Font as default monospace font
_:

{
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];

      fonts.fontconfig = {
        defaultFonts = {
          monospace = [ "JetBrainsMono Nerd Font" ];
        };
      };
    };
}
