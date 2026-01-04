{ pkgs, opencode, ... }:

{
  programs.opencode = {
    enable = true;
    package = opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      theme = "catppuccin";
    };
  };
}
