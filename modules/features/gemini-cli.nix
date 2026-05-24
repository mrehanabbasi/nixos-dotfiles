# Gemini CLI - AI coding assistant
_:

{
  flake.modules.homeManager.gemini-cli =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features."gemini-cli";
    in
    {
      options.features."gemini-cli".enable = lib.mkEnableOption "Gemini CLI AI coding assistant";
      config = lib.mkIf cfg.enable {
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
    };
}
