---
name: emergency-rollback
description: Safely rollback failed builds or git commits
disable-model-invocation: true
context: fork
allowed-tools: [Read, Bash, Skill]
---

# Emergency Rollback

I help you safely rollback failed NixOS builds or revert problematic git commits. I require **explicit invocation** via `/rollback` to prevent accidental use.

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

## Important safety notes

⚠️ **Manual invocation required** - I will NOT auto-invoke
⚠️ **Confirmation required** - I ask before executing rollback commands
⚠️ **Read-only by default** - I plan the rollback first, then ask permission

## Token optimization

Running in fork context keeps rollback planning isolated from main conversation, saving tokens while allowing you to safely explore options.

## Example usage

You must explicitly invoke me:
- `/rollback` (via slash command)
- "Use emergency-rollback skill to undo the last build"
- "I need to rollback to the previous generation"

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
