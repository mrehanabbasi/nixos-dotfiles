# MIME type associations and default applications
_:

{
  flake.modules.homeManager.mime-apps = _: {
    xdg.desktopEntries.neovimGhostty = {
      name = "Neovim in Ghostty";
      exec = "ghostty -e nvim %F";
      terminal = false;
      mimeType = [ "text/plain" ];
      icon = "utilities-terminal";
      comment = "Edit text files in Neovim using Ghostty";
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = [ "neovimGhostty.desktop" ];
        "text/html" = [ "brave-browser.desktop" ];
        "x-scheme-handler/http" = [ "handlr.desktop" ];
        "x-scheme-handler/https" = [ "handlr.desktop" ];
        "x-scheme-handler/about" = [ "brave-browser.desktop" ];
        "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];
        "inode/directory" = [ "thunar.desktop" ];

        # Archives
        "application/zip" = [ "xarchiver.desktop" ];
        "application/x-7z-compressed" = [ "xarchiver.desktop" ];
        "application/x-tar" = [ "xarchiver.desktop" ];
        "application/gzip" = [ "xarchiver.desktop" ];
        "application/x-bzip2" = [ "xarchiver.desktop" ];
        "application/x-xz" = [ "xarchiver.desktop" ];
        "application/x-rar" = [ "xarchiver.desktop" ];
        "application/x-compressed-tar" = [ "xarchiver.desktop" ];
      };
    };
  };
}
