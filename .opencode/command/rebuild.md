---
description: Validate NixOS rebuild for the current host
agent: nixos-builder
# model: default
---
Identify the target config and validation host, then run non-destructive validation only. Use `nix eval` first, followed by `nix build --dry-run` when appropriate.

Never run `nixos-rebuild switch`; the user performs the switch.
