# Implementation Plan: Claude Code Migration to NixOS with XDG Compliance

## Overview

Migrate Claude Code configuration from `~/.claude` to a declarative NixOS module using home-manager with full XDG Base Directory compliance. This includes:
- Managing `settings.json` and `statusline-command.sh` via Nix
- Organizing runtime data according to XDG standards
- Creating symlink structure for backward compatibility
- Cleaning up the old `~/.claude` directory structure

## User Preferences

Based on clarification:
- **Config Location**: XDG-compliant `~/.config/claude/`
- **Script Method**: Fully declarative (Nix store)
- **Migration Scope**: All config to Nix, move runtime to XDG directories

## Architecture

### Directory Structure (XDG-Compliant)

```
~/.config/claude/          # XDG_CONFIG_HOME - configuration files
├── settings.json          # Nix-managed (symlink to store)
└── statusline-command.sh  # Nix-managed (symlink to store)

~/.local/share/claude/     # XDG_DATA_HOME - persistent data
├── projects/              # Session transcripts (17MB)
├── history.jsonl          # Command history (65KB)
└── plans/                 # User planning documents (user-writable)

~/.cache/claude/           # XDG_CACHE_HOME - cache data
├── file-history/          # File version cache (1MB)
├── session-env/           # Session environment (88KB)
├── shell-snapshots/       # Shell state snapshots (520KB)
└── statsig/               # Analytics cache (16KB)

~/.local/state/claude/     # XDG_STATE_HOME - state/logs
├── todos/                 # Task lists (152KB)
└── debug/                 # Debug logs (4.9MB)

~/.local/share/claude/secrets/  # User-managed secrets
└── credentials.json       # OAuth tokens (NOT in Nix)

~/.claude -> ~/.config/claude/  # Symlink for backward compatibility
```

### Module Structure

```
modules/programs/development/claude/
├── default.nix           # Main module definition
└── statusline-command.sh # Status line script (129 lines)
```

## Implementation Steps

### Step 1: Create Module Files

**File**: `modules/programs/development/claude/default.nix`

```nix
# Claude Code - AI coding assistant configuration
# Manages status line with real-time session information and XDG directory structure
{ ... }:

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

      # XDG Config: settings.json and statusline script
      xdg.configFile."claude/settings.json".text = builtins.toJSON {
        statusLine = {
          type = "command";
          command = "bash ${statuslineScript}";
        };
        alwaysThinkingEnabled = true;
      };

      # Create XDG directory structure
      xdg.dataFile."claude/plans/.keep".text = "";
      xdg.cacheFile."claude/.keep".text = "";
      xdg.stateFile."claude/.keep".text = "";

      # Backward compatibility symlink: ~/.claude -> ~/.config/claude
      # This ensures Claude Code finds config even if it doesn't support XDG
      home.file.".claude".source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.configHome}/claude";
    };
}
```

**File**: `modules/programs/development/claude/statusline-command.sh`

Copy existing `/home/rehan/.claude/statusline-command.sh` as-is (129 lines). No modifications needed.

### Step 2: Integrate Module

**Modify**: `modules/users/rehan/default.nix`

Add to imports list (around line 75 in Development section):

```nix
# Development
inputs.self.modules.homeManager.gpg
inputs.self.modules.homeManager.opencode
inputs.self.modules.homeManager.claude  # NEW
```

### Step 3: Migrate Runtime Data

Before building, manually migrate existing runtime data to XDG locations:

```bash
# Backup original
cp -r ~/.claude ~/.claude.backup

# Create XDG directories
mkdir -p ~/.local/share/claude
mkdir -p ~/.cache/claude
mkdir -p ~/.local/state/claude
mkdir -p ~/.local/share/claude/secrets

# Move persistent data to XDG_DATA_HOME
mv ~/.claude/projects ~/.local/share/claude/
mv ~/.claude/history.jsonl ~/.local/share/claude/
mv ~/.claude/plans ~/.local/share/claude/

# Move cache data to XDG_CACHE_HOME
mv ~/.claude/file-history ~/.cache/claude/
mv ~/.claude/session-env ~/.cache/claude/
mv ~/.claude/shell-snapshots ~/.cache/claude/
mv ~/.claude/statsig ~/.cache/claude/

# Move state/logs to XDG_STATE_HOME
mv ~/.claude/todos ~/.local/state/claude/
mv ~/.claude/debug ~/.local/state/claude/

# Move credentials to secure location
mv ~/.claude/.credentials.json ~/.local/share/claude/secrets/credentials.json

# Remove now-empty config files (will be managed by Nix)
rm ~/.claude/settings.json
rm ~/.claude/statusline-command.sh
rm ~/.claude/statusline-debug.json 2>/dev/null || true

# Remove old directory (will be replaced by symlink)
rmdir ~/.claude
```

### Step 4: Update Claude Code to Use XDG Paths

**Challenge**: Claude Code likely hardcodes `~/.claude` paths.

**Solution**: The symlink `~/.claude -> ~/.config/claude` provides backward compatibility. However, Claude Code will still write runtime data to `~/.claude/*`, which resolves to `~/.config/claude/*`.

**Better Solution**: Create selective symlinks to redirect writes to XDG locations:

```bash
# After NixOS rebuild creates ~/.config/claude/
cd ~/.config/claude

# Create symlinks to XDG locations for runtime data
ln -s ../../.local/share/claude/projects projects
ln -s ../../.local/share/claude/history.jsonl history.jsonl
ln -s ../../.local/share/claude/plans plans
ln -s ../../cache/claude/file-history file-history
ln -s ../../cache/claude/session-env session-env
ln -s ../../cache/claude/shell-snapshots shell-snapshots
ln -s ../../cache/claude/statsig statsig
ln -s ../../.local/state/claude/todos todos
ln -s ../../.local/state/claude/debug debug
ln -s ../../.local/share/claude/secrets/credentials.json .credentials.json
```

Then create main symlink:
```bash
ln -s .config/claude ~/.claude
```

**Result**:
- Config files in `~/.config/claude/` (Nix-managed)
- Runtime data in proper XDG locations
- Claude Code accesses via `~/.claude/` symlink
- Writes go to correct XDG locations via nested symlinks

### Step 5: Automate Symlink Creation

Update module to create all necessary symlinks:

```nix
{
  flake.modules.homeManager.claude =
    { pkgs, config, ... }:
    let
      statuslineScript = pkgs.writeShellScript "statusline-command" (
        builtins.readFile ./statusline-command.sh
      );
    in
    {
      home.packages = with pkgs; [ jq ];

      xdg.configFile."claude/settings.json".text = builtins.toJSON {
        statusLine = {
          type = "command";
          command = "bash ${statuslineScript}";
        };
        alwaysThinkingEnabled = true;
      };

      # Create XDG directories
      xdg.dataFile."claude/plans/.keep".text = "";
      xdg.cacheFile."claude/.keep".text = "";
      xdg.stateFile."claude/.keep".text = "";

      # Create symlinks from ~/.config/claude to XDG locations
      xdg.configFile."claude/projects".source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.dataHome}/claude/projects";
      xdg.configFile."claude/history.jsonl".source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.dataHome}/claude/history.jsonl";
      xdg.configFile."claude/plans".source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.dataHome}/claude/plans";
      xdg.configFile."claude/file-history".source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.cacheHome}/claude/file-history";
      xdg.configFile."claude/session-env".source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.cacheHome}/claude/session-env";
      xdg.configFile."claude/shell-snapshots".source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.cacheHome}/claude/shell-snapshots";
      xdg.configFile."claude/statsig".source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.cacheHome}/claude/statsig";
      xdg.configFile."claude/todos".source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.stateHome}/claude/todos";
      xdg.configFile."claude/debug".source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.stateHome}/claude/debug";
      xdg.configFile."claude/.credentials.json".source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.dataHome}/claude/secrets/credentials.json";

      # Main symlink: ~/.claude -> ~/.config/claude
      home.file.".claude".source = config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.configHome}/claude";
    };
}
```

### Step 6: Build and Validate

```bash
# Navigate to repo
cd /home/rehan/nixos-dotfiles

# Format new files
nixfmt modules/programs/development/claude/default.nix

# Validate flake
nix flake check

# Build (without switching)
sudo nixos-rebuild build --flake .#one-piece

# If successful, switch
sudo nixos-rebuild switch --flake .#one-piece
```

### Step 7: Functional Testing

```bash
# Verify XDG structure
ls -la ~/.config/claude/
ls -la ~/.local/share/claude/
ls -la ~/.cache/claude/
ls -la ~/.local/state/claude/

# Verify main symlink
ls -la ~/.claude
# Should show: .claude -> .config/claude

# Verify nested symlinks
ls -la ~/.config/claude/
# Should show symlinks to XDG locations

# Test statusline script directly
echo '{"model":{"display_name":"Claude Sonnet 4.5"},"workspace":{"project_dir":"'"$(pwd)"'"},"transcript_path":"/tmp/test.txt","output_style":{"name":"default"}}' | bash ~/.config/claude/statusline-command.sh

# Test Claude Code integration
claude .
# Verify status line appears at bottom
```

### Step 8: Clean Up Backup

```bash
# After confirming everything works
rm -rf ~/.claude.backup
```

## Files to Create/Modify

### CREATE:
1. `modules/programs/development/claude/default.nix` (~60 lines with symlinks)
2. `modules/programs/development/claude/statusline-command.sh` (copy from ~/.claude)

### MODIFY:
3. `modules/users/rehan/default.nix` (add import line ~75)

### MIGRATE (Manual):
4. Move runtime data from `~/.claude/` to XDG locations (Step 3)

## Key Design Decisions

### 1. XDG Compliance with Backward Compatibility

**Approach**: Use symlink structure to achieve both goals
- **Primary location**: `~/.config/claude/` (XDG-compliant)
- **Compatibility**: `~/.claude` symlink for apps expecting legacy path
- **Runtime data**: Proper XDG locations via nested symlinks

**Rationale**: Claude Code likely expects `~/.claude`, but we want XDG compliance. Symlinks provide transparent redirection.

### 2. Fully Declarative Script Management

**Approach**: Use `pkgs.writeShellScript` with `builtins.readFile`
- Script stored in Nix store (immutable)
- Modifications require rebuild
- Full reproducibility

**Rationale**: User preference for production-ready declarative approach. Changes are tracked in git and require intentional rebuild.

### 3. Runtime Data Organization

**XDG Directory Mapping**:
- `XDG_CONFIG_HOME`: Configuration files (settings.json, scripts)
- `XDG_DATA_HOME`: Persistent user data (projects, history, plans)
- `XDG_CACHE_HOME`: Temporary cache (file-history, session-env, shell-snapshots)
- `XDG_STATE_HOME`: Application state (todos, debug logs)

**Rationale**: Follows XDG Base Directory specification for proper data separation and easier backups.

### 4. Credentials Handling

**Location**: `~/.local/share/claude/secrets/credentials.json`
- NOT managed by Nix (sensitive data)
- Symlinked from `~/.config/claude/.credentials.json`
- User-writable and secure (600 permissions)

**Rationale**: Keep secrets out of Nix store and git while maintaining access for Claude Code.

## Edge Cases & Solutions

### Claude Code Creates New Runtime Files

**Scenario**: Claude Code creates new files in `~/.claude/`

**Solution**: Via symlink `~/.claude -> ~/.config/claude/`, new files appear in `~/.config/claude/`. You can then:
1. Manually move to appropriate XDG location
2. Add new symlink in Nix config
3. Rebuild to make symlink permanent

### Script Needs Quick Modification

**Scenario**: Need to test status line changes rapidly

**Solution**: Temporarily modify the script in-place:
```bash
# Find script in Nix store
readlink ~/.config/claude/statusline-command.sh

# For rapid testing, bypass Nix temporarily:
# Edit modules/programs/development/claude/statusline-command.sh
# Then rebuild when ready
```

### Credentials Get Overwritten

**Scenario**: Nix rebuild might affect .credentials.json symlink

**Solution**: The `mkOutOfStoreSymlink` ensures the symlink points outside Nix store, so credentials remain user-managed and won't be overwritten.

### Need to Rollback Migration

**Scenario**: Something breaks and need to restore old structure

**Solution**:
```bash
# Restore from backup
sudo nixos-rebuild switch --rollback
rm ~/.claude
mv ~/.claude.backup ~/.claude
```

## Validation Checklist

- [ ] Module builds without errors (`nix flake check`)
- [ ] NixOS rebuild succeeds
- [ ] `~/.config/claude/settings.json` exists and contains correct config
- [ ] `~/.config/claude/statusline-command.sh` is executable (via symlink)
- [ ] `~/.claude` symlink points to `~/.config/claude/`
- [ ] XDG directories created (`~/.local/share/claude/`, etc.)
- [ ] Nested symlinks work (e.g., `~/.claude/projects` → `~/.local/share/claude/projects`)
- [ ] Credentials accessible at `~/.claude/.credentials.json`
- [ ] Status line renders correctly in Claude Code
- [ ] Git integration works (branch/status display)
- [ ] Context usage tracking works (token count)
- [ ] Runtime data (history, projects) accessible
- [ ] New sessions create files in correct XDG locations

## Benefits of This Approach

1. **XDG Compliance**: Follows Linux desktop standards for data organization
2. **Declarative**: All configuration managed via Nix (reproducible)
3. **Backward Compatible**: Symlinks ensure Claude Code continues working
4. **Organized**: Data properly separated (config/data/cache/state)
5. **Maintainable**: Clear separation of Nix-managed vs user-managed files
6. **Versionable**: Configuration changes tracked in git
7. **Atomic**: Changes applied atomically with rollback support
8. **Clean**: No duplication, single source of truth

## Future Enhancements

1. **Auto-backup credentials**: Before rebuild, backup credentials to prevent loss
2. **Custom status line themes**: Module options for different color schemes
3. **Conditional features**: Enable/disable specific status line components
4. **Integration with system theme**: Auto-detect Catppuccin variant
5. **Additional Claude Code configs**: Manage agent definitions, skills, commands

## Critical Files Reference

For implementation, these files are most important:

1. **`modules/programs/development/claude/default.nix`** - Core module with symlink orchestration
2. **`modules/programs/development/claude/statusline-command.sh`** - Status line script (copy from current)
3. **`modules/users/rehan/default.nix`** - Integration point (add import)
4. **`modules/programs/cli/git/default.nix`** - Reference pattern for external scripts
5. **Current `~/.claude/` directory** - Source for migration and testing

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Symlink complexity breaks access | Low | High | Test thoroughly; maintain backup |
| Claude Code doesn't follow symlinks | Very Low | High | Test with actual Claude session |
| Runtime data path issues | Low | Medium | Comprehensive symlink coverage |
| Credentials get lost | Low | High | Keep backup; exclude from Nix management |
| Build fails due to circular symlinks | Low | Medium | Use mkOutOfStoreSymlink properly |

## Expected Outcome

After successful implementation:
- Claude Code configuration fully declarative and version-controlled
- All data organized according to XDG standards
- Transparent operation - Claude Code works identically
- Easy to reproduce on new machines
- Clean separation of config vs runtime data
- Backward compatible with existing Claude Code expectations
