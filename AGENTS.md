# Agent Guidelines for nixos-dotfiles

## Agent Autonomy

The agent is trusted to perform the following **without explicit confirmation**:

### File Operations
- Read any file in the repository
- Write/edit configuration files (`*.nix`, `*.md`, config files, etc.)
- Create new modules when needed for the requested feature

### Git Operations
- Stage changes related to user requests
- Commit changes after completing user-requested modifications
- Push to `main` branch after commits
- Use Conventional Commits format (load `commit-message` skill)

### Build Operations
- Run `nixos-rebuild build --flake .#one-piece` to validate changes
- Run `nixos-rebuild switch --flake .#one-piece` after successful build validation (when user requests a config change)
- Run `nix flake check` for comprehensive validation

### Restrictions (still require confirmation)
- Destructive git operations (`git reset --hard`, `git push --force`, `git rebase`)
- Deleting files or modules
- Changes to host hardware configs (`_hardware.nix`) or `stateVersion`
- Operations involving secrets or credentials

**Always explain what was done after completing actions.**

## Build/Deploy Commands

```bash
# Build (validate without applying)
sudo nixos-rebuild build --flake .#one-piece

# Apply configuration
sudo nixos-rebuild switch --flake .#one-piece

# Test (temporary, no bootloader update)
sudo nixos-rebuild test --flake .#one-piece

# Validate flake syntax
nix flake check

# Format Nix files
nixpkgs-fmt <file.nix>

# Update all flake inputs
nix flake update

# Update single input
nix flake update <input-name>
```

## Repository Structure (Dendritic Pattern)

Uses flake-parts + import-tree for automatic module discovery.

```
├── flake.nix                 # Minimal flake (imports modules/)
├── modules/
│   ├── flake/default.nix     # flake-parts configuration
│   ├── _lib/default.nix      # Helper functions (mkNixos)
│   ├── hosts/
│   │   ├── one-piece/        # Host-specific config
│   │   │   ├── default.nix   # Host composition (imports aspects)
│   │   │   ├── _hardware.nix # Hardware config (auto-generated)
│   │   │   ├── _gpu.nix      # NVIDIA settings
│   │   │   ├── _network.nix  # Hostname, WiFi backend
│   │   │   ├── _bluetooth.nix
│   │   │   └── _kanata.nix   # Keyboard remapping
│   │   └── _template/        # Template for new hosts
│   ├── users/rehan/          # User definition + packages
│   ├── system/               # base, boot, networking, virtualisation
│   ├── secrets/              # sops config + secrets.yaml
│   ├── services/             # audio, tailscale, pia
│   ├── desktop/              # hyprland, sddm, hyprlock, hypridle, hyprpaper, walker
│   ├── programs/
│   │   ├── cli/              # zsh, tmux, git, neovim, fzf, bat, etc.
│   │   ├── terminal/         # ghostty
│   │   ├── media/            # cava, zathura, kdenlive
│   │   ├── development/      # gpg, opencode
│   │   └── productivity/     # kdeconnect
│   ├── gaming/               # steam, gamemode, wine
│   └── theming/              # catppuccin
```

### Key Conventions
- Files prefixed with `_` are ignored by import-tree (helpers, plain NixOS modules)
- Each module defines `flake.modules.nixos.<name>` and/or `flake.modules.homeManager.<name>`
- Host `default.nix` composes aspects via `inputs.self.modules.nixos.<name>`

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

### Formatting Rules
- **Indentation**: 2 spaces, NO tabs
- **Line length**: < 100 characters
- **Semicolons**: Required after each attribute
- **Strings**: `"${var}"` for interpolation, `''heredoc''` for multi-line

### Naming Conventions
| Type | Convention | Example |
|------|------------|---------|
| Variables | camelCase | `enableBluetooth` |
| Files | kebab-case.nix | `oh-my-posh.nix` |
| Hostnames | kebab-case | `one-piece` |
| Flake inputs | kebab-case | `home-manager` |
| Aspect names | kebab-case | `system-packages` |

## Common Patterns

### Adding a New Aspect (Feature)
1. Create `modules/<category>/feature.nix`
2. Define `flake.modules.nixos.feature` and/or `flake.modules.homeManager.feature`
3. Add to host's `default.nix`: `inputs.self.modules.nixos.feature`
4. Run `sudo nixos-rebuild build --flake .#one-piece` to validate

### Adding a New Host
1. Copy `modules/hosts/_template/` to `modules/hosts/<hostname>/`
2. Update `_hardware.nix` with hardware-specific config
3. Customize `default.nix` to select desired aspects
4. Build with `nixos-rebuild build --flake .#<hostname>`

### Secrets (sops-nix)
- Secrets stored in `modules/secrets/secrets.yaml`
- Age key: `/home/rehan/.config/sops/age/keys.txt`
- Access: `config.sops.secrets.<name>.path`

## Important Notes

- **stateVersion**: NEVER change after initial install
- **Host hardware files**: Prefixed with `_` to exclude from import-tree
- **Host**: `one-piece` | **User**: `rehan`
- **Theme**: Catppuccin Mocha Blue (system-wide)
- **Rollback**: Select previous generation from GRUB if broken

## Testing Workflow

1. Edit module(s)
2. `nixpkgs-fmt <file.nix>` — format
3. `sudo nixos-rebuild build --flake .#one-piece` — validate
4. `sudo nixos-rebuild switch --flake .#one-piece` — apply
5. Verify functionality
