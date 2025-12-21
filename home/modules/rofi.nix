{ ... }:

{
  catppuccin.rofi.enable = true;

  xdg.configFile = {
    "rofi/launchers".source = ../rofi/launchers;
    "rofi/scripts/launcher_t1".source = ../rofi/scripts/launcher_t1;
    "rofi/colors".source = ../rofi/colors;
  };

  programs.rofi = {
    enable = true;

  # Font configuration
  font = "JetBrainsMono Nerd Font 16";

  # Terminal to use - adjust to your preferred terminal
  terminal = "rofi-sensible-terminal";

  # Location and behavior
  location = "center";
  cycle = true;

  # Additional configuration from config.rasi
  extraConfig = {
    # ===== General Settings =====
    modi = "drun,run,filebrowser,window";
    case-sensitive = false;
    filter = "";
    scroll-method = 0;
    normalize-match = true;
    show-icons = true;
    icon-theme = "MacTahoe-dark";
    steal-focus = false;

    # ===== Matching Settings =====
    matching = "normal";
    tokenize = true;

    # ===== SSH Settings =====
    ssh-client = "ssh";
    ssh-command = "{terminal} -e {ssh-client} {host} [-p {port}]";
    parse-hosts = true;
    parse-known-hosts = true;

    # ===== Drun Settings =====
    drun-categories = "";
    drun-match-fields = "name,generic,exec,categories,keywords";
    drun-display-format = "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
    drun-show-actions = false;
    drun-url-launcher = "xdg-open";
    drun-use-desktop-cache = false;
    drun-reload-desktop-cache = false;

    # ===== Run Settings =====
    run-command = "{cmd}";
    run-list-command = "";
    run-shell-command = "{terminal} -e {cmd}";

    # ===== Window Switcher Settings =====
    window-match-fields = "title,class,role,name,desktop";
    window-command = "wmctrl -i -R {window}";
    window-format = "{w} - {c} - {t:0}";
    window-thumbnail = false;

    # ===== History and Sorting =====
    disable-history = true;
    sorting-method = "normal";
    max-history-size = 25;

    # ===== Display Labels =====
    display-window = "Windows";
    display-windowcd = "Window CD";
    display-run = "Run";
    display-ssh = "SSH";
    display-drun = "Apps";
    display-combi = "Combi";
    display-keys = "Keys";
    display-filebrowser = "Files";

    # ===== Misc Settings =====
    sort = false;
    threads = 0;
    click-to-exit = true;
  };
  };
}
