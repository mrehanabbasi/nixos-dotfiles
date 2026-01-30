---
description: Safely rollback failed builds or commits
agent: nixos-planner
# model: default
---

**EMERGENCY USE ONLY**

Use the emergency-rollback skill to safely revert:
- Failed NixOS builds (rollback to previous generation)
- Problematic git commits (using git revert)
- Broken system configurations

This skill requires confirmation before executing any commands.

⚠️ This is a manual-invocation-only command for safety reasons.
