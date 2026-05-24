# DaVinci Resolve - professional video editor (free tier, unfree package)
# On hybrid AMD+NVIDIA: launch with `nvidia-offload davinci-resolve` for GPU acceleration
# base.nix uses allowUnfree = true which already covers this package
_:

{
  flake.modules.nixos."davinci-resolve" =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features."davinci-resolve";
    in
    {
      options.features."davinci-resolve".enable = lib.mkEnableOption "DaVinci Resolve video editor";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ pkgs.davinci-resolve ];
      };
    };
}
