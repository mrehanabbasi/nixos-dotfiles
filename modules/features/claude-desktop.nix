# Claude Desktop - native Linux desktop app via claude-desktop-debian flake
{ inputs, ... }:

{
  flake.modules.homeManager.claude-desktop =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features."claude-desktop";
    in
    {
      options.features."claude-desktop".enable = lib.mkEnableOption "Claude Desktop app";

      config = lib.mkIf cfg.enable {
        home.packages = [
          inputs.claude-desktop-debian.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-fhs
        ];
      };
    };
}
