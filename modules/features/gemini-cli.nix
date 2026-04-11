# Gemini CLI - AI coding assistant
_:

{
  flake.modules.homeManager.gemini-cli =
    { pkgs, ... }:
    {
      catppuccin.gemini-cli.enable = true;

      programs.gemini-cli = {
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
        };
      };
    };
}
