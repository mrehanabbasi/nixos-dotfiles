# Claude Code - AI coding assistant configuration with XDG compliance
# Extends the upstream Home Manager claude-code module with custom defaults
{ inputs, ... }:

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
    in
    {
      # Use upstream Home Manager claude-code module for package only
      # Settings are managed via XDG to avoid conflicts with symlink structure
      programs.claude-code = {
        enable = lib.mkDefault true;
        # DO NOT set settings here - it creates .claude/settings.json which conflicts
        # with our .claude symlink. Settings are managed via xdg.configFile below.
      };

      # Ensure jq dependency is available (required by statusline script)
      home.packages = lib.mkIf config.programs.claude-code.enable [
        pkgs.jq
      ];

      # XDG directory structure with config, data, cache, and state
      xdg = lib.mkIf config.programs.claude-code.enable {
        # Config: symlinks to runtime data in proper XDG locations
        configFile = {
          # Settings file with custom configuration
          "claude/settings.json".text = builtins.toJSON {
            "$schema" = "https://json.schemastore.org/claude-code-settings.json";

            # Enable extended thinking mode
            alwaysThinkingEnabled = true;

            # Custom status line with Catppuccin colors
            statusLine = {
              type = "command";
              command = "bash ${statuslineScript}";
            };

            # Pre/post tool execution hooks
            hooks = {
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

            # Tool permissions configuration
            permissions = {
              allow = [
                # Core tools
                "Edit"
                "Glob"
                "Grep"
                "Read"
                "WebFetch"
                "WebSearch"
                "Write"

                # Skills
                "Skill(commit-message)"
                "Skill(diagnose)"
                "Skill(emergency-rollback)"
                "Skill(flake-update)"
                "Skill(nixos-rebuild)"
                "Skill(pre-commit-check)"

                # Safe Bash commands - file info
                "Bash(awk *)"
                "Bash(base64 *)"
                "Bash(basename *)"
                "Bash(cat *)"
                "Bash(cd *)"
                "Bash(cut *)"
                "Bash(date *)"
                "Bash(diff *)"
                "Bash(dirname *)"
                "Bash(du *)"
                "Bash(echo *)"
                "Bash(env *)"
                "Bash(file *)"
                "Bash(find *)"
                "Bash(head *)"
                "Bash(hostname *)"
                "Bash(id *)"
                "Bash(jq *)"
                "Bash(ls *)"
                "Bash(md5sum *)"
                "Bash(mkdir *)"
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
                "Bash(tree *)"
                "Bash(uname *)"
                "Bash(uniq *)"
                "Bash(wc *)"
                "Bash(whereis *)"
                "Bash(which *)"
                "Bash(whoami)"
                "Bash(xargs *)"

                # Git read operations
                "Bash(git add *)"
                "Bash(git branch)"
                "Bash(git branch -a)"
                "Bash(git branch -r)"
                "Bash(git branch -v *)"
                "Bash(git diff *)"
                "Bash(git fetch *)"
                "Bash(git log *)"
                "Bash(git remote *)"
                "Bash(git rev-parse *)"
                "Bash(git show *)"
                "Bash(git stash *)"
                "Bash(git status)"
                "Bash(git -C * status)"
              ];
              ask = [
                # File operations
                "Bash(cp *)"
                "Bash(mv *)"
                "Bash(rm *)"
                "Bash(rmdir *)"
                "Bash(touch *)"

                # Network
                "Bash(curl *)"
                "Bash(wget *)"

                # Git write operations
                "Bash(git branch -D *)"
                "Bash(git branch -d *)"
                "Bash(git branch --delete *)"
                "Bash(git checkout *)"
                "Bash(git commit *)"
                "Bash(git merge *)"
                "Bash(git rebase *)"
                "Bash(git reset *)"
                "Bash(git tag *)"

                # Process management
                "Bash(kill *)"
                "Bash(pkill *)"
              ];
              deny = [
                # Dangerous operations
                "Bash(chmod *)"
                "Bash(chown *)"
                "Bash(git clean *)"
                "Bash(git push *)"
                "Bash(sudo *)"
              ];
            };
          };

          # Symlinks from ~/.config/claude to XDG locations
          # This allows Claude Code to access runtime data in proper XDG locations
          "claude/projects".source =
            config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/claude/projects";
          "claude/history.jsonl".source =
            config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/claude/history.jsonl";
          "claude/plans".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/claude/plans";
          "claude/file-history".source =
            config.lib.file.mkOutOfStoreSymlink "${config.xdg.cacheHome}/claude/file-history";
          "claude/session-env".source =
            config.lib.file.mkOutOfStoreSymlink "${config.xdg.cacheHome}/claude/session-env";
          "claude/shell-snapshots".source =
            config.lib.file.mkOutOfStoreSymlink "${config.xdg.cacheHome}/claude/shell-snapshots";
          "claude/statsig".source =
            config.lib.file.mkOutOfStoreSymlink "${config.xdg.cacheHome}/claude/statsig";
          "claude/todos".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.stateHome}/claude/todos";
          "claude/debug".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.stateHome}/claude/debug";

          # Credentials: MANUAL SETUP REQUIRED
          # Users must create: ~/.local/share/claude/secrets/credentials.json
          # This file contains OAuth tokens and should NOT be managed by Nix
          "claude/.credentials.json".source =
            config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/claude/secrets/credentials.json";
        };

        # Data: persistent user data
        dataFile = {
          "claude/projects/.keep".text = "";
          "claude/plans/.keep".text = "";
          "claude/secrets/.keep".text = "";
        };

        # Cache: temporary cache data
        cacheFile = {
          "claude/file-history/.keep".text = "";
          "claude/session-env/.keep".text = "";
          "claude/shell-snapshots/.keep".text = "";
          "claude/statsig/.keep".text = "";
        };

        # State: application state and logs
        stateFile = {
          "claude/todos/.keep".text = "";
          "claude/debug/.keep".text = "";
        };
      };

      # Main symlink: ~/.claude -> ~/.config/claude
      # This ensures Claude Code finds config even if it doesn't fully support XDG
      home.file.".claude" = lib.mkIf config.programs.claude-code.enable {
        source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/claude";
      };
    };
}
