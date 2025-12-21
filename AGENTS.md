# Agent Guidelines for nixos-dotfiles

## Build/Deploy Commands
- Build config: `sudo nixos-rebuild build --flake .#one-piece`
- Apply config: `sudo nixos-rebuild switch --flake .#one-piece`
- Test config: `sudo nixos-rebuild test --flake .#one-piece`
- Check flake: `nix flake check`
- Update inputs: `nix flake update`
- Format Nix files: `nixpkgs-fmt <file.nix>`

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
