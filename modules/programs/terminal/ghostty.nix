# Ghostty terminal emulator with Catppuccin theme
{ ... }:

{
  flake.modules.nixos.ghostty =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.ghostty ];
    };

  flake.modules.homeManager.ghostty =
    { ... }:
    {
      catppuccin.ghostty.enable = true;

      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        installVimSyntax = true;
        installBatSyntax = true;

        settings = {
          font-family = "JetBrainsMono Nerd Font";
          font-size = 14;

          # Disable ligatures
          font-feature = [
            "-dlig"
            "-liga"
            "-calt"
          ];

          cursor-style = "block";
          background-opacity = 0.95;
          term = "xterm-256color";
        };
      };
    };
}
