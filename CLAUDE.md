# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS configuration repository using flakes for declarative system configuration. The system is named "one-piece" and uses Hyprland as the window manager with a modular configuration structure.

## Build/Deploy Commands

- Build config: `sudo nixos-rebuild build --flake .#one-piece`
- Apply config: `sudo nixos-rebuild switch --flake .#one-piece`
- Test config (temporary): `sudo nixos-rebuild test --flake .#one-piece`
- Check flake: `nix flake check`
- Update inputs: `nix flake update`
- Format Nix files: `nixpkgs-fmt <file.nix>`

## Architecture

### Configuration Structure

The repository follows a two-tier modular architecture:

**System-level configuration (root directory):**
- `configuration.nix` - Main entry point that imports all system modules
- `flake.nix` - Flake definition with inputs (nixpkgs, home-manager, hyprshutdown, catppuccin, sops-nix, opencode)
- `hardware-configuration.nix` - Hardware-specific settings
- `modules/` - System-wide configuration modules:
  - `boot.nix` - Boot loader and kernel settings
  - `networking.nix` - Network configuration
  - `hardware.nix` - Hardware settings (audio, graphics, etc.)
  - `desktop.nix` - Display manager (SDDM) and Hyprland system setup
  - `programs.nix` - System-wide programs
  - `services.nix` - System services
  - `users.nix` - User account definitions
  - `virtualisation.nix` - Docker, VMs, etc.
  - `gaming.nix` - Gaming-related packages and settings
  - `kanata.nix` - Keyboard remapping configuration

**User-level configuration (home/ directory):**
- `home/home.nix` - Home Manager entry point for user "rehan"
- `home/modules/` - User application configurations:
  - Shell: `zsh.nix`, `tmux.nix`, `oh-my-posh.nix`
  - Editor: `neovim.nix`
  - Terminal: `ghostty.nix`
  - File management: `yazi.nix`, `mime-apps.nix`
  - Window manager: `hyprland.nix`, `hyprlock.nix`, `hypridle.nix`, `hyprpaper.nix`, `rofi.nix`
  - Tools: `git.nix`, `gpg.nix`, `fzf.nix`, `zoxide.nix`, `bat.nix`, `fastfetch.nix`, `btop.nix`, `cava.nix`
  - Applications: `zathura.nix`, `kdeconnect.nix`, `opencode.nix`

### Key Architectural Patterns

1. **Flake Inputs Management**: The flake pins nixpkgs to 25.11 stable. Most inputs use `inputs.nixpkgs.follows = "nixpkgs"` for consistency, except hyprshutdown which uses its own unstable nixpkgs to avoid compatibility issues.

2. **Special Arguments**: System-level modules receive `{ hyprshutdown, opencode, system, ... }` via `specialArgs`. Home Manager modules receive `{ opencode, ... }` via `extraSpecialArgs`.

3. **Home Manager Integration**: Home Manager is integrated at the NixOS level (not standalone). User configuration is in `home-manager.users.rehan` block in flake.nix.

4. **Theming**: Catppuccin theme system is applied both at system level (SDDM) and user level (applications). Uses "mocha" flavor with "blue" accent. User home.nix sets `catppuccin.enable = false` at root to prevent automatic theming of all applications, enabling it selectively per-app instead.

5. **Secrets Management**: Uses sops-nix with age encryption. Key file location: `/home/rehan/.config/sops/age/keys.txt`. Secrets stored in `secrets/secrets.yaml`.

6. **Module Import Pattern**: Home Manager modules use explicit imports with argument passing:
   ```nix
   (import ./modules/tmux.nix { inherit pkgs; })
   ```

## Code Style

- **Language**: Nix expression language for declarative system configuration
- **Formatting**: Use 2-space indentation, no tabs. Run `nixpkgs-fmt` before committing
- **Imports**: Use `{ config, pkgs, ... }:` pattern. Import order: stdlib, custom modules, config
- **Naming**: Use camelCase for variables, kebab-case for hostnames/files (e.g., `one-piece`)
- **Structure**: Modular config split by concern (home/, configuration.nix, hardware-configuration.nix)
- **Comments**: Use `#` for comments. Document non-obvious configuration choices
- **Secrets**: Use sops-nix for secrets management. Never commit plaintext secrets
- **Home Manager**: User configs go in home/ directory, system configs in root
- **Flake inputs**: Pin to specific branches (e.g., nixos-25.11), use `follows` for consistency

## Important Configuration Details

- **System state version**: 25.11 (Do NOT change this value)
- **Hostname**: one-piece
- **User**: rehan
- **Time zone**: Asia/Karachi
- **Locale**: en_US.UTF-8
- **Window Manager**: Hyprland (Wayland)
- **Terminal**: Ghostty
- **Shell**: Zsh with Oh My Posh
- **Editor**: Neovim with LSPs (Go, TypeScript, Lua, YAML, JSON, Docker, Tailwind)
- **Display Manager**: SDDM with Catppuccin theme
- **Garbage Collection**: Automatic weekly, keeps last 7 days

## Hyprland Configuration

The Hyprland config in `home/modules/hyprland.nix` uses declarative Nix configuration (not hyprland.conf). Key details:

- Main modifier: SUPER key
- Terminal: Ghostty
- File manager: Yazi (terminal) or Dolphin (GUI with SUPER+SHIFT+E)
- Launcher: Rofi
- Browser: Brave with specific extension allowlisting
- Layout: Dwindle with vim-style navigation (H/J/K/L)
- Autostart: hyprpanel, hyprpaper, hypridle, kdeconnect
