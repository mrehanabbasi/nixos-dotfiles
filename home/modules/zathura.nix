{ ... }:

{
  catppuccin.zathura.enable = true;

  programs.zathura = {
    enable = true;
    options = {
    # adjust-open = "best-fit";
    adjust-open = "width";

    recolor = false;
    # sandbox = "none";
    selection-clipboard = "clipboard";
    statusbar-h-padding = 0;
    statusbar-v-padding = 0;
    page-v-padding = 0;
    page-h-padding = 0;

    font = "JetBrainsMono Nerd Font 12";
  };
  mappings = {
    u = "scroll half-up";
    d = "scroll half-down";
    T = "toggle_page_mode";
    J = "scroll full-down";
    K = "scroll full-up";
    r = "reload";
    R = "rotate";
    A = "zoom in";
    D = "zoom out";
    i = "recolor";
    p = "print";
    b = "toggle_statusbar";
  };
  };
}
