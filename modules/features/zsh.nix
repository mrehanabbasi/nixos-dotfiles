# Zsh shell configuration
_:

{
  flake.modules.nixos.zsh =
    { config, lib, ... }:
    let
      cfg = config.features.zsh;
    in
    {
      options.features.zsh.enable = lib.mkEnableOption "zsh shell";

      config = lib.mkIf cfg.enable {
        programs.zsh.enable = true;
      };
    };

  flake.modules.homeManager.zsh =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.zsh;
    in
    {
      options.features.zsh.enable = lib.mkEnableOption "zsh shell";

      config = lib.mkIf cfg.enable {
      home.activation.createZshCacheDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "${config.xdg.cacheHome}/oh-my-zsh/completions"
      '';

      programs.zsh = {
        enable = true;
        history.size = 10000;
        history.path = "${config.xdg.dataHome}/zsh/history";
        sessionVariables = {
          ZSH_CACHE_DIR = "${config.xdg.cacheHome}/oh-my-zsh";
        };
        shellAliases = {
          ls = "eza --icons --color=always";
          ll = "eza -al --icons --color=always";
        };
        shellGlobalAliases = {
          NE = "2>/dev/null";
          ND = ">/dev/null";
          NUL = ">/dev/null 2>&1";
          JQ = "| jq";
          C = "| wl-copy";
        };
        initContent = lib.mkMerge [
          (lib.mkBefore ''
            chmod u+w "$ZSH_CACHE_DIR/completions/_docker" 2>/dev/null || true
          '')
          ''
          # Set GPG_TTY for pinentry-tty to work in CLI tools (e.g., Claude Code commits)
          export GPG_TTY=$(tty)

          bindkey -e

          autoload -Uz edit-command-line
          zle -N edit-command-line
          bindkey '^X^e' edit-command-line

          zle -N copy-command
          bindkey '^Xc' copy-command
          bindkey ' ' magic-space

          bindkey -s '^Xgc' 'git commit -am ""\C-b'

          # disable sort when completing `git checkout`
          zstyle ':completion:*:git-checkout:*' sort false

          # set descriptions format to enable group support
          # NOTE: don't use escape sequences herem fzf-tab will ignore them
          zstyle ':completion:*:descriptions' format '[%d]'

          # set list-colors to enable filename colorizing
          zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

          # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
          zstyle ':completion:*' menu no

          # preview directory's content with eza when completing cd
          zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
          zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
          zstyle ':fzf-tab:complete:ls:*' fzf-preview 'cat $realpath'

          # switch group using `<` and `>`
          zstyle ':fzf-tab:*' switch-group '<' '>'

          # Suffix aliases
          alias -s md='bat'
          alias -s mov='open'
          alias -s png='open'
          alias -s mp4='open'
          alias -s go='$EDITOR'
          alias -s js='$EDITOR'
          alias -s ts='$EDITOR'
          alias -s yaml='bat -l yaml'
          alias -s json='jq <'
          ''
        ];
        plugins = [
          {
            name = "zsh-autosuggestions";
            src = pkgs.zsh-autosuggestions;
            file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
          }
          {
            name = "zsh-completions";
            src = pkgs.zsh-completions;
            file = "share/zsh-completions/zsh-completions.zsh";
          }
          {
            name = "zsh-syntax-highlighting";
            src = pkgs.zsh-syntax-highlighting;
            file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
          }
          {
            name = "fzf-tab";
            src = pkgs.zsh-fzf-tab;
            file = "share/fzf-tab/fzf-tab.plugin.zsh";
          }
          # oh-my-zsh plugins (sourced directly, no framework)
          {
            name = "git";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git";
            file = "git.plugin.zsh";
          }
          {
            name = "sudo";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/sudo";
            file = "sudo.plugin.zsh";
          }
          {
            name = "golang";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/golang";
            file = "golang.plugin.zsh";
          }
          {
            name = "command-not-found";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/command-not-found";
            file = "command-not-found.plugin.zsh";
          }
          {
            name = "docker";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/docker";
            file = "docker.plugin.zsh";
          }
          {
            name = "docker-compose";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/docker-compose";
            file = "docker-compose.plugin.zsh";
          }
          {
            name = "eza";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/eza";
            file = "eza.plugin.zsh";
          }
          {
            name = "fzf";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/fzf";
            file = "fzf.plugin.zsh";
          }
          {
            name = "gh";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/gh";
            file = "gh.plugin.zsh";
          }
          {
            name = "podman";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/podman";
            file = "podman.plugin.zsh";
          }
          {
            name = "ssh";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/ssh";
            file = "ssh.plugin.zsh";
          }
          {
            name = "tailscale";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/tailscale";
            file = "tailscale.plugin.zsh";
          }
          {
            name = "zoxide";
            src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/zoxide";
            file = "zoxide.plugin.zsh";
          }
        ];
      };
      };
    };
}
