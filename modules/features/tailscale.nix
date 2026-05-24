# Tailscale VPN service
_:

{
  flake.modules.nixos.tailscale =
    { config, lib, ... }:
    let
      cfg = config.features.tailscale;
    in
    {
      options.features.tailscale.enable = lib.mkEnableOption "Tailscale VPN service";
      config = lib.mkIf cfg.enable {
        services.tailscale.enable = true;
      };
    };
}
