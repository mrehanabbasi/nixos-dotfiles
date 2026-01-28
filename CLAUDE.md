# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS configuration repository using the **Dendritic pattern** with flake-parts and import-tree for declarative system configuration. The system is named "one-piece" and uses Hyprland as the window manager.

## Build/Deploy Commands

- Build config: `sudo nixos-rebuild build --flake .#one-piece`
- Apply config: `sudo nixos-rebuild switch --flake .#one-piece`
- Test config (temporary): `sudo nixos-rebuild test --flake .#one-piece`
- Check flake: `nix flake check`
- Update inputs: `nix flake update`
- Format Nix files: `nixpkgs-fmt <file.nix>`

## Architecture

### Dendritic Pattern with flake-parts

The repository uses **flake-parts** + **import-tree** for automatic module discovery. Each `.nix` file in `modules/` is a flake-parts module that defines aspects (features).

**Key concepts:**
- **Aspects**: Self-contained features defined as `flake.modules.nixos.<name>` or `flake.modules.homeManager.<name>`
- **Host composition**: Hosts select which aspects to include via their `default.nix`
- **Auto-import**: import-tree automatically imports all `.nix` files (except those prefixed with `_`)

### Directory Structure

```
├── flake.nix                 # Minimal flake entry point
├── modules/
│   ├── flake/default.nix     # flake-parts configuration
│   ├── _lib/default.nix      # Helper functions (mkNixos) - ignored by import-tree
│   ├── hosts/
│   │   ├── one-piece/        # Host-specific configuration
│   │   │   ├── default.nix   # Host composition (selects aspects)
│   │   │   ├── _hardware.nix # Hardware config (plain NixOS module)
│   │   │   ├── _gpu.nix      # NVIDIA Prime settings
│   │   │   ├── _network.nix  # Hostname, WiFi backend
│   │   │   ├── _bluetooth.nix
│   │   │   └── _kanata.nix   # Keyboard remapping
│   │   └── _template/        # Template for new hosts
│   ├── users/rehan/          # User definition + Home Manager
│   ├── system/               # base, boot, networking, virtualisation
│   ├── secrets/              # sops-nix config + secrets.yaml
│   ├── services/             # audio, tailscale, pia
│   ├── desktop/              # hyprland, sddm, hyprlock, hypridle, hyprpaper, walker
│   ├── programs/
│   │   ├── cli/              # zsh, tmux, git, neovim, fzf, bat, yazi, etc.
│   │   ├── terminal/         # ghostty
│   │   ├── media/            # cava, zathura, kdenlive
│   │   ├── development/      # gpg, opencode
│   │   └── productivity/     # kdeconnect
│   ├── gaming/               # steam, gamemode, wine
│   └── theming/              # catppuccin
```

### Key Architectural Patterns

1. **Flake-parts modules**: Each file defines `flake.modules.nixos.<aspect>` and/or `flake.modules.homeManager.<aspect>`

2. **Host composition**: Host's `default.nix` imports aspects:
   ```nix
   modules = [
     inputs.self.modules.nixos.base
     inputs.self.modules.nixos.hyprland
     # ... more aspects
   ];
   ```

3. **`_` prefix convention**: Files/dirs starting with `_` are ignored by import-tree:
   - `_lib/` - Helper functions
   - `_hardware.nix` - Plain NixOS modules (need `modulesPath`)
   - `_template/` - Not auto-imported

4. **Home Manager integration**: Integrated at NixOS level via the `rehan` user module

5. **Theming**: Catppuccin "mocha" flavor with "blue" accent, applied system-wide

6. **Secrets**: sops-nix with age encryption. Secrets in `modules/secrets/secrets.yaml`

## Code Style

### Dendritic Module Template
```nix
# Description comment
{ ... }:
{
  flake.modules.nixos.feature-name = { config, pkgs, lib, ... }: {
    # NixOS configuration
  };

  flake.modules.homeManager.feature-name = { config, pkgs, ... }: {
    # Home Manager configuration
  };
}
```

### Formatting
- **Language**: Nix expression language
- **Formatting**: 2-space indentation, no tabs. Run `nixpkgs-fmt` before committing
- **Naming**: camelCase for variables, kebab-case for files/hostnames/aspects
- **Comments**: Use `#` for comments. Document non-obvious choices
- **Secrets**: Use sops-nix, never commit plaintext

## Important Configuration Details

- **System state version**: 25.11 (Do NOT change)
- **Hostname**: one-piece
- **User**: rehan
- **Time zone**: Asia/Karachi
- **Locale**: en_US.UTF-8
- **Window Manager**: Hyprland (Wayland)
- **Terminal**: Ghostty
- **Shell**: Zsh with Oh My Posh
- **Editor**: Neovim
- **Display Manager**: SDDM with Catppuccin theme

## Adding New Features

1. Create `modules/<category>/feature.nix`
2. Define the aspect:
   ```nix
   { ... }:
   {
     flake.modules.nixos.feature = { pkgs, ... }: {
       # config here
     };
   }
   ```
3. Add to host's `default.nix`: `inputs.self.modules.nixos.feature`
4. Build and test: `sudo nixos-rebuild build --flake .#one-piece`
