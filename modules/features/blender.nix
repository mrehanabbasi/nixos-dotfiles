# Blender 3D creation suite
# On a hybrid-GPU host, launch through that host's offload wrapper (e.g.
# `nvidia-offload blender`) to render on the discrete GPU.
_:

{
  flake.modules.homeManager.blender =
    {
      config,
      lib,
      pkgs,
      ...
    }:
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
