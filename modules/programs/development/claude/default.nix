# Claude Code - AI coding assistant configuration
# Manages status line with real-time session information and XDG directory structure
_:

{
  flake.modules.homeManager.claude =
    { pkgs, config, ... }:
    let
      statuslineScript = pkgs.writeShellScript "statusline-command" (
        builtins.readFile ./statusline-command.sh
      );
    in
    {
      # Ensure jq dependency is available
      home.packages = with pkgs; [
        jq # Required by statusline script for JSON parsing
      ];

      # XDG directory structure with config, data, cache, and state
      xdg = {
        # Config: settings.json and symlinks to runtime data
        configFile = {
          "claude/settings.json".text = builtins.toJSON {
            statusLine = {
              type = "command";
              command = "bash ${statuslineScript}";
            };
            alwaysThinkingEnabled = true;
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
      # This ensures Claude Code finds config even if it doesn't support XDG
      home.file.".claude".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/claude";
    };
}
