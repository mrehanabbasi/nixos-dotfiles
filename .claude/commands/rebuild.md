---
description: Validate NixOS rebuild for the current host
---

Identify the target config and validation host, then run non-destructive validation only. Use `nix eval` first, followed by `nix build --dry-run` when appropriate.

Never run `nixos-rebuild switch`; the user performs the switch.

Use the nixos-builder skill to handle this task.
