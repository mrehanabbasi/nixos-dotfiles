# Agent Guidelines for nixos-dotfiles

## Overview
This is a NixOS system configuration using flakes, home-manager, and Hyprland for the host `one-piece`. The configuration is modular, with system-level configs in `modules/` and user-level configs in `home/modules/`.

## Build/Deploy Commands

### Main Operations
- **Build config**: `sudo nixos-rebuild build --flake .#one-piece`
- **Apply config**: `sudo nixos-rebuild switch --flake .#one-piece`
- **Test config (temporary)**: `sudo nixos-rebuild test --flake .#one-piece`
- **Dry run**: `sudo nixos-rebuild dry-activate --flake .#one-piece`

### Validation
- **Check flake**: `nix flake check`
- **Show flake outputs**: `nix flake show`
- **Show config**: `nixos-option <option.path>` (e.g., `nixos-option boot.loader`)
- **Validate specific module**: Build the system after changes to catch syntax errors

### Maintenance
- **Update flake inputs**: `nix flake update`
- **Update specific input**: `nix flake update <input-name>` (e.g., `nix flake update nixpkgs`)
- **Garbage collection**: `sudo nix-collect-garbage -d` (automatic weekly via `nix.gc`)
- **Format Nix files**: `nixpkgs-fmt <file.nix>` or `nixpkgs-fmt .` for all files

### Testing Single Changes
- After editing a module, run `sudo nixos-rebuild build --flake .#one-piece` to validate
- For home-manager only changes, can sometimes use `home-manager switch --flake .#one-piece`
- Use `nixos-rebuild test` for temporary activation without bootloader update

## Repository Structure

```
.
├── flake.nix                    # Flake definition with inputs and system config
├── configuration.nix            # Main system config (imports all modules)
├── hardware-configuration.nix   # Auto-generated hardware config
├── sops.nix                     # Secret management configuration
├── modules/                     # System-level NixOS modules
│   ├── boot.nix                 # Bootloader settings
│   ├── networking.nix           # Network configuration
│   ├── hardware.nix             # Hardware (Bluetooth, NVIDIA, graphics)
│   ├── desktop.nix              # Desktop environment settings
│   ├── programs.nix             # System programs and packages
│   ├── services.nix             # System services
│   ├── users.nix                # User account definitions
│   ├── virtualisation.nix       # Docker/Podman configuration
│   ├── gaming.nix               # Gaming-related packages
│   └── kanata.nix               # Keyboard remapping
├── home/                        # Home Manager user configuration
│   ├── home.nix                 # Main home-manager config
│   ├── modules/                 # User-level modules
│   │   ├── hyprland.nix         # Hyprland window manager config
│   │   ├── git.nix              # Git configuration
│   │   ├── neovim.nix           # Neovim setup
│   │   ├── zsh.nix              # Zsh shell config
│   │   ├── ghostty.nix          # Terminal emulator
│   │   ├── rofi.nix             # Application launcher
│   │   └── ...                  # Other user applications
│   ├── rofi/                    # Rofi theme files
│   ├── cava/                    # Audio visualizer config
│   └── misc/                    # Miscellaneous files (git hooks, etc.)
└── secrets/                     # SOPS encrypted secrets (not in version control)
```

## Code Style Guidelines

### Language & Syntax
- **Language**: Nix expression language (purely functional, lazy evaluation)
- **Formatting**: 2-space indentation, NO tabs
- **Line length**: Keep lines under 100 characters when practical
- **Semicolons**: Required after each attribute set entry
- **String interpolation**: Use `"${variable}"` or `''multi-line strings''` for heredocs

### Module Structure
```nix
# Module description comment
{ config, pkgs, lib, ... }:

{
  # Configuration goes here
  programs.example = {
    enable = true;
    package = pkgs.example;
    settings = {
      option1 = "value";
      option2 = 42;
    };
  };
}
```

### Import Patterns
1. **System modules**: `{ config, pkgs, lib, ... }:`
2. **Home-manager modules**: `{ config, pkgs, ... }:`
3. **With custom inputs**: `{ config, pkgs, opencode, ... }:`
4. **Import order**: Standard args first, custom args after, `...` last

### Naming Conventions
- **Variables**: `camelCase` (e.g., `enableBluetooth`, `myPackage`)
- **Hostnames**: `kebab-case` (e.g., `one-piece`)
- **Files**: `kebab-case.nix` (e.g., `oh-my-posh.nix`, `mime-apps.nix`)
- **Flake inputs**: `kebab-case` or `lowercase` (e.g., `home-manager`, `nixpkgs`)
- **Attributes in sets**: Match the option name (e.g., `enable`, `defaultBrowser`)

### Module Organization
- **System-level**: Put in `modules/` (affects entire system, requires sudo to apply)
- **User-level**: Put in `home/modules/` (user-specific, managed by home-manager)
- **One concern per module**: E.g., `networking.nix` only for network config
- **Module size**: Keep under 300 lines; split if larger

### Comments
- Use `#` for single-line comments
- Document non-obvious choices, hardware-specific settings, and workarounds
- Explain WHY, not WHAT (code shows what, comments explain reasoning)
```nix
# Switched to wpa_supplicant for WiFi 7 MLO support with Qualcomm FastConnect 7800
wifi.backend = "wpa_supplicant";
```

### Attribute Sets
- **Prefer explicit**: Use full paths like `programs.git.enable = true;`
- **Group related**: Keep related options together in the same set
- **Alphabetize**: Order attributes alphabetically within sections when practical
```nix
programs = {
  git.enable = true;
  neovim.enable = true;
  zsh.enable = true;
};
```

### Package Management
- **System packages**: `environment.systemPackages = with pkgs; [ ... ];`
- **User packages**: `home.packages = with pkgs; [ ... ];`
- **Prefer programs.***: Use `programs.git.enable = true;` over manual package install when available
- **Comments for unusual packages**: Document why a package is needed

### Secrets Management
- **Use sops-nix**: All secrets must be encrypted with SOPS
- **Never commit plaintext**: Secrets go in `secrets/secrets.yaml` (encrypted, not tracked)
- **Age key location**: `/home/rehan/.config/sops/age/keys.txt`
- **Access secrets**: Use `config.sops.secrets.<secret-name>.path`

### Home Manager Integration
- **User configs**: Go in `home/modules/`
- **Import in home.nix**: Add to imports list
- **Pass through specialArgs**: Custom inputs available via `extraSpecialArgs` in flake.nix
- **XDG compliance**: Use `xdg.configFile` for dotfile management

### Flake Best Practices
- **Pin versions**: Use specific branches (e.g., `nixos-25.11`, `release-25.11`)
- **Use follows**: Keep input versions consistent with `inputs.nixpkgs.follows = "nixpkgs";`
- **Document exceptions**: If not using `follows`, comment why (e.g., compatibility issues)
- **Minimal inputs**: Only add flake inputs when necessary

### Error Handling
- **Build errors**: Run `sudo nixos-rebuild build --flake .#one-piece` to catch before switch
- **Syntax errors**: Use `nix flake check` to validate
- **Rollback**: Boot to previous generation from GRUB if system is broken
- **Check evaluation**: Use `nix-instantiate --eval` to test expressions

### Type Safety
- Nix is dynamically typed but validate types through:
  - Options defined in NixOS/home-manager modules
  - Using `lib.types.*` for custom options
  - Testing configurations before applying

### Performance Considerations
- **Avoid IFD**: Don't use Import From Derivation unless necessary
- **Lazy evaluation**: Nix only evaluates what's needed
- **Share derivations**: Use `follows` to avoid duplicate inputs
- **Build caching**: Leverage binary cache (cache.nixos.org)

## Common Patterns

### Adding a System Package
```nix
# In modules/programs.nix
environment.systemPackages = with pkgs; [
  new-package  # Comment explaining purpose if not obvious
];
```

### Adding a User Package
```nix
# In home/home.nix
home.packages = with pkgs; [
  new-package
];
```

### Creating a New Module
```nix
# In modules/new-feature.nix or home/modules/new-app.nix
{ config, pkgs, ... }:

{
  # Configuration here
  programs.newapp = {
    enable = true;
    settings = {
      # Options
    };
  };
}
```
Then import in `configuration.nix` or `home/home.nix`.

### Hyprland Configuration
- Main config: `home/modules/hyprland.nix`
- Uses `wayland.windowManager.hyprland.settings` attribute set
- Keybinds in `bind`, `bindm`, `bindl`, `bindel` lists
- Window rules in `windowrule` list

### Git Hooks
- Defined in `home/modules/git.nix`
- Hook scripts in `home/misc/` directory
- Made executable via `pkgs.writeShellScript`

## Testing Workflow

1. **Before changes**: Ensure current config builds
2. **Make changes**: Edit relevant module(s)
3. **Format**: Run `nixpkgs-fmt <changed-file.nix>`
4. **Validate**: Run `sudo nixos-rebuild build --flake .#one-piece`
5. **Check**: Optional: `nix flake check` for comprehensive validation
6. **Test**: Run `sudo nixos-rebuild test --flake .#one-piece` for temporary activation
7. **Apply**: Run `sudo nixos-rebuild switch --flake .#one-piece` to make permanent
8. **Verify**: Check that services/programs work as expected
9. **Rollback if needed**: Boot to previous generation from GRUB

## Important Notes

- **stateVersion**: NEVER change `system.stateVersion` or `home.stateVersion` after initial install
- **Hardware config**: Don't manually edit `hardware-configuration.nix` (regenerate with `nixos-generate-config`)
- **Flake lock**: Commit `flake.lock` to track exact input versions
- **Root operations**: Most `nixos-rebuild` commands require `sudo`
- **Hostname**: System is named `one-piece`, referenced in flake as `.#one-piece`
- **User**: Primary user is `rehan`, configured in `modules/users.nix`
- **Theme**: Uses Catppuccin Mocha Blue theme system-wide
