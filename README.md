# nixos-dotfiles

NixOS configuration using flake-parts and the dendritic pattern for modular, declarative system management.

## Quick Start

```bash
# Build and validate configuration
sudo nixos-rebuild build --flake .#one-piece

# Apply configuration
sudo nixos-rebuild switch --flake .#one-piece

# Update flake inputs
nix flake update
```

## Features

- **Modular Architecture**: Dendritic pattern with automatic module discovery via import-tree
- **Declarative Everything**: System, user, and application configuration in Nix
- **Hyprland Desktop**: Wayland compositor with full theming integration
- **Catppuccin Mocha Theme**: System-wide consistent theming
- **Secrets Management**: sops-nix for encrypted secrets
- **Flatpak Integration**: Declarative Flatpak application management with auto-updates

## Key Components

### System
- **Host**: `one-piece` (x86_64-linux)
- **User**: `rehan` with Home Manager integration
- **Desktop**: Hyprland, SDDM, walker launcher
- **Services**: Audio (Pipewire), Tailscale, PIA VPN, Flatpak

### Application Management

**NixOS Packages**: Traditional package installation via `environment.systemPackages`

**Flatpak**: Declarative management via nix-flatpak
- Apps defined in `modules/services/flatpak.nix`
- Automatic daily updates enabled
- Flathub repository automatically managed

Example:
```nix
services.flatpak.packages = [
  "de.z_ray.Facetracker"
];
```

## Documentation

- **CLAUDE.md**: Comprehensive agent guidelines, code style, and patterns
- **modules/**: Self-documenting module structure

## Repository Structure

```
modules/
├── flake/          # flake-parts configuration
├── hosts/          # Host-specific configs (one-piece)
├── users/          # User configurations (rehan)
├── system/         # Base system, boot, networking
├── services/       # System services (audio, flatpak, VPN)
├── desktop/        # Hyprland and desktop environment
├── programs/       # Applications (CLI, terminal, media, dev tools)
├── gaming/         # Steam, gamemode, wine
├── theming/        # Catppuccin theme configuration
└── secrets/        # sops-nix encrypted secrets
```

## Contributing

See **CLAUDE.md** for detailed guidelines on:
- Adding new modules
- Code style and formatting
- Common patterns and anti-patterns
- Build and validation workflow
