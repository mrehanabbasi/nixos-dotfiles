# FZF - fuzzy finder
_:

{
  flake.modules.homeManager.fzf =
    { config, lib, ... }:
    let
      cfg = config.features.fzf;
    in
    {
      options.features.fzf.enable = lib.mkEnableOption "fzf fuzzy finder";
      config = lib.mkIf cfg.enable {
        catppuccin.fzf.enable = true;

        programs.fzf = {
          enable = true;
          enableZshIntegration = true;
          tmux.enableShellIntegration = true;
        };
      };
    };
}
