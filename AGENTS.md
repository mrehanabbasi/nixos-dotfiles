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
- Changes to `hardware-configuration.nix` or `stateVersion`
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

## Repository Structure

```
├── flake.nix                 # Flake inputs and system definition
├── configuration.nix         # Main config (imports modules/)
├── hardware-configuration.nix # Auto-generated (DO NOT EDIT)
├── sops.nix                  # Secrets management
├── modules/                  # System-level NixOS modules
│   ├── boot.nix, networking.nix, hardware.nix, desktop.nix
│   ├── programs.nix, services.nix, users.nix
│   ├── virtualisation.nix, gaming.nix, kanata.nix
└── home/                     # Home Manager (user-level)
    ├── home.nix              # Main home-manager config
    └── modules/              # User apps (hyprland, git, neovim, etc.)
```

## Code Style

### Module Template
```nix
# Description comment
{ config, pkgs, lib, ... }:

{
  programs.example = {
    enable = true;
    settings = {
      option1 = "value";
    };
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

### Import Patterns
```nix
# System modules
{ config, pkgs, lib, ... }:

# Home-manager modules  
{ config, pkgs, ... }:

# With custom flake inputs
{ config, pkgs, opencode, ... }:
```

### Package Management
```nix
# System packages (modules/programs.nix)
environment.systemPackages = with pkgs; [ package-name ];

# User packages (home/home.nix)
home.packages = with pkgs; [ package-name ];

# Prefer programs.* when available
programs.git.enable = true;  # Better than adding git to packages
```

### Comments
- Explain WHY, not WHAT
- Document hardware-specific workarounds
```nix
# Switched to wpa_supplicant for WiFi 7 MLO support with Qualcomm FastConnect 7800
wifi.backend = "wpa_supplicant";
```

## Common Patterns

### Adding a New Module
1. Create `modules/feature.nix` or `home/modules/app.nix`
2. Import in `configuration.nix` or `home/home.nix`
3. Run `sudo nixos-rebuild build --flake .#one-piece` to validate

### Flake Input Best Practices
```nix
# Pin to stable branches
nixpkgs.url = "nixpkgs/nixos-25.11";

# Use follows for consistency
inputs.nixpkgs.follows = "nixpkgs";

# Comment exceptions
# Let hyprshutdown use its own nixpkgs (unstable) to avoid compatibility issues
```

### Secrets (sops-nix)
- Encrypt with SOPS, never commit plaintext
- Age key: `/home/rehan/.config/sops/age/keys.txt`
- Access: `config.sops.secrets.<name>.path`

## Important Notes

- **stateVersion**: NEVER change after initial install
- **hardware-configuration.nix**: Auto-generated, do not edit manually
- **Host**: `one-piece` | **User**: `rehan`
- **Theme**: Catppuccin Mocha Blue (system-wide)
- **Rollback**: Select previous generation from GRUB if broken

## Testing Workflow

1. Edit module(s)
2. `nixpkgs-fmt <file.nix>` — format
3. `sudo nixos-rebuild build --flake .#one-piece` — validate
4. `sudo nixos-rebuild switch --flake .#one-piece` — apply
5. Verify functionality
