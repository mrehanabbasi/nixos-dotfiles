# Yazi - terminal file manager with Catppuccin theme
{ ... }:

{
  flake.modules.homeManager.yazi = { ... }: {
    catppuccin.yazi.enable = true;

    programs.yazi = {
      enable = true;

      settings = {
        opener = {
          imv_image = [{
            run = ''imv "$0"'';
            desc = "imv Image Viewer";
            block = false;
            for = "unix";
          }];

          mpv_video = [{
            run = ''mpv "$0"'';
            desc = "mpv Video Player";
            block = false;
            for = "unix";
          }];

          zathura_pdf = [{
            run = ''zathura "$0"'';
            desc = "Zathura PDF Reader";
            block = false;
            for = "unix";
          }];

          nvim_code = [{
            run = ''nvim "$0"'';
            desc = "Neovim Code Editor";
            block = true;
            for = "unix";
          }];

          edit = [{
            run = ''nvim "$@"'';
            desc = "Neovim";
            block = true;
          }];
        };

        open = {
          prepend_rules = [
            { mime = "image/*"; use = "imv_image"; }
            { mime = "video/*"; use = "mpv_video"; }
            { mime = "application/pdf"; use = "zathura_pdf"; }
            { mime = "text/*"; use = "nvim_code"; }
          ];
        };

        mgr = { show_hidden = true; };
      };
    };
  };
}
