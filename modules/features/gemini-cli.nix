# Gemini CLI - AI coding assistant
_:

{
  flake.modules.homeManager.gemini-cli =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features."gemini-cli";
      catppuccinMochaTheme = {
        name = "Catppuccin Mocha";
        type = "custom";
        Background = "#1e1e2e";
        Foreground = "#cdd6f4";
        LightBlue = "#89dceb";
        AccentBlue = "#89b4fa";
        AccentPurple = "#cba6f7";
        AccentCyan = "#94e2d5";
        AccentGreen = "#a6e3a1";
        AccentYellow = "#f9e2af";
        AccentRed = "#f38ba8";
        Comment = "#9399b2";
        Gray = "#7f849c";
        DiffAdded = "#546d5c";
        DiffRemoved = "#734a5f";
        GradientColors = [
          "#89b4fa"
          "#cba6f7"
          "#f38ba8"
        ];
      };
    in
    {
      options.features."gemini-cli".enable = lib.mkEnableOption "Gemini CLI AI coding assistant";
      config = lib.mkIf cfg.enable {
        programs.antigravity-cli = {
          enable = true;
          package = pkgs.gemini-cli;
          settings = {
            general = {
              preferredEditor = "nvim";
              vimMode = true;
            };
            privacy = {
              usageStatisticsEnabled = false;
            };
            ui = {
              theme = catppuccinMochaTheme.name;
              customThemes.${catppuccinMochaTheme.name} = catppuccinMochaTheme;
            };
          };
        };
      };
    };
}
