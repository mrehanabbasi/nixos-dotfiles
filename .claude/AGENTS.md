# Autonomous Agents vs Skills

This document explains when to use **autonomous agents** (via Task tool) vs **skills** for NixOS development.

## Agent vs Skill Decision Criteria

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

## Current Skills That Can Spawn Agents

These skills use the **Task tool** internally for complex work:

### audit-agent
**Skill behavior**: Quick focused audits
**Agent delegation**: For large codebase analysis, spawns `Explore` agent to search and analyze across many files

### nixos-planner
**Skill behavior**: Plan simple changes
**Agent delegation**: For complex features, could spawn `general-purpose` agent to research implementation approaches

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
3. Invoke audit-agent skill
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
| Rebuild config | ✅ Skill (`nixos-builder`) | `/rebuild` |
| Quick diagnostics | ✅ Skill (`diagnose`) | `/diagnose` |
| Find pattern in codebase | 🤖 Agent (`Explore`) | "Find all Hyprland keybindings" |
| Research new feature | 🤖 Agent (`general-purpose`) | "How to add GPU passthrough?" |
| Plan complex migration | 🤖 Agent (`Plan`) | "Plan NixOS 24.11 upgrade" |
| Debug complex issue | 🤖 Agent (`general-purpose`) | "Why does Hyprland crash?" |
| Bulk refactoring | 🤖 Agent (`Explore` + `general-purpose`) | "Refactor all module imports" |

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

**Via skills** (skills can spawn agents internally):
```
/review-audit
→ audit-agent skill may spawn Explore agent for large codebases
```

---

## Recommendation for Your Workflow

**Current setup is optimal for token efficiency**:
- ✅ **Fork context skills handle 95% of tasks** (validate, build, diagnose, rollback, audit)
- ✅ **Fork skills are 3-5x cheaper** than agent spawning for predictable workflows
- ✅ **Only use agents for truly exploratory work** (research, unknown debugging)

**Token optimization strategy**:
1. **Default to fork skills** - Lower overhead, still isolated
2. **Use agents sparingly** - Only when you need multi-step exploration
3. **Agent overhead is ~500-1K tokens** - Reserve for complex unknowns

**When to actually use built-in agents**:
- ❌ **NOT for validation** - Use `/pre-commit` (fork skill)
- ❌ **NOT for diagnostics** - Use `/diagnose` (fork skill)
- ❌ **NOT for audits** - Use `/review-audit` (fork skill)
- ✅ **YES for research** - "How does GPU passthrough work?"
- ✅ **YES for exploration** - "Find all instances of X in unfamiliar codebase"
- ✅ **YES for complex debugging** - "Why does this crash only on specific hardware?"

**Your current 7 fork-context skills are the sweet spot** for token efficiency!

---

## See Also
- `SKILLS_GUIDE.md` - Skill selection and workflows
- `.claude/README.md` - Configuration overview
- Task tool documentation - Built-in agent types
