# Yazi - terminal file manager with Catppuccin theme
_:

{
  flake.modules.homeManager.yazi =
    { config, lib, ... }:
    let
      cfg = config.features.yazi;
    in
    {
      options.features.yazi.enable = lib.mkEnableOption "yazi terminal file manager";
      config = lib.mkIf cfg.enable {
        catppuccin.yazi.enable = true;

        programs.yazi = {
          enable = true;

          settings = {
            # Yazi expands %s (all selected paths) itself - it does not pass the
            # files as shell positional args, so "$0"/"$@" expand to nothing and
            # every opener fails.
            opener = {
              imv_image = [
                {
                  run = "imv %s";
                  desc = "imv Image Viewer";
                  orphan = true;
                  for = "unix";
                }
              ];

              mpv_video = [
                {
                  run = "mpv %s";
                  desc = "mpv Video Player";
                  orphan = true;
                  for = "unix";
                }
              ];

              zathura_pdf = [
                {
                  run = "zathura %s";
                  desc = "Zathura PDF Reader";
                  orphan = true;
                  for = "unix";
                }
              ];

              nvim_code = [
                {
                  run = "nvim %s";
                  desc = "Neovim Code Editor";
                  block = true;
                  for = "unix";
                }
              ];

              edit = [
                {
                  run = "nvim %s";
                  desc = "Neovim";
                  block = true;
                }
              ];

              extract = [
                {
                  run = "ya pub extract --list %s";
                  desc = "Extract here";
                }
              ];
            };

            open = {
              prepend_rules = [
                {
                  mime = "image/*";
                  use = "imv_image";
                }
                {
                  mime = "video/*";
                  use = "mpv_video";
                }
                {
                  mime = "application/pdf";
                  use = "zathura_pdf";
                }
                {
                  mime = "text/*";
                  use = "nvim_code";
                }
                {
                  mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
                  use = [
                    "extract"
                    "reveal"
                  ];
                }
              ];
            };

            mgr = {
              show_hidden = true;
            };
          };
        };
      };
    };
}
