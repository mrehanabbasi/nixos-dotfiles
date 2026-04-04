# NixOS Dotfiles

Personal NixOS configuration using the [Dendritic pattern](https://discourse.nixos.org/t/the-dendritic-pattern/61271) with flake-parts and automatic module discovery.

## Features

- **Dendritic pattern** - Feature-based organization with automatic module discovery
- **Hyprland** - Wayland compositor with Waybar, Hyprlock, and Hypridle
- **Catppuccin Mocha** - System-wide theming (GTK uses Tokyonight-Dark)
- **Home Manager** - Declarative user environment management
- **sops-nix** - Secrets management with age encryption
- **Gaming** - Steam, Gamemode, Wine, Lutris, Heroic, Bottles

## Prerequisites

- NixOS installed with flakes enabled
- Git

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/mrehanabbasi/nixos-dotfiles.git
   cd nixos-dotfiles
   ```

2. **Create your host configuration**
   ```bash
   cp -r modules/hosts/_template modules/hosts/your-hostname
   ```

3. **Generate hardware configuration**
   ```bash
   nixos-generate-config --show-hardware-config > modules/hosts/your-hostname/hardware.nix
   ```
   Then wrap the output in a flake-parts module (see `modules/hosts/one-piece/hardware.nix` for reference).

4. **Update user configuration**

   Edit `modules/users/rehan/default.nix` or create your own user module.

5. **Set up secrets (optional)**

   Create age key and configure sops:
   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   ```
   Update `modules/secrets/.sops.yaml` with your public key.

6. **Build and switch**
   ```bash
   sudo nixos-rebuild switch --flake .#your-hostname
   ```

## Structure

```
modules/
├── features/       # Self-contained feature modules (audio, hyprland, zsh, etc.)
├── hosts/          # Host-specific configurations
├── users/          # User configurations (Home Manager)
├── system/         # Core system modules (base, boot, networking, fonts)
├── theming/        # Catppuccin and GTK theming
├── secrets/        # sops-nix configuration
└── flake/          # flake-parts setup
```

## Commands

```bash
# Build without switching
sudo nixos-rebuild build --flake .#one-piece

# Build and switch
sudo nixos-rebuild switch --flake .#one-piece

# Update flake inputs
nix flake update

# Format nix files
nix fmt
```

## Documentation

See `CLAUDE.md` for detailed guidelines on adding modules, code style, and patterns.

## License

[MIT](LICENSE)
