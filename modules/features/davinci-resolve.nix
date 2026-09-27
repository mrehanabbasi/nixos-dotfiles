# DaVinci Resolve - professional video editor (free tier, unfree package)
# base.nix uses allowUnfree = true which already covers this package
#
# Known Linux/NixOS gotchas (see https://wiki.nixos.org/wiki/DaVinci_Resolve):
# - No native Wayland support (Qt version mismatch) -> force QT_QPA_PLATFORM=xcb,
#   runs fine under XWayland on Hyprland.
# - Needs OpenCL, which is a GPU-driver concern and therefore the host's job:
#   Mesa hosts want mesa.opencl in hardware.graphics.extraPackages, NVIDIA hosts
#   get it from the proprietary driver. This module deliberately adds neither.
# - Free edition has only partial H.264/H.265 decode and no AAC audio due to
#   licensing; transcode problem files to DNxHR first if playback/export fails.
# - On hybrid-GPU machines, prefer the discrete GPU (more mature CUDA/OpenCL
#   support): set gpuOffloadCommand to the host's offload wrapper to get a
#   `davinci-resolve-gpu` launcher alongside the plain one.
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
      davinciResolveOffload = pkgs.writeShellScriptBin "davinci-resolve-gpu" ''
        export QT_QPA_PLATFORM=xcb
        exec ${cfg.gpuOffloadCommand} davinci-resolve "$@"
      '';
    in
    {
      options.features."davinci-resolve" = {
        enable = lib.mkEnableOption "DaVinci Resolve video editor";

        gpuOffloadCommand = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = config.host.gpu.offloadCommand;
          defaultText = lib.literalExpression "config.host.gpu.offloadCommand";
          example = "nvidia-offload";
          description = ''
            Command that runs its arguments on the machine's discrete GPU. When
            non-null a `davinci-resolve-gpu` wrapper is installed that launches
            Resolve through it; null (the default on single-GPU machines) skips
            the wrapper, which would otherwise reference a command that does
            not exist there.

            Follows {option}`host.gpu.offloadCommand` by default.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.davinci-resolve
        ]
        ++ lib.optional (cfg.gpuOffloadCommand != null) davinciResolveOffload;
      };
    };
}
