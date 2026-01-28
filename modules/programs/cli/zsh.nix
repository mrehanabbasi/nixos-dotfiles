# Zsh shell configuration
{ ... }:

{
  flake.modules.nixos.zsh =
    { ... }:
    {
      programs.zsh.enable = true;
    };

  flake.modules.homeManager.zsh =
    { config, pkgs, ... }:
    {
      programs.zsh = {
        enable = true;
        history.size = 10000;
        history.path = "${config.xdg.dataHome}/zsh/history";
        shellAliases = {
          ls = "eza --icons --color=always";
          ll = "eza -al --icons --color=always";
        };
        initContent = ''
          # Set GPG_TTY for pinentry-tty to work in CLI tools (e.g., Claude Code commits)
          export GPG_TTY=$(tty)

          bindkey -e

          # disable sort when completing `git checkout`
          zstyle ':completion:*:git-checkout:*' sort false
          # set descriptions format to enable group support
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
        '';
        oh-my-zsh = {
          enable = false;
          plugins = [
            "git"
            "sudo"
            "golang"
            "command-not-found"
            "docker"
            "docker-compose"
            "eza"
            "fzf"
            "gh"
            "podman"
            "ssh"
            "tailscale"
            "zoxide"
          ];
        };
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
        ];
      };
    };
}
