# Ghostty terminal emulator with Catppuccin theme
_:

{
  flake.modules.nixos.ghostty =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.ghostty;
    in
    {
      options.features.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator";
      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ pkgs.ghostty ];
      };
    };

  flake.modules.homeManager.ghostty =
    { config, lib, ... }:
    let
      cfg = config.features.ghostty;
    in
    {
      options.features.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator";
      config = lib.mkIf cfg.enable {
        catppuccin.ghostty.enable = true;

        programs.ghostty = {
          enable = true;
          enableZshIntegration = true;
          installVimSyntax = true;
          installBatSyntax = true;

          settings = {
            font-family = "JetBrainsMono Nerd Font";
            font-style-italic = "Italic";
            font-style-bold = "Bold";
            font-style-bold-italic = "Bold Italic";
            font-size = 12;

            adjust-cell-height = "+15%";
            adjust-cell-width = "+2%";

            # Disable ligatures
            font-feature = [
              "-dlig"
              "-liga"
              "-calt"
            ];

            cursor-style = "block";
            background-opacity = 0.95;
            term = "xterm-256color";

            # Keybindings
            keybind = [
              "ctrl+l=text:\\x0c" # Clear screen
            ];
          };
        };
      };
    };
}
