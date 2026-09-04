# DaVinci Resolve - professional video editor (free tier, unfree package)
# base.nix uses allowUnfree = true which already covers this package
#
# Known Linux/NixOS gotchas (see https://wiki.nixos.org/wiki/DaVinci_Resolve):
# - No native Wayland support (Qt version mismatch) -> force QT_QPA_PLATFORM=xcb,
#   runs fine under XWayland on Hyprland.
# - Needs OpenCL: hardware.graphics.extraPackages must include mesa.opencl for
#   the AMD iGPU path; hardware.nvidia + prime offload (host gpu.nix) covers CUDA.
# - Free edition has only partial H.264/H.265 decode and no AAC audio due to
#   licensing; transcode problem files to DNxHR first if playback/export fails.
# - On hybrid AMD+NVIDIA laptops, prefer running on the NVIDIA GPU (more mature
#   CUDA/OpenCL support): the `davinci-resolve-nvidia` wrapper below runs it
#   through `nvidia-offload` with QT_QPA_PLATFORM=xcb already set.
_:

{
  flake.modules.nixos."davinci-resolve" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features."davinci-resolve";
      davinciResolveNvidia = pkgs.writeShellScriptBin "davinci-resolve-nvidia" ''
        export QT_QPA_PLATFORM=xcb
        exec nvidia-offload davinci-resolve "$@"
      '';
    in
    {
      options.features."davinci-resolve".enable = lib.mkEnableOption "DaVinci Resolve video editor";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.davinci-resolve
          davinciResolveNvidia
        ];

        hardware.graphics.extraPackages = [ pkgs.mesa.opencl ];
      };
    };
}
