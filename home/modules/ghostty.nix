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

      # disable litigatures
      font-feature = [
        "-dlig"
        "-liga"
        "-calt"
      ];

      # Cursor style
      cursor-style = "block";

      # Background / transparency (optional; set full opaque if you want solid background)
      background-opacity = 0.95;
      # (optional) background blur — comment out if you don't want blur
      # background-blur = 0;

      # TERM (so shell / apps see a suitable term type)
      # term = "xterm-ghostty";
      term = "xterm-256color";
    };
  };
}
