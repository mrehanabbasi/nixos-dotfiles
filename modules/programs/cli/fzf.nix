# FZF - fuzzy finder with Catppuccin theme
_:

{
  flake.modules.homeManager.fzf =
    _:
    {
      catppuccin.fzf.enable = true;

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        tmux.enableShellIntegration = true;
      };
    };
}
