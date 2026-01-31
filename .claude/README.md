# Claude Code Configuration

This directory contains Claude Code compatible configuration, mirroring the opencode setup in `.opencode/`.

## Directory Structure

```
.claude/
├── settings.json              # Permissions, tool access, and hooks
├── README.md                  # This file
├── SKILLS_GUIDE.md            # Skill selection decision tree
├── AGENTS.md                  # Autonomous agents vs skills guide
├── HOOKS.md                   # Hooks documentation and examples
├── agents/                    # Autonomous agents (can research, iterate, decide)
│   ├── nixos-builder/         # Primary builder agent
│   ├── nixos-planner/         # Planning agent (isolated context)
│   ├── audit-agent/           # Code audit agent
│   ├── docs-assistant/        # Documentation agent
│   └── hyprland-config/       # Hyprland config agent
├── hooks/                     # Hook scripts
│   ├── protect-files.sh       # Protect sensitive files (PreToolUse)
│   └── auto-format-nix.sh     # Auto-format Nix files (PostToolUse)
├── skills/                    # Procedural skills (follow checklists)
│   ├── pre-commit-check/      # Pre-commit validation
│   ├── diagnose/              # System diagnostics
│   ├── emergency-rollback/    # Rollback failed builds
│   ├── commit-message/        # Commit message guidelines
│   ├── nixos-rebuild/         # NixOS rebuild commands
│   └── flake-update/          # Flake update guidance
└── commands/                  # Slash commands
    ├── rebuild.md             # /rebuild - Build and switch config
    ├── commit.md              # /commit - Generate commit message
    ├── update.md              # /update - Update flake inputs
    ├── plan-changes.md        # /plan-changes - Plan config changes
    ├── review-audit.md        # /review-audit - Audit configuration
    ├── pre-commit.md          # /pre-commit - Validate before build
    ├── diagnose.md            # /diagnose - System diagnostics
    └── rollback.md            # /rollback - Emergency rollback
```

## Compatibility with opencode

This setup maintains compatibility with opencode while providing Claude Code support:

### Configuration Mapping

| opencode | Claude Code | Purpose |
|----------|-------------|---------|
| `opencode.jsonc` | `.claude/settings.json` | Permissions |
| `.opencode/agents/` | `.claude/skills/` | Agent definitions (as skills) |
| `.opencode/skill/` | `.claude/skills/` | Utility skills |
| `.opencode/command/` | `.claude/commands/` | Slash commands |

### Key Differences

1. **Agents → Skills**: opencode's agents are converted to Claude Code skills
   - Primary agents become regular skills
   - Subagents become skills with `context: fork` for isolation

2. **Frontmatter**: Adapted to Claude Code format
   - `mode` → removed (behavior controlled by `context`)
   - `temperature` → removed (model-controlled)
   - `tools` → `allowed-tools` (array of tool names)
   - `compatibility` → removed
   - `license` → removed

3. **Permissions**: Converted from opencode's simplified format to Claude Code's pattern-based format

## Agents vs Skills

### Autonomous Agents (can research, iterate, make decisions)

Located in `.claude/agents/` - these can use webfetch, edit files, read code, and figure out solutions:

**Primary Execution:**
- **nixos-builder**: Build and apply NixOS changes (can research, edit multiple files, iterate on failures)
- **nixos-planner**: Plan complex changes (can explore options, analyze requirements, suggest alternatives)

**Specialized Analysis:**
- **audit-agent**: Audit config for best practices (can explore codebase, identify patterns)
- **docs-assistant**: Improve documentation (can understand context, suggest improvements)
- **hyprland-config**: Validate Hyprland config (can research best practices, suggest fixes)

### Procedural Skills (follow checklists, execute known steps)

Located in `.claude/skills/` - these run predefined procedures:

**Validation & Diagnostics:**
- **pre-commit-check**: Run validation checklist (audit → nixfmt → flake check → report)
- **diagnose**: Execute diagnostic commands (journalctl → systemctl → dmesg → analyze)
- **emergency-rollback**: Follow rollback procedure (list generations → show commands → execute)

**Reference & Guidance:**
- **commit-message**: Provide conventional commit templates
- **nixos-rebuild**: Explain rebuild commands and workflows
- **flake-update**: Give update guidance and compatibility notes

### How to Use

**Invoke an agent** (autonomous, can figure things out):
```bash
"Use nixos-builder to add GPU passthrough support"
"Ask nixos-planner to design a migration plan"
```

**Invoke a skill** (procedural, follows steps):
```bash
"Run pre-commit-check to validate my changes"
"Use diagnose to check network issues"
```

See `SKILLS_GUIDE.md` for detailed decision tree and `AGENTS.md` for agent vs skill criteria.

## Using Slash Commands

**Core Workflow:**
```bash
/pre-commit       # Validate before building (catches errors early) 🆕
/rebuild          # Rebuild and switch NixOS config
/commit           # Generate conventional commit message
```

**Planning & Quality:**
```bash
/plan-changes     # Plan configuration changes
/review-audit     # Audit configuration files
/update           # Update flake inputs
```

**Troubleshooting:**
```bash
/diagnose         # Run system diagnostics 🆕
/rollback         # Emergency rollback (manual safety net) 🆕
```

## Optimal Workflow

**For editing Nix modules** (most common task):
1. `/pre-commit` - Validate current state
2. Make your edits
3. `/pre-commit` - Catch syntax errors before building
4. `/rebuild` - Apply changes
5. `/review-audit` - Quality check (optional)
6. `/commit` - Generate commit message

**Token savings**: Using `/pre-commit` before `/rebuild` saves ~4-6K tokens per cycle by catching errors before expensive rebuild attempts.

See `SKILLS_GUIDE.md` for complete workflow documentation and token optimization strategies.

## Autonomous Agents for Complex Tasks

For multi-step, exploratory tasks that require iteration and research, use **autonomous agents** instead of skills:

**When to use agents**:
- 🤖 Research new features ("How do I add GPU passthrough?")
- 🤖 Explore codebase patterns ("Find all Hyprland keybindings")
- 🤖 Debug complex issues ("Why does X crash?")
- 🤖 Plan migrations ("Plan upgrade to NixOS 24.11")
- 🤖 Bulk refactoring ("Refactor all module imports")

**Built-in agents available**:
- `general-purpose` - Multi-step research and implementation
- `Explore` - Codebase exploration and pattern finding
- `Plan` - Planning complex changes

**How to invoke**:
```bash
# Natural language (Claude spawns agent automatically)
"Find all places where hyprland is configured"

# Explicit request
"Use the Explore agent to find all Hyprland keybindings"
```

See `AGENTS.md` for detailed agent vs skill decision criteria and examples.

## Hooks (Automated Workflow)

Hooks are **shell scripts that run automatically** at specific lifecycle points to enforce rules and automate tasks.

### Active Hooks

**1. Protect Sensitive Files** (PreToolUse on Edit/Write)
- **Script**: `.claude/hooks/protect-files.sh`
- **Purpose**: Block modifications to sensitive files per CLAUDE.md guidelines
- **Protected**: `_hardware.nix`, `secrets.yaml`, `stateVersion`, `.env` files
- **Behavior**: Exits with error if protected file detected

**2. Auto-Format Nix Files** (PostToolUse on Edit)
- **Script**: `.claude/hooks/auto-format-nix.sh`
- **Purpose**: Automatically run `nixfmt` after editing `.nix` files
- **Benefit**: Consistent formatting without manual intervention

### Benefits

- ✅ **Enforces CLAUDE.md rules** automatically
- ✅ **Saves tokens** - Formatting happens outside Claude's context
- ✅ **Safety net** - Catches mistakes before they cause issues
- ✅ **Consistent code style** - Auto-formatting on every edit

### Configuration

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit",
        "hooks": [{"type": "command", "command": ".claude/hooks/protect-files.sh"}]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [{"type": "command", "command": ".claude/hooks/auto-format-nix.sh"}]
      }
    ]
  }
}
```

See `HOOKS.md` for complete documentation, examples, and how to add custom hooks.

## Maintaining Both Configurations

When updating configuration:

1. **Update opencode first** (`.opencode/` directory)
2. **Sync to Claude Code** by copying and adapting format:
   - Agents: Convert to skills with appropriate `context` setting
   - Skills: Copy with updated frontmatter
   - Commands: Copy with minimal changes
   - Permissions: Update `settings.json`

## Notes

- Both `.opencode` and `.claude` can coexist
- Claude Code will use `.claude/` configuration
- opencode will use `.opencode/` and `opencode.jsonc`
- Keep both in sync for cross-tool compatibility
