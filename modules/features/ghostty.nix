# Ghostty terminal emulator with Catppuccin theme
_:

{
  flake.modules.nixos.ghostty =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.ghostty ];
    };

  flake.modules.homeManager.ghostty = _: {
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
}
