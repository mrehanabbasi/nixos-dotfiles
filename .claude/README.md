# Claude Code Configuration

This directory contains Claude Code compatible configuration, mirroring the opencode setup in `.opencode/`.

## Directory Structure

```
.claude/
├── settings.json              # Permissions and tool access control
├── README.md                  # This file
├── SKILLS_GUIDE.md            # Skill selection decision tree
├── AGENTS.md                  # Autonomous agents vs skills guide
├── agents/                    # Legacy - not used by Claude Code
├── skills/                    # Skills (agents + utilities)
│   ├── nixos-builder/         # Primary builder skill
│   ├── nixos-planner/         # Planning skill (isolated context)
│   ├── docs-assistant/        # Documentation skill
│   ├── audit-agent/           # Code audit skill
│   ├── hyprland-config/       # Hyprland config skill
│   ├── pre-commit-check/      # Pre-commit validation (NEW)
│   ├── diagnose/              # System diagnostics (NEW)
│   ├── emergency-rollback/    # Rollback failed builds (NEW)
│   ├── commit-message/        # Commit message guidelines
│   ├── nixos-rebuild/         # NixOS rebuild commands
│   └── flake-update/          # Flake update guidance
└── commands/                  # Slash commands
    ├── rebuild.md             # /rebuild - Build and switch config
    ├── commit.md              # /commit - Generate commit message
    ├── update.md              # /update - Update flake inputs
    ├── plan-changes.md        # /plan-changes - Plan config changes
    ├── review-audit.md        # /review-audit - Audit configuration
    ├── pre-commit.md          # /pre-commit - Validate before build (NEW)
    ├── diagnose.md            # /diagnose - System diagnostics (NEW)
    └── rollback.md            # /rollback - Emergency rollback (NEW)
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

## Using Skills

### Invoke a skill:
```bash
# In Claude Code chat
"Use the nixos-builder skill to add a new package"
```

### Available skills:

**Execution & Building:**
- **nixos-builder**: Build and apply NixOS changes (main context)
- **nixos-rebuild**: Get rebuild commands and guidance (reference)

**Planning & Analysis:**
- **nixos-planner**: Plan changes without applying them (fork context)
- **audit-agent**: Audit config for best practices (fork context)
- **pre-commit-check**: Validate before commit/rebuild (fork context) 🆕

**Troubleshooting:**
- **diagnose**: System diagnostics for network/boot/hardware issues (fork context) 🆕
- **emergency-rollback**: Safely rollback failed builds (fork context, manual-only) 🆕

**Documentation & Config:**
- **docs-assistant**: Improve documentation (fork context)
- **hyprland-config**: Validate Hyprland config (fork context)

**Git & Dependencies:**
- **commit-message**: Generate conventional commits
- **flake-update**: Update flake dependencies safely

See `SKILLS_GUIDE.md` for detailed decision tree and workflow recommendations.

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
