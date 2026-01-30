---
name: emergency-rollback
description: Safely rollback failed builds or git commits
license: MIT
compatibility: opencode
---

# Emergency Rollback

I help you safely rollback failed NixOS builds or revert problematic git commits.

## What I do

1. **NixOS generation rollback**
   - List available previous generations
   - Execute `sudo nixos-rebuild switch --rollback`
   - Show what changed between generations
   - Verify rollback success

2. **Git commit reversion**
   - Show recent commit history
   - Generate safe `git revert` commands
   - Handle merge commits properly
   - Preserve history (no force operations)

3. **Boot menu selection guidance**
   - Explain how to select previous generation at boot
   - Show GRUB menu navigation
   - List generation timestamps and descriptions

4. **Safety checks**
   - Confirm you want to proceed before executing
   - Show what will change
   - Verify no uncommitted work will be lost
   - Backup current generation info

## When to use me

**NixOS rollback scenarios:**
- Build succeeded but system is broken
- New config causes boot issues
- Service failures after rebuild
- Need to quickly restore working state

**Git rollback scenarios:**
- Committed bad configuration
- Need to undo recent changes
- Want to revert without losing history

## What I won't do

- Destructive operations without confirmation
- Force pushes to remote (violates CLAUDE.md guidelines)
- Delete uncommitted work
- Hard resets (use git revert instead)

## Command reference

**List generations:**
```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

**Rollback to previous:**
```bash
sudo nixos-rebuild switch --rollback
```

**Rollback to specific generation:**
```bash
sudo nix-env --switch-generation <number> --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch
```

**Git revert:**
```bash
git revert <commit-hash>
```
