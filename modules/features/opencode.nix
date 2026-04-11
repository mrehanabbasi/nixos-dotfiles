# OpenCode - AI coding assistant
{ inputs, ... }:

{
  flake.modules.homeManager.opencode =
    { pkgs, ... }:
    {
      catppuccin.opencode.enable = true;

      programs.opencode = {
        enable = true;
        package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
        # settings = {
        #   theme = "catppuccin";
        # };
      };
    };
}
