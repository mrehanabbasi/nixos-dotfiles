{ ... }:

{
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
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
      "x-scheme-handler/about" = [ "brave-browser.desktop" ];
      "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];
    };
  };
}
