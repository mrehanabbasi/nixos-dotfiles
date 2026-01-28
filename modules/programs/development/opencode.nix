# OpenCode - AI coding assistant
{ inputs, ... }:

{
  flake.modules.homeManager.opencode =
    { pkgs, ... }:
    {
      programs.opencode = {
        enable = true;
        package = inputs.opencode.packages.${pkgs.system}.default;
        settings = {
          theme = "catppuccin";
        };
      };
    };
}
