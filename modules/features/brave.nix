# Brave browser
_:

{
  flake.modules.nixos.brave =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.brave;
    in
    {
      options.features.brave.enable = lib.mkEnableOption "Brave browser";
      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          brave
        ];
      };
    };
}
