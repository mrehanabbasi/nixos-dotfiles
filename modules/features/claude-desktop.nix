# Claude Desktop - native Linux desktop app via claude-desktop-debian flake
{ inputs, ... }:

{
  flake.modules.homeManager.claude-desktop =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.claude-desktop-debian.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-fhs
      ];
    };
}
