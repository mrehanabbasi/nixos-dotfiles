# Autonomous Agents vs Skills

This document explains the distinction between **autonomous agents** and **procedural skills** in this Claude Code configuration.

## Repository Context

This is a **NixOS dotfiles repository** using the **Dendritic pattern** with flake-parts and import-tree for automatic module discovery.

**Key directories:**
- `modules/` - NixOS and Home Manager configuration modules
- `.claude/agents/` - Autonomous agents for complex tasks
- `.claude/skills/` - Procedural skills for known workflows
- `.claude/commands/` - Slash commands for quick operations
- `.claude/hooks/` - Git hooks for validation and formatting

**Host**: `one-piece` | **User**: `rehan` | **System**: `x86_64-linux`

See `/home/rehan/nixos-dotfiles/CLAUDE.md` for complete repository guidelines.

---

## Two Types of Components

### Autonomous Agents (`.claude/agents/`)

**Can research, iterate, and make decisions autonomously.**

Located in `.claude/agents/`, these components can autonomously research, iterate, and make complex decisions:

- **nixos-builder** - Research solutions, edit multiple files, iterate on build failures
- **nixos-planner** - Explore options, analyze requirements, suggest alternatives
- **audit-agent** - Explore codebase, identify patterns, infer best practices
- **docs-assistant** - Understand context, research documentation standards
- **hyprland-config** - Research Hyprland best practices, suggest fixes

**Capabilities:**
- ✅ Use webfetch to research solutions
- ✅ Edit multiple files based on findings
- ✅ Read and understand code contextually
- ✅ Infer requirements and adapt
- ✅ Handle unknown scenarios
- ✅ Make complex multi-step decisions

### Procedural Skills (`.claude/skills/`)

**Follow known procedures and checklists.**

Located in `.claude/skills/`, these components execute predefined workflows:

- **pre-commit-check** - Runs checklist: audit → nixfmt → flake check → report
- **diagnose** - Executes: journalctl → systemctl → dmesg → analyze
- **emergency-rollback** - Follows: list generations → show commands → execute
- **commit-message** - Provides conventional commit templates
- **nixos-rebuild** - Explains rebuild commands and workflows
- **flake-update** - Gives update guidance and compatibility notes

**Characteristics:**
- Execute predefined steps in sequence
- Do not need to figure out solutions
- Follow fixed procedures
- More token-efficient for straightforward tasks

---

## When to Use Which

**Use an Agent when:**
- You don't know the solution path
- Need research and exploration
- Multiple approaches possible
- Example: "Add GPU passthrough support" (requires research, testing, iteration)

**Use a Skill when:**
- Solution is known and procedural
- Following a checklist
- Running diagnostic commands
- Example: "Run pre-commit validation" (known steps: audit, nixfmt, flake check)

---

## Built-in Claude Code Agents (via Task Tool)

This section explains when to use built-in Claude Code agents vs the project's autonomous agents/skills.

### Agent vs Skill Decision Criteria

### Use a Skill (with `context: fork`) When:
- ✅ Task is focused and predictable
- ✅ Execution is straightforward (run command, validate, return result)
- ✅ One-pass operation (no iteration needed)
- ✅ Lower token cost than agent spawning overhead
- **Examples**: Format check, run rebuild, system diagnostics, code audit
- **Token efficiency**: Fork skills are CHEAPER than agents for straightforward tasks

### Use an Agent (via Task tool) ONLY When:
- ✅ Task requires exploratory research (unknown solution path)
- ✅ Multiple rounds of iteration absolutely necessary
- ✅ Needs autonomous decision-making across many steps
- ✅ Fork skill complexity would exceed agent overhead
- ✅ Outcome completely uncertain until deep investigation
- **Examples**: Research unfamiliar feature, debug unknown issue, explore new codebase
- **Token cost**: Agent spawning adds ~500-1K overhead - only worth it for truly complex tasks

### Token Economics:

**Fork context skill**:
```
Overhead: ~50 tokens (fork creation)
Work: N tokens (in isolated context)
Return: ~100-200 tokens (summary to main)
Total impact on main: ~150-250 tokens
```

**Built-in agent**:
```
Overhead: ~500-1K tokens (agent spawning)
Work: N tokens (in agent context)
Return: ~200-500 tokens (summary to main)
Total impact on main: ~700-1.5K tokens
```

**Rule of thumb**: Only use agents when the task complexity justifies 3-5x higher overhead

---

## Project Agents That May Spawn Built-in Agents

These autonomous agents may use built-in Claude Code agents via the **Task tool** for complex work:

### audit-agent
**Primary capability**: Analyze codebase for style, patterns, and best practices
**May delegate to**: `Explore` agent for thorough codebase scanning across many files

### nixos-planner
**Primary capability**: Plan configuration changes and feature additions
**May delegate to**: `general-purpose` agent for researching implementation approaches

### nixos-builder
**Primary capability**: Execute NixOS rebuild with error handling and iteration
**May delegate to**: Research solutions for build failures, dependency issues

---

## Autonomous Agents for Complex Tasks

These tasks should be handled by **autonomous agents** directly, not skills:

### 1. Feature Research & Implementation
**Task**: "Research how to implement X feature in NixOS"
**Why agent**: Needs to explore docs, search similar implementations, test approaches
**How to invoke**:
```bash
"Use the general-purpose agent to research how to implement gaming optimizations in NixOS"
```
**Agent**: `general-purpose` (multi-step research and implementation)

---

### 2. Codebase Exploration
**Task**: "Find all instances of X pattern across the codebase"
**Why agent**: Needs systematic search across many files, analyze patterns, summarize findings
**How to invoke**:
```bash
"Use the Explore agent to find all hyprland keybindings and their purposes"
```
**Agent**: `Explore` (thorough=medium) - specialized for codebase exploration

---

### 3. Performance Analysis
**Task**: "Identify why rebuild is slow"
**Why agent**: Needs to profile, analyze logs, test hypotheses, iterate
**How to invoke**:
```bash
"Use the general-purpose agent to analyze rebuild performance and suggest optimizations"
```
**Agent**: `general-purpose` (exploratory analysis)

---

### 4. Migration Planning
**Task**: "Plan migration from NixOS 24.05 to 24.11"
**Why agent**: Needs to research breaking changes, analyze affected modules, plan migration steps
**How to invoke**:
```bash
"Use the Plan agent to create a migration plan from NixOS 24.05 to 24.11"
```
**Agent**: `Plan` (specialized for planning complex changes)

---

### 5. Dependency Analysis
**Task**: "Analyze impact of updating home-manager input"
**Why agent**: Needs to check changelogs, analyze breaking changes, test compatibility
**How to invoke**:
```bash
"Use the general-purpose agent to analyze the impact of updating home-manager to the latest commit"
```
**Agent**: `general-purpose` (research and analysis)

---

### 6. Debugging Complex Issues
**Task**: "Figure out why Hyprland crashes on specific monitor configuration"
**Why agent**: Needs to analyze logs, search issues, test hypotheses, iterate solutions
**How to invoke**:
```bash
"Use the general-purpose agent to debug why Hyprland crashes with dual monitor setup"
```
**Agent**: `general-purpose` (iterative debugging)

---

### 7. Bulk Refactoring
**Task**: "Refactor all modules to use new config structure"
**Why agent**: Needs to find all affected files, understand current pattern, plan changes, verify safety
**How to invoke**:
```bash
"Use the Explore agent to find all modules using old config pattern, then use general-purpose to plan refactoring"
```
**Agents**: `Explore` (find files) + `general-purpose` (plan refactoring)

---

## Built-in Agents Available

Claude Code provides these autonomous agents via the Task tool:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **general-purpose** | Multi-step tasks, research, implementation | Complex problems needing iteration |
| **Explore** | Codebase exploration, pattern finding | "Find all X", "Show me where Y is used" |
| **Plan** | Planning complex changes | "Plan how to implement Z" |
| **claude-code-guide** | Claude Code documentation lookup | Questions about Claude Code features |

---

## Workflow Examples

### Example 1: Adding a New Feature (Uses Agent)
```
You: "I want to add NVIDIA GPU passthrough for VMs"

# This should spawn a general-purpose agent:
Response: "This requires research into NVIDIA, VFIO, and libvirt configs.
Let me spawn an agent to research this..."

Agent workflow:
1. Search codebase for existing GPU/VM configs
2. Research NVIDIA passthrough requirements
3. Explore libvirt module structure
4. Plan implementation steps
5. Return comprehensive plan

Result: Detailed implementation plan with all modules to modify
```

### Example 2: Quick Validation (Uses Skill)
```
You: "/pre-commit"

# This uses pre-commit-check skill:
Skill workflow:
1. Run nixfmt on changed files
2. Run nix flake check
3. May invoke audit-agent if needed
4. Return validation results

Result: "All checks passed" or list of issues
```

### Example 3: Hybrid Approach
```
You: "Optimize my NixOS boot time"

# Starts with skill, delegates to agent if needed:
diagnose skill:
1. Quick check: systemd-analyze blame
2. If complex: "This needs deeper analysis..."
3. Spawn general-purpose agent to analyze systemd units, research optimizations

Result: Specific recommendations based on agent research
```

---

## Common NixOS Patterns

### Flatpak Management (nix-flatpak)

This repository uses **nix-flatpak** for declarative Flatpak management, enabling reproducible application installation.

**Adding new applications** (in `modules/services/flatpak.nix`):
```nix
services.flatpak.packages = [
  "com.example.App"        # App ID from Flathub
  "org.another.Application"
];
```

**Configuration**:
- Repository management: nix-flatpak automatically adds and manages Flathub
- Auto-updates: Enabled daily via `services.flatpak.update.auto`
- No manual systemd services needed for repository setup

**Finding app IDs**: Search on [Flathub](https://flathub.org) or use:
```bash
flatpak search <app-name>
flatpak list --app  # List installed apps
```

**Manual operations** (when needed):
```bash
flatpak update                    # Manually trigger updates
flatpak uninstall --unused        # Clean up unused dependencies
flatpak repair                    # Repair installation
```

**Module location**: `/home/rehan/nixos-dotfiles/modules/services/flatpak.nix`

---

## When NOT to Use Agents

**Avoid agents for**:
- ❌ Simple commands (`nixos-rebuild switch`)
- ❌ Single-file edits
- ❌ Straightforward validations
- ❌ Reference lookups (use skills with `nixos-rebuild`, `flake-update` instead)

**Why**: Agent overhead (spawning, context creation) wastes time for simple tasks

---

## Summary Table

| Task Type | Use | Example |
|-----------|-----|---------|
| Validate syntax | ✅ Skill (`pre-commit-check`) | `/pre-commit` |
| Rebuild config | 🤖 Agent (`nixos-builder`) | `/rebuild` |
| Quick diagnostics | ✅ Skill (`diagnose`) | `/diagnose` |
| Find pattern in codebase | 🤖 Agent (`Explore`) | "Find all Hyprland keybindings" |
| Research new feature | 🤖 Agent (`general-purpose`) | "How to add GPU passthrough?" |
| Plan complex migration | 🤖 Agent (`Plan`) or (`nixos-planner`) | "Plan NixOS 24.11 upgrade" |
| Debug complex issue | 🤖 Agent (`general-purpose`) | "Why does Hyprland crash?" |
| Bulk refactoring | 🤖 Agent (`Explore` + `general-purpose`) | "Refactor all module imports" |
| Audit codebase | 🤖 Agent (`audit-agent`) | `/review-audit` |

---

## How to Invoke Agents

**Via natural language** (Claude decides when to spawn):
```
"Find all places where hyprland is configured"
→ Claude spawns Explore agent automatically
```

**Explicit request**:
```
"Use the general-purpose agent to research NVIDIA GPU passthrough"
→ Explicitly spawns general-purpose agent
```

**Via slash commands** (which invoke agents):
```
/review-audit
→ Invokes audit-agent, which may spawn Explore agent for large codebases
```

---

## Recommendation for Your Workflow

**Current setup is optimal for token efficiency**:
- ✅ **Fork context agents and skills handle 95% of tasks** (validate, build, diagnose, rollback, audit)
- ✅ **Fork-context components are 3-5x cheaper** than built-in agent spawning
- ✅ **Only use built-in agents for truly exploratory work** (research, unknown debugging)

**Token optimization strategy**:
1. **Default to project agents/skills** - Run in fork context with lower overhead
2. **Use built-in agents sparingly** - Only when you need multi-step exploration
3. **Built-in agent overhead is ~500-1K tokens** - Reserve for complex unknowns

**When to actually use built-in agents**:
- ❌ **NOT for validation** - Use `/pre-commit` (invokes pre-commit-check skill)
- ❌ **NOT for diagnostics** - Use `/diagnose` (invokes diagnose skill)
- ❌ **NOT for audits** - Use `/review-audit` (invokes audit-agent)
- ❌ **NOT for rebuilds** - Use `/rebuild` (invokes nixos-builder agent)
- ✅ **YES for research** - "How does GPU passthrough work?"
- ✅ **YES for exploration** - "Find all instances of X in unfamiliar codebase"
- ✅ **YES for complex debugging** - "Why does this crash only on specific hardware?"

**Note**: Project agents and skills run in forked contexts for token efficiency!

---

## See Also
- `SKILLS_GUIDE.md` - Skill selection and workflows
- `.claude/README.md` - Configuration overview
- Task tool documentation - Built-in agent types
