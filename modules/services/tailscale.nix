# Tailscale VPN service
{ ... }:

{
  flake.modules.nixos.tailscale =
    { ... }:
    {
      services.tailscale.enable = true;
    };
}
