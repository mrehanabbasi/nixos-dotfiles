# Communication apps - Zoom and Slack
_:

{
  flake.modules.homeManager.communication =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.communication;
    in
    {
      options.features.communication.enable = lib.mkEnableOption "communication apps (Zoom, Slack)";

      config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          zoom-us
          slack
        ];
      };
    };
}
