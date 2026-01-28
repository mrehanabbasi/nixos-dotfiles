# FZF - fuzzy finder with Catppuccin theme
{ ... }:

{
  flake.modules.homeManager.fzf =
    { ... }:
    {
      catppuccin.fzf.enable = true;

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        tmux.enableShellIntegration = true;
      };
    };
}
