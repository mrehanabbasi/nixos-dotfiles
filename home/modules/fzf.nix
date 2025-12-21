{ ... }:

{
  catppuccin.fzf.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
  };
}
