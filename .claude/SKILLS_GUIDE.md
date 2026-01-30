# Skills Selection Guide

This guide helps you choose the right skill or slash command for your task to optimize token usage and workflow efficiency.

## Decision Tree

```
┌─────────────────────────────────────────────┐
│         What do you want to do?             │
└─────────────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
        ▼            ▼            ▼
   BEFORE       DURING        AFTER
   changes      changes      changes
        │            │            │
        │            │            │
        ▼            ▼            ▼


┌─────────────── BEFORE MAKING CHANGES ───────────────┐
│                                                      │
│  Validate before editing:                           │
│  └─ /pre-commit         Run quality checks          │
│                         (~4-6K token savings)       │
│                                                      │
│  Plan a change:                                     │
│  └─ /plan-changes       Create implementation plan  │
│                         (nixos-planner skill)       │
│                                                      │
│  Understand existing code:                          │
│  └─ docs-assistant      Read and explain docs       │
│  └─ hyprland-config     Validate Hyprland config    │
│                                                      │
└──────────────────────────────────────────────────────┘


┌─────────────── DURING CHANGES ──────────────────────┐
│                                                      │
│  Make config changes:                               │
│  └─ nixos-builder       Edit modules and config     │
│                         (or use directly)           │
│                                                      │
│  Update dependencies:                               │
│  └─ /update             Update flake inputs safely  │
│                         (nixos-planner +            │
│                          flake-update)              │
│                                                      │
│  Get guidance:                                      │
│  └─ nixos-rebuild       Command reference           │
│  └─ flake-update        Dependency advice           │
│                                                      │
└──────────────────────────────────────────────────────┘


┌─────────────── AFTER CHANGES ───────────────────────┐
│                                                      │
│  Build and apply:                                   │
│  └─ /rebuild            Build and switch config     │
│                         (nixos-builder skill)       │
│                                                      │
│  Quality check:                                     │
│  └─ /review-audit       Audit for best practices   │
│                         (audit-agent skill)         │
│                                                      │
│  Commit changes:                                    │
│  └─ /commit             Generate conventional       │
│                         commit message              │
│                                                      │
└──────────────────────────────────────────────────────┘


┌─────────────── TROUBLESHOOTING ─────────────────────┐
│                                                      │
│  System not working:                                │
│  └─ /diagnose           Run diagnostics             │
│                         (~3-5K token savings)       │
│                                                      │
│  Build failed / broken:                             │
│  └─ /rollback           Revert to previous state   │
│                         (MANUAL ONLY - safety)      │
│                                                      │
│  Check logs:                                        │
│  └─ diagnose skill      journalctl, systemctl       │
│                                                      │
└──────────────────────────────────────────────────────┘
```

## Optimal Workflow for Common Tasks

### Editing Nix Modules (Your Most Common Task)

**Token-optimized flow:**

1. **Before editing**: `/pre-commit` - Validate current state
2. **Plan the change**: `/plan-changes` - Create implementation plan
3. **Make edits**: Edit files directly or use nixos-builder
4. **Pre-build validation**: `/pre-commit` - Catch syntax errors early
5. **Build**: `/rebuild` - Apply changes
6. **Post-build audit**: `/review-audit` - Check quality
7. **Commit**: `/commit` - Generate commit message

**Token savings**: ~8-12K per cycle (vs rebuild → fail → fix → rebuild)

---

### Code Review and Auditing

**Token-optimized flow:**

1. **Review code**: `/review-audit` - Run audit-agent in fork context
2. **Check formatting**: `/pre-commit` - Verify nixfmt compliance
3. **Fix issues**: Make edits based on findings
4. **Re-audit**: `/review-audit` - Verify fixes

**Token savings**: ~4-6K per review session (isolated context)

---

### Building/Rebuilding NixOS Config

**Token-optimized flow:**

1. **Pre-flight check**: `/pre-commit` - Validate before building
2. **Build**: `/rebuild` - Apply configuration
3. **If fails**: Fix errors, repeat from step 1
4. **If succeeds**: `/commit` - Commit changes

**Token savings**: ~4-6K when pre-commit catches issues early

---

### Troubleshooting System Issues

**Token-optimized flow:**

1. **Quick diagnostics**: `/diagnose` - Run in fork context
2. **Review findings**: Analyze logs and status
3. **If config issue**: `/rollback` - Revert to working state
4. **If service issue**: Restart/reconfigure specific service

**Token savings**: ~3-5K per session (verbose logs in fork context)

---

## Skill Reference Table

| Skill | Context | Auto-Invoke | When to Use | Token Impact |
|-------|---------|-------------|-------------|--------------|
| **pre-commit-check** | fork | Can auto-suggest | Before rebuild/commit | Saves 4-6K |
| **diagnose** | fork | Can auto-suggest | System issues | Saves 3-5K |
| **emergency-rollback** | fork | Manual only | Failed builds | Safety feature |
| **nixos-builder** | main | Manual | Apply changes | N/A (execution) |
| **nixos-planner** | fork | Manual | Plan changes | Saves 3-5K |
| **audit-agent** | fork | Manual | Quality checks | Saves 4-6K |
| **docs-assistant** | fork | Auto on docs | Documentation | Saves 3-5K |
| **hyprland-config** | fork | Auto on hyprland | Hyprland config | Saves 2-4K |
| **commit-message** | main | Can auto-suggest | Git commits | Saves ~2K |
| **nixos-rebuild** | main | Reference | Command help | Saves ~1K |
| **flake-update** | main | Reference | Dependency help | Saves 2-3K |

---

## Auto-Invocation Patterns (Hybrid Approach)

### Skills That Can Auto-Suggest

When you say certain phrases, these skills may auto-invoke:

**pre-commit-check** triggers on:
- "ready to commit"
- "validate my changes"
- "check before building"

**diagnose** triggers on:
- "network not working"
- "system issue"
- "check logs"
- "something's broken"

**docs-assistant** triggers on:
- "update documentation"
- "improve README"
- "explain this module"

**hyprland-config** triggers on:
- "hyprland keybinding"
- "window manager config"
- "validate hyprland"

### Skills That Require Explicit Invocation

**Manual-only (safety critical):**
- `emergency-rollback` - Must use `/rollback` command
- `nixos-builder` - Must use `/rebuild` command
- `nixos-planner` - Must use `/plan-changes` command
- `audit-agent` - Must use `/review-audit` command

---

## Token Optimization Tips

### Use Fork Context Skills for Analysis

Skills with `context: fork` run in isolated contexts:
- Don't pollute main conversation
- Can process large outputs without context bloat
- Perfect for diagnostics, planning, auditing

**Fork context skills:**
- pre-commit-check
- diagnose
- emergency-rollback
- nixos-planner
- audit-agent
- docs-assistant
- hyprland-config

### Catch Issues Early

Running `/pre-commit` before `/rebuild` saves massive tokens:
- Syntax errors caught before expensive rebuild
- Format issues fixed before build
- Flake validation prevents partial builds

**Typical savings**: 40% fewer tokens per edit-rebuild cycle

### Use Targeted Skills

Instead of asking general questions in main context:
- `/diagnose` for system issues
- `/review-audit` for code quality
- `/plan-changes` for implementation planning

Each delegation saves 3-6K tokens by using specialized skills.

---

## Quick Reference

**Starting a new feature:**
```bash
/plan-changes    # Plan implementation
# ... make edits ...
/pre-commit      # Validate before building
/rebuild         # Apply changes
/review-audit    # Quality check
/commit          # Generate commit message
```

**Quick fix workflow:**
```bash
# ... make edit ...
/pre-commit      # Validate
/rebuild         # Apply
/commit          # Commit
```

**Troubleshooting workflow:**
```bash
/diagnose        # Check system status
# ... analyze findings ...
/rollback        # If needed to revert
```

**Code review workflow:**
```bash
/review-audit    # Check quality
# ... fix issues ...
/pre-commit      # Validate fixes
```

---

## See Also

- `.claude/README.md` - Configuration overview
- `.claude/skills/*/SKILL.md` - Individual skill documentation
- `.claude/commands/*.md` - Slash command definitions
- `/help` - Claude Code built-in help
