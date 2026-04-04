# Thunar file manager with all dependencies
# Self-contained: includes gvfs, tumbler, archive managers, and plugins
_:

{
  flake.modules.nixos.thunar =
    { pkgs, ... }:
    {
      programs.thunar = {
        enable = true;
        plugins = with pkgs.xfce; [
          thunar-volman
          thunar-archive-plugin
        ];
      };

      # Virtual filesystem support for Thunar (trash, mounting, remote access)
      services.gvfs.enable = true;

      # Thumbnail service for Thunar
      services.tumbler.enable = true;

      environment.systemPackages = with pkgs; [
        # Archive managers (backends for thunar-archive-plugin)
        # xarchiver is a lightweight GTK archive manager
        # file-roller provides better thunar-archive-plugin integration via .tap files
        xarchiver
        file-roller

        # Video thumbnails for Thunar
        ffmpegthumbnailer

        # Filesystem support for NTFS drives
        ntfs3g
      ];
    };
}
