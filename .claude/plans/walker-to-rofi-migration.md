# Walker to Rofi Migration Plan

## Overview

Replace Walker with Rofi as the primary application launcher in the NixOS configuration, maintaining the Super+Space keybinding and applying Catppuccin Mocha Blue theming via the catppuccin-nix flake.

## Current State Analysis

### Walker Configuration

- **Location**: `modules/desktop/walker/default.nix` (639 lines, 22KB)
- **Integration**: Home Manager module with systemd service
- **Keybinding**: `Super+Space` via `$menu = "walker"` in Hyprland
- **Theme**: Custom Catppuccin Mocha Blue (260 lines of manual CSS)
- **Features**: Application launcher, web search, calculator, file browser, clipboard, symbols
- **Dependencies**: Two flake inputs (`walker` and `elephant`)

### Integration Points

1. **User imports** (`modules/users/rehan/default.nix`):
   - Line 36: `inputs.walker.homeManagerModules.default`
   - Line 47: `inputs.self.modules.homeManager.walker`
2. **Hyprland** (`modules/desktop/hyprland/default.nix`):
   - Line 63: `"$menu" = "walker"`
3. **Flake inputs** (`flake.nix`):
   - Lines 40-48: `elephant` and `walker` definitions

## Migration Approach

### Design Decisions

**Focus**: Full-featured application launcher matching Walker's capabilities including calculator, clipboard history, web search, and emoji picker with plugins.

**Benefits**:

- Simpler configuration: ~120 lines vs 639 lines
- Automatic theming via catppuccin-nix (no manual CSS)
- Cleaner dependencies: Removes 2 flake inputs, adds 2 new packages (rofi-calc, cliphist)
- Better performance: On-demand launch (no background systemd service)
- Mature ecosystem: 10+ years development, extensive plugin library
- Native Wayland support
- Plugin architecture for extensibility
- Web search with multiple search engine options

**Risks**: Low - launcher is user-space only, not system-critical. Terminal (Super+Return) remains accessible for recovery.

## Implementation Steps

### Step 1: Create Rofi Module with Plugins

**File**: `modules/programs/productivity/rofi.nix` (new file)

**Content**:

```nix
# Rofi - Application launcher with plugins (calculator, clipboard, emoji, web search)
# Replaces: Walker
# Depends on: catppuccin (for theming)
{ pkgs, ... }:

{
  flake.modules.homeManager.rofi = { config, pkgs, ... }: {
    catppuccin.rofi.enable = true;

    # Clipboard manager backend
    services.cliphist.enable = true;

    home.packages = with pkgs; [
      rofi-calc
      rofi-emoji
    ];

    programs.rofi = {
      enable = true;
      terminal = "ghostty";
      location = "center";

      extraConfig = {
        modi = "drun,run,window,calc,emoji,cliphist:cliphist-rofi,websearch:rofi-websearch";
        show-icons = true;
        drun-display-format = "{name}";
        disable-history = false;
        hide-scrollbar = true;
        display-drun = " Apps";
        display-run = " Run";
        display-window = " Window";
        display-calc = " Calc";
        display-emoji = " Emoji";
        display-cliphist = " Clipboard";
        display-websearch = " Search";
        sidebar-mode = false;
        matching = "fuzzy";
      };

      plugins = with pkgs; [
        rofi-calc
        rofi-emoji
      ];
    };

    # Clipboard history helper script
    home.file.".local/bin/cliphist-rofi" = {
      text = ''
        #!/usr/bin/env bash
        cliphist list | rofi -dmenu | cliphist decode | wl-copy
      '';
      executable = true;
    };

    # Web search helper script
    home.file.".local/bin/rofi-websearch" = {
      text = ''
        #!/usr/bin/env bash
        # Rofi web search script
        # Usage: rofi -show websearch -modi websearch:rofi-websearch

        SEARCH_ENGINE="https://duckduckgo.com/?q="

        if [ -z "$@" ]; then
          echo -en "DuckDuckGo\0icon\x1fsearch\n"
          echo -en "Google\0icon\x1fsearch\n"
          echo -en "GitHub\0icon\x1fgithub\n"
          echo -en "YouTube\0icon\x1fyoutube\n"
        else
          query="$@"

          # Determine search engine based on input
          case "$query" in
            "DuckDuckGo")
              echo "Type your search query..."
              ;;
            "Google")
              SEARCH_ENGINE="https://www.google.com/search?q="
              echo "Type your search query..."
              ;;
            "GitHub")
              SEARCH_ENGINE="https://github.com/search?q="
              echo "Type your search query..."
              ;;
            "YouTube")
              SEARCH_ENGINE="https://www.youtube.com/results?search_query="
              echo "Type your search query..."
              ;;
            *)
              # Encode the query and open in browser
              encoded=$(echo "$query" | sed 's/ /+/g')
              xdg-open "${SEARCH_ENGINE}${encoded}" &
              ;;
          esac
        fi
      '';
      executable = true;
    };
  };
}
```

**Rationale**:

- `catppuccin.rofi.enable = true` automatically applies Mocha Blue theme
- `services.cliphist.enable = true` enables clipboard history backend (replaces walker's clipboard)
- `rofi-calc` plugin provides calculator functionality (replaces walker's calc)
- `rofi-emoji` plugin provides emoji picker (bonus feature)
- Custom `cliphist-rofi` script integrates cliphist with rofi
- Custom `rofi-websearch` script provides web search with multiple engines (replaces walker's web search)
- `modi` includes all modes: apps, run, window, calculator, emoji, clipboard, websearch
- `matching = "fuzzy"` for better search experience
- Icons enabled to match walker's visual style

**Plugin Usage**:

- Calculator: `Super+Space` → Tab to calc mode → type `5 + 3` → shows result
- Clipboard: `Super+Space` → Tab to clipboard mode → select from history
- Emoji: `Super+Space` → Tab to emoji mode → type emoji name → select
- Web Search: `Super+Space` → Tab to websearch mode → type query → opens in browser

### Step 2: Enable Catppuccin Theme for Rofi

**File**: `modules/theming/catppuccin.nix`

**Change**: Add inside the `catppuccin` attribute set (after line 29):

```nix
rofi.enable = true;
```

**Location**: Between `waybar.enable = true;` and the closing brace

**Rationale**: Follows existing pattern for enabling catppuccin themes (waybar, mpv, lazygit, etc.)

### Step 3: Update Hyprland Keybindings

**File**: `modules/desktop/hyprland/default.nix`

**Change 1**: Line 63, replace:

```nix
"$menu" = "walker";
```

With:

```nix
"$menu" = "rofi -show drun";
```

**Change 2**: Add new Rofi keybindings in the `bind` array (after existing bindings):

```nix
"$mainMod, Equal, exec, rofi -show calc -modi calc -no-show-match -no-sort"
"$mainMod SHIFT, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
"$mainMod, Period, exec, rofi -show emoji -modi emoji"
"$mainMod, slash, exec, rofi -show websearch -modi websearch:rofi-websearch"
```

**Rationale**:

- Preserves Super+Space for application launcher
- Super+Equal for quick calculator access (replaces walker's `=` prefix)
- Super+Shift+V for clipboard history (replaces walker's `:` prefix)
  - Note: Super+V is already used for floating window toggle, so using Shift modifier
- Super+Period for emoji picker (bonus feature)
- Super+Slash for web search (replaces walker's `+` prefix)
  - Note: "/" is intuitive for search operations
- Each mode accessible via dedicated keybinding for faster workflow

### Step 4: Update User Imports - Remove Walker

**File**: `modules/users/rehan/default.nix`

**Changes**:

1. **Line 36** - Remove:

   ```nix
   inputs.walker.homeManagerModules.default
   ```

2. **Line 47** - Remove:

   ```nix
   inputs.self.modules.homeManager.walker
   ```

3. **Line 47** (after removal) - Add:

   ```nix
   inputs.self.modules.homeManager.rofi
   ```

**Result**: Walker modules removed, Rofi module added in Desktop section

### Step 5: Remove Walker Flake Inputs

**File**: `flake.nix`

**Change**: Remove lines 40-48:

```nix
elephant = {
  url = "github:abenz1267/elephant";
  inputs.nixpkgs.follows = "nixpkgs";
};

walker = {
  url = "github:abenz1267/walker";
  inputs.elephant.follows = "elephant";
};
```

**Rationale**: Removes unused dependencies, reducing flake evaluation time and closure size

### Step 6: Delete Walker Module

**Command**: (to be executed during implementation)

```bash
rm modules/desktop/walker/default.nix
```

**Rationale**: Clean up unused configuration files

### Step 7: Update Flake Lock

**Command**: (to be executed during implementation)

```bash
nix flake update
```

**Rationale**: Remove walker/elephant from flake.lock after input removal

### Step 8: Format Modified Files

**Commands**: (to be executed during implementation)

```bash
nixfmt modules/programs/productivity/rofi.nix
nixfmt modules/theming/catppuccin.nix
nixfmt modules/desktop/hyprland/default.nix
nixfmt modules/users/rehan/default.nix
nixfmt flake.nix
```

**Rationale**: Maintain consistent code formatting per repository standards

### Step 9: Validation

**Commands**: (to be executed during implementation)

```bash
# 1. Validate flake syntax
nix flake check

# 2. Build configuration (does not apply)
sudo nixos-rebuild build --flake .#one-piece

# 3. If successful, apply configuration
sudo nixos-rebuild switch --flake .#one-piece
```

**Rationale**: Validate changes before applying to avoid breaking the system

## Testing Checklist

After `nixos-rebuild switch`, verify:

**Core Functionality**:

- [ ] Press `Super+Space` - Rofi launches centered on screen
- [ ] Catppuccin Mocha Blue theme visible (blue accents, dark background)
- [ ] Application icons display correctly
- [ ] Typing filters results in real-time
- [ ] Selecting app and pressing Enter launches it
- [ ] `Tab` key cycles between modes (Apps → Run → Window → Calc → Emoji → Clipboard)

**Calculator** (replaces walker's `=` prefix):

- [ ] Press `Super+Equal` or use `Super+Space` + `Tab` to calc mode
- [ ] Type `5 + 3` - shows result `8`
- [ ] Try complex: `sqrt(16) * 2` - shows result `8`

**Clipboard History** (replaces walker's `:` prefix):

- [ ] Copy some text to clipboard
- [ ] Press `Super+Shift+V` - shows clipboard history
- [ ] Select entry - gets copied to clipboard
- [ ] Paste with `Ctrl+V` - verifies clipboard integration

**Emoji Picker** (bonus feature):

- [ ] Press `Super+Period` - emoji picker launches
- [ ] Type `heart` - shows heart emojis
- [ ] Select emoji - gets copied to clipboard

**Web Search** (replaces walker's `+` prefix):

- [ ] Press `Super+/` - web search mode launches
- [ ] Type search query - opens in default browser
- [ ] Try different engines: DuckDuckGo (default), Google, GitHub, YouTube

**Cleanup Verification**:

- [ ] No walker processes: `ps aux | grep walker` returns nothing
- [ ] Flake inputs clean: `nix flake metadata | grep -E "walker|elephant"` returns nothing
- [ ] Cliphist service running: `systemctl --user status cliphist` shows active

## Critical Files

**Files to Create**:

1. `modules/programs/productivity/rofi.nix` - New Rofi module with plugins (~120 lines)
2. `~/.local/bin/cliphist-rofi` - Clipboard integration helper script (auto-created by Home Manager)
3. `~/.local/bin/rofi-websearch` - Web search helper script (auto-created by Home Manager)

**Files to Modify**:

1. `modules/users/rehan/default.nix` - Remove walker imports, add rofi (lines 36, 47)
2. `modules/theming/catppuccin.nix` - Enable rofi theme (line ~30)
3. `modules/desktop/hyprland/default.nix` - Update $menu variable (line 63), add Rofi keybindings
4. `flake.nix` - Remove walker/elephant inputs (lines 40-48)

**Files to Delete**:

1. `modules/desktop/walker/default.nix` - Old walker configuration

## Rollback Strategy

If issues occur:

1. **Immediate**: Reboot and select previous generation from GRUB
2. **Manual**: `sudo nixos-rebuild switch --rollback`
3. **Git**: `git revert <commit-hash>` and rebuild

## Post-Migration Notes

### Feature Mapping: Walker → Rofi

| Walker Feature | Walker Prefix | Rofi Equivalent | Rofi Keybinding |
|----------------|---------------|-----------------|-----------------|
| Application launcher | (default) | `rofi -show drun` | `Super+Space` |
| Calculator | `=` | `rofi -show calc` | `Super+Equal` |
| Clipboard history | `:` | cliphist + rofi | `Super+Shift+V` |
| Emoji picker | N/A | `rofi -show emoji` | `Super+Period` |
| Web search | `+` | rofi-websearch script | `Super+/` |
| File browser | `/` | Not included (use yazi: `Super+Return` + `yazi`) | N/A |
| Symbol lookup | `.` | Not included | N/A |

**Notes**:

- Clipboard uses `Super+Shift+V` instead of `Super+V` because `Super+V` is already mapped to floating window toggle in Hyprland
- Web search uses `Super+/` (slash) which is intuitive for search operations
- Web search supports multiple engines: DuckDuckGo (default), Google, GitHub, YouTube
- File browser and symbol lookup are omitted as they're better handled by dedicated tools (yazi, character map)

### Rofi Customization

Additional options available in `programs.rofi.extraConfig`:

- `kb-row-up/down`: Change navigation keybindings
- `matching`: fuzzy, regex, glob, normal
- `sort`: Enable sorting
- `case-sensitive`: false (default)
- `width/height`: Override default dimensions

## References

- Catppuccin Rofi: <https://github.com/catppuccin/rofi>
- Catppuccin Nix Options: <https://nix.catppuccin.com/options/main/home/catppuccin.rofi/>
- Home Manager Rofi: <https://github.com/nix-community/home-manager/blob/master/modules/programs/rofi.nix>
- Rofi Wayland: <https://github.com/lbonn/rofi>

## Summary

This migration simplifies the configuration from 639 lines to ~120 lines while maintaining core walker features (calculator, clipboard history, web search) via Rofi plugins and custom scripts. It removes 2 flake dependencies (walker, elephant) and provides a mature, well-supported application launcher with automatic Catppuccin theming. The Super+Space keybinding workflow remains identical, with additional dedicated keybindings for quick access to calculator (Super+Equal), clipboard (Super+Shift+V), emoji picker (Super+Period), and web search (Super+/).
