# LocalSend for local file sharing
# The NixOS module automatically opens required firewall ports
_:

{
  flake.modules.nixos.localsend =
    { config, lib, ... }:
    let
      cfg = config.features.localsend;
    in
    {
      options.features.localsend.enable = lib.mkEnableOption "LocalSend local file sharing";
      config = lib.mkIf cfg.enable {
        programs.localsend.enable = true;
      };
    };
}
