# Blender 3D creation suite
# On hybrid AMD+NVIDIA: launch with `nvidia-offload blender` for GPU rendering
_:

{
  flake.modules.homeManager.blender =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.blender;
    in
    {
      options.features.blender.enable = lib.mkEnableOption "Blender 3D creation suite";

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.blender ];
      };
    };
}
