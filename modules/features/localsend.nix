# LocalSend for local file sharing
# The NixOS module automatically opens required firewall ports
_:

{
  flake.modules.nixos.localsend = _: {
    programs.localsend.enable = true;
  };
}
