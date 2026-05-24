# Git configuration with GPG signing
_:

{
  flake.modules.homeManager.git =
    { config, lib, pkgs, ... }:
    let
      cfg = config.features.git;
      commitMsgHook = pkgs.writeShellScript "commit-msg" (builtins.readFile ./commit-msg);
    in
    {
      options.features.git.enable = lib.mkEnableOption "git version control";

      config = lib.mkIf cfg.enable {
      programs.git = {
        enable = true;
        lfs.enable = true;
        signing.key = "31B434AD0A1C3224";
        signing.signByDefault = true;

        hooks = {
          commit-msg = commitMsgHook;
        };

        settings = {
          user = {
            name = "M. Rehan Abbasi";
            email = "mrehanabbasi@proton.me";
          };
          pull.rebase = true;
          init.defaultBranch = "main";
          push.autosetupremote = true;
          url = {
            "ssh://git@github.com/" = {
              insteadOf = "https://github.com/";
            };
          };
          alias = {
            br = "branch";
            ci = "commit";
            co = "checkout";
            df = "diff";
            info = "remote -v";
            lg = "log -p";
            lg2 = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %c(bold blue)<%an>%Creset' --abbrev-commit";
            lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
            lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
            st = "status";
          };
        };
      };
      };
    };
}
