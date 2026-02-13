# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Agent Guidelines for nixos-dotfiles

## Agent Autonomy

Perform **without confirmation**:

- Read/write/edit config files (`*.nix`, `*.md`, etc.)
- Create new modules for requested features
- Run `nix flake check` for validation

**Require confirmation**:

- Commit (Conventional Commits), and push to `main`
- Destructive git ops (`reset --hard`, `push --force`, `rebase`)
- Deleting files/modules
- Changes to `_hardware.nix` or `stateVersion`
- Operations involving secrets

**Never do this**:

- Run `nixos-rebuild build/switch --flake .#one-piece` with or without `sudo`

**Agent workflow**:

- Use `.claude/plans/` for plan files, name them descriptively (not random names)

## Build/Lint Commands

```bash
sudo nixos-rebuild build --flake .#one-piece   # Validate (primary)
sudo nixos-rebuild switch --flake .#one-piece  # Apply (Never run this yourself)
sudo nixos-rebuild test --flake .#one-piece    # Temporary (no bootloader)
nix flake check                                 # Validate flake syntax
nixfmt <file.nix>                              # Format single file
nixfmt modules/programs/cli/                   # Format directory
nix flake update                                # Update all inputs
nix flake update <input-name>                  # Update single input
```

## Architecture

### Dendritic Pattern Overview

Uses **flake-parts + import-tree** for automatic module discovery. The `flake.nix` is minimal—it just imports `./modules` which auto-discovers all `.nix` files (except `_` prefixed ones).

**Key conventions**:

- `_` prefix = ignored by import-tree (helpers, plain NixOS modules, hardware configs)
- Modules export via `flake.modules.nixos.<name>` and/or `flake.modules.homeManager.<name>`
- Hosts compose modules via `inputs.self.modules.nixos.<name>`
- Users compose Home Manager modules via `inputs.self.modules.homeManager.<name>`
- Hardware config stays in host's `_*.nix` files, never in shared modules

### Module Composition Flow

```
flake.nix
    └── modules/ (auto-imported by import-tree)
            ├── hosts/one-piece/default.nix  ──┐
            │   Composes NixOS modules:        │
            │   └── inputs.self.modules.nixos.* ◄── Defined in modules/**/*.nix
            │                                   │
            └── users/rehan/default.nix ───────┤
                Composes HM modules:            │
                └── inputs.self.modules.homeManager.* ◄─┘
```

### Host Layer Ordering

Hosts (`modules/hosts/*/default.nix`) compose modules in **strict layer order**:

1. **External flake modules** - Third-party options (catppuccin, sops-nix, home-manager)
2. **Base system** - Core NixOS (base, boot, networking, virtualisation, fonts)
3. **Secrets** - sops config (before services that use them)
4. **Theming** - catppuccin (before modules that read theme options)
5. **Services** - audio, tailscale, pia, flatpak
6. **Desktop & Programs** - hyprland, sddm, browsers, CLI tools
7. **Optional features** - gaming
8. **Host-specific hardware** - Plain NixOS modules (`_hardware.nix`, `_gpu.nix`, etc.)
9. **User** - Composes Home Manager modules

### Dual-Module Pattern

Most modules define **both** NixOS and Home Manager aspects in one file:

```nix
# modules/desktop/hyprland/default.nix
{ inputs, ... }:
{
  flake.modules.nixos.hyprland = { pkgs, ... }: {
    # System-level: enable service, install packages
    programs.hyprland.enable = true;
  };

  flake.modules.homeManager.hyprland = _: {
    # User-level: configure dotfiles, settings
    wayland.windowManager.hyprland.settings = { ... };
  };
}
```

### Directory Structure

```
modules/
├── flake/          # flake-parts config
├── _lib/           # Helper functions (mkNixos) - NOT auto-imported
├── hosts/          # Host compositions (one-piece)
├── users/          # User compositions (rehan)
├── system/         # base, boot, networking, virtualisation, fonts
├── secrets/        # sops config + secrets.yaml
├── services/       # audio, tailscale, pia, flatpak
├── desktop/        # hyprland, sddm, hyprlock, hypridle, waybar, swaync
├── programs/       # cli/, terminal/, media/, development/, productivity/
├── gaming/         # steam, gamemode, wine
└── theming/        # catppuccin, gtk
```

## Code Style

### Module Template

```nix
# Description of module
# Depends on: other-module (if applicable)
{ inputs, ... }:  # Use { ... }: if inputs not needed
{
  flake.modules.nixos.feature-name = { config, pkgs, lib, ... }: {
    # NixOS configuration
  };

  flake.modules.homeManager.feature-name = { config, pkgs, ... }: {
    # Home Manager configuration
  };
}
```

### Module Arguments

| Argument | When to Use |
|----------|-------------|
| `{ ... }:` | No external args needed |
| `{ inputs, ... }:` | Needs flake inputs (external packages, modules) |
| `{ config, ... }:` | Reads other config (e.g., `config.sops.secrets`) |
| `{ pkgs, ... }:` | Needs packages |
| `{ lib, ... }:` | Uses lib functions (`mkIf`, `mkOption`) |

### Formatting

- **Indentation**: 2 spaces, NO tabs
- **Line length**: < 100 chars
- **Semicolons**: Required after each attribute
- **Strings**: `"${var}"` for interpolation, `''heredoc''` for multi-line
- **Lists**: One item per line for 3+ items

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Variables | camelCase | `enableBluetooth` |
| Files | kebab-case.nix | `oh-my-posh.nix` |
| Hostnames/Inputs | kebab-case | `one-piece`, `home-manager` |

### Conditional Configuration

```nix
services.foo = lib.mkIf config.programs.bar.enable { ... };

environment.systemPackages = with pkgs; [ required ]
  ++ lib.optionals config.hardware.nvidia.enable [ nvidia-tools ];

option = lib.mkDefault "value";  # Can be overridden
option = lib.mkForce "value";    # Cannot be overridden
```

### Error Handling

```nix
assertions = [{
  assertion = config.services.foo.enable -> config.services.bar.enable;
  message = "foo requires bar to be enabled";
}];

warnings = lib.optional (config.old-option != null)
  "old-option is deprecated, use new-option instead";
```

## Common Patterns

### Adding a New Aspect

1. Create `modules/<category>/feature.nix`
2. Define `flake.modules.nixos.feature` and/or `flake.modules.homeManager.feature`
3. Add NixOS module to host's `default.nix`: `inputs.self.modules.nixos.feature`
4. Add Home Manager module to user's `default.nix`: `inputs.self.modules.homeManager.feature`
5. Validate: `sudo nixos-rebuild build --flake .#one-piece`

### Secrets (sops-nix)

```nix
{ config, ... }: {
  services.foo.credentialsFile = config.sops.secrets.foo.path;
}
```

Secrets: `modules/secrets/secrets.yaml` | Key: `/home/rehan/.config/sops/age/keys.txt`

### Flatpak (nix-flatpak)

Declarative Flatpak management using nix-flatpak for reproducible application installation.

**Adding new applications**:

```nix
services.flatpak.packages = [
  "com.example.App"        # App ID from Flathub
  "org.another.Application"
];
```

**Configuration** (`modules/services/flatpak.nix`):

- Repository management: nix-flatpak automatically adds and manages Flathub
- Auto-updates: Enabled daily via `services.flatpak.update.auto`
- No manual systemd services needed for repository setup

**Finding app IDs**: Search on [Flathub](https://flathub.org) or use:

```bash
flatpak search <app-name>
flatpak list --app  # List installed apps
```

**Manual operations** (when needed):

```bash
flatpak update                    # Manually trigger updates
flatpak uninstall --unused        # Clean up unused dependencies
flatpak repair                    # Repair installation
```

## Nix Anti-patterns

- **NEVER** change `stateVersion` after initial install
- **NEVER** hardcode paths—use `config.xdg.*` or `pkgs.writeText`
- **AVOID** `with pkgs;` in large scopes—prefer explicit `pkgs.foo`
- **AVOID** `rec { }` attribute sets—use `let ... in` instead

## Context

- **Host**: `one-piece` | **User**: `rehan` | **System**: `x86_64-linux`
- **Theme**: Catppuccin Mocha Blue (system-wide)
- **Rollback**: Select previous generation from GRUB if config breaks
