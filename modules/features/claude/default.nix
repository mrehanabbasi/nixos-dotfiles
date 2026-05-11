# Claude Code - AI coding assistant configuration
# Extends the upstream Home Manager claude-code module with custom defaults
_:

{
  flake.modules.homeManager.claude =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      # Status line script with Catppuccin colors and real-time session info
      statuslineScript = pkgs.writeShellScript "statusline-command" (
        builtins.readFile ./statusline-command.sh
      );

      # Bundle all JS hooks into one derivation so node's require('./caveman-config')
      # resolves correctly. HM's programs.claude-code.hooks creates a separate store
      # derivation per file — symlink resolution lands each file in its own isolated
      # dir, so relative require() calls fail. Copying all files into one derivation
      # keeps them in the same __dirname.
      cavemanHooks = pkgs.runCommandLocal "claude-caveman-hooks" { } ''
        mkdir $out
        cp ${../../../.claude/hooks/caveman-activate.js} $out/caveman-activate.js
        cp ${../../../.claude/hooks/caveman-mode-tracker.js} $out/caveman-mode-tracker.js
        cp ${../../../.claude/hooks/caveman-config.js} $out/caveman-config.js
      '';
    in
    {
      programs.claude-code = {
        enable = lib.mkDefault true;
        settings = {
          "$schema" = "https://json.schemastore.org/claude-code-settings.json";
          alwaysThinkingEnabled = true;

          statusLine = {
            type = "command";
            command = "bash ${statuslineScript}";
          };

          hooks = {
            SessionStart = [
              {
                hooks = [
                  {
                    type = "command";
                    command = "node .claude/hooks/caveman-activate.js";
                  }
                ];
              }
            ];
            UserPromptSubmit = [
              {
                hooks = [
                  {
                    type = "command";
                    command = "node .claude/hooks/caveman-mode-tracker.js";
                  }
                ];
              }
            ];
            PreToolUse = [
              {
                matcher = "Edit";
                hooks = [
                  {
                    type = "command";
                    command = ".claude/hooks/protect-files.sh";
                  }
                ];
              }
              {
                matcher = "Write";
                hooks = [
                  {
                    type = "command";
                    command = ".claude/hooks/protect-files.sh";
                  }
                ];
              }
            ];
            PostToolUse = [
              {
                matcher = "Edit";
                hooks = [
                  {
                    type = "command";
                    command = ".claude/hooks/auto-format-nix.sh";
                  }
                ];
              }
            ];
          };

          permissions = {
            allow = [
              "Edit"
              "Glob"
              "Grep"
              "Read"
              "WebFetch"
              "WebSearch"
              "Write"
              "Skill(commit-message)"
              "Skill(diagnose)"
              "Skill(emergency-rollback)"
              "Skill(flake-update)"
              "Skill(nixos-rebuild)"
              "Skill(pre-commit-check)"
              "Bash(awk *)"
              "Bash(base64 *)"
              "Bash(basename *)"
              "Bash(cat *)"
              "Bash(cd *)"
              "Bash(cut *)"
              "Bash(date)"
              "Bash(date *)"
              "Bash(diff *)"
              "Bash(dirname *)"
              "Bash(du *)"
              "Bash(echo *)"
              "Bash(env)"
              "Bash(env *)"
              "Bash(file *)"
              "Bash(find *)"
              "Bash(head *)"
              "Bash(hostname)"
              "Bash(hostname *)"
              "Bash(id)"
              "Bash(id *)"
              "Bash(jq *)"
              "Bash(ls)"
              "Bash(ls *)"
              "Bash(md5sum *)"
              "Bash(mkdir *)"
              "Bash(printenv)"
              "Bash(printenv *)"
              "Bash(pwd)"
              "Bash(realpath *)"
              "Bash(sed *)"
              "Bash(sha256sum *)"
              "Bash(sort *)"
              "Bash(stat *)"
              "Bash(tail *)"
              "Bash(tee *)"
              "Bash(tr *)"
              "Bash(tree)"
              "Bash(tree *)"
              "Bash(uname)"
              "Bash(uname *)"
              "Bash(uniq *)"
              "Bash(wc *)"
              "Bash(whereis *)"
              "Bash(which *)"
              "Bash(whoami)"
              "Bash(xargs *)"
              "Bash(git add *)"
              "Bash(git branch)"
              "Bash(git branch -a)"
              "Bash(git branch -r)"
              "Bash(git branch -v)"
              "Bash(git branch -v *)"
              "Bash(git diff)"
              "Bash(git diff *)"
              "Bash(git -C * diff)"
              "Bash(git -C * diff *)"
              "Bash(git fetch)"
              "Bash(git fetch *)"
              "Bash(git log)"
              "Bash(git log *)"
              "Bash(git -C * log)"
              "Bash(git -C * log *)"
              "Bash(git remote)"
              "Bash(git remote *)"
              "Bash(git rev-parse *)"
              "Bash(git show *)"
              "Bash(git stash list)"
              "Bash(git stash show *)"
              "Bash(git status)"
              "Bash(git -C * status)"
              "Bash(git -C * status *)"
            ];
            ask = [
              "Bash(cp *)"
              "Bash(mv *)"
              "Bash(rm *)"
              "Bash(rmdir *)"
              "Bash(touch *)"
              "Bash(curl *)"
              "Bash(wget *)"
              "Bash(git stash)"
              "Bash(git stash apply *)"
              "Bash(git stash clear)"
              "Bash(git stash drop *)"
              "Bash(git stash pop *)"
              "Bash(git stash push *)"
              "Bash(git branch -D *)"
              "Bash(git branch -d *)"
              "Bash(git branch --delete *)"
              "Bash(git checkout *)"
              "Bash(git commit *)"
              "Bash(git merge *)"
              "Bash(git rebase *)"
              "Bash(git reset *)"
              "Bash(git tag *)"
              "Bash(kill *)"
              "Bash(pkill *)"
            ];
            deny = [
              "Bash(chmod *)"
              "Bash(chown *)"
              "Bash(git clean *)"
              "Bash(git push *)"
              "Bash(sudo *)"
            ];
          };
        };
      };

      # Hook files — all placed in ~/.claude/hooks/ via home.file so Claude Code
      # can find them. JS files share one derivation (cavemanHooks) so that
      # require('./caveman-config') resolves correctly after symlink resolution.
      # Bash hooks get executable = true since HM strips the bit on copy.
      home.file = lib.mkIf config.programs.claude-code.enable {
        ".claude/hooks/caveman-activate.js".source = "${cavemanHooks}/caveman-activate.js";
        ".claude/hooks/caveman-mode-tracker.js".source = "${cavemanHooks}/caveman-mode-tracker.js";
        ".claude/hooks/protect-files.sh" = {
          source = ../../../.claude/hooks/protect-files.sh;
          executable = true;
        };
        ".claude/hooks/auto-format-nix.sh" = {
          source = ../../../.claude/hooks/auto-format-nix.sh;
          executable = true;
        };
      };

      # Ensure jq dependency is available (required by statusline script)
      home.packages = lib.mkIf config.programs.claude-code.enable [
        pkgs.jq
      ];
    };
}
