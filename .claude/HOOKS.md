# Claude Code Hooks

This document explains the hooks configured for this NixOS project and how to extend them.

## What Are Hooks?

Hooks are **shell scripts that run automatically** at specific points in Claude Code's execution lifecycle. They provide deterministic control and automation for your workflow.

## Active Hooks in This Project

### 1. Protect Sensitive Files (PreToolUse)

**Script**: `.claude/hooks/protect-files.sh`
**Event**: PreToolUse
**Tools**: Edit, Write
**Purpose**: Enforce CLAUDE.md guidelines by blocking modifications to sensitive files

**Protected patterns**:
- `_hardware.nix` - Hardware configuration requires confirmation
- `secrets.yaml` - Secrets managed by sops
- `stateVersion` - Should never change after initial install
- `.env` - Environment files with credentials
- `.age` / `keys.txt` - Encryption keys

**Behavior**: If a protected file is detected, the hook exits with code 2 (blocking error), preventing the operation and notifying Claude.

**Example output**:
```
🛡️  PROTECTED FILE: modules/hosts/one-piece/_hardware.nix
This file requires explicit user confirmation per CLAUDE.md guidelines.
Protected patterns: _hardware.nix, secrets.yaml, stateVersion, .env files
```

---

### 2. Auto-Format and Lint Nix Files (PostToolUse)

**Script**: `.claude/hooks/auto-format-nix.sh`
**Event**: PostToolUse
**Tools**: Edit
**Purpose**: Automatically lint and format `.nix` files after editing

**Behavior**:
- Runs `statix fix` to fix linter errors and anti-patterns
- Runs `nixfmt` to format code style
- Silently succeeds if tools not available
- Runs outside Claude's context (saves tokens)

**Example output**:
```
🔧 Linted: modules/system/base.nix
✨ Formatted: modules/system/base.nix
```

---

## Hook Configuration

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/protect-files.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/auto-format-nix.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Hook Events Available

Claude Code supports these hook events:

| Event | When It Runs | Can Block? |
|-------|-------------|-----------|
| **PreToolUse** | Before tool executes | ✅ Yes (exit 2) |
| **PostToolUse** | After tool succeeds | ✅ Yes (exit 2) |
| **PostToolUseFailure** | After tool fails | ❌ No |
| **UserPromptSubmit** | Before Claude sees input | ✅ Yes (exit 2) |
| **SessionStart** | At session initialization | ❌ No |
| **SessionEnd** | At session cleanup | ❌ No |
| **PermissionRequest** | On permission dialogs | ✅ Yes (allow/deny) |

---

## Writing Custom Hooks

### Hook Script Template

```bash
#!/bin/bash
# Hook: [Description]
# Event: [PreToolUse/PostToolUse/etc]
# Tools: [Bash/Edit/Write/etc]

set -e

# Read hook input JSON from stdin
HOOK_INPUT=$(cat)

# Extract relevant data
TOOL=$(echo "$HOOK_INPUT" | jq -r '.tool // empty')
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')
COMMAND=$(echo "$HOOK_INPUT" | jq -r '.tool_input.command // empty')

# Your logic here
if [[ condition ]]; then
  echo "Message to user" >&2
  exit 2  # Block operation
fi

# Allow operation
exit 0
```

### Hook Input JSON Structure

Hooks receive JSON via stdin:

```json
{
  "timestamp": "2026-01-30T17:00:00Z",
  "tool": "Edit",
  "tool_input": {
    "file_path": "/home/rehan/nixos-dotfiles/modules/system/base.nix",
    "old_string": "...",
    "new_string": "..."
  },
  "tool_output": {
    "file_path": "/home/rehan/nixos-dotfiles/modules/system/base.nix"
  },
  "session_id": "abc123",
  "event": "PreToolUse"
}
```

### Exit Codes

| Code | Meaning | Shown to Claude? |
|------|---------|-----------------|
| `0` | Success, allow operation | Verbose mode only |
| `2` | Blocking error, deny operation | ✅ Yes |
| Other | Non-blocking error | Verbose mode only |

---

## Example: Additional Hooks You Could Add

### 3. Validate NixOS Rebuild Commands

```bash
#!/bin/bash
# .claude/hooks/validate-nixos-rebuild.sh
set -e

HOOK_INPUT=$(cat)
COMMAND=$(echo "$HOOK_INPUT" | jq -r '.tool_input.command // empty')

# Ensure nixos-rebuild uses correct flake path
if [[ "$COMMAND" =~ nixos-rebuild ]] && [[ ! "$COMMAND" =~ --flake\ \.#one-piece ]]; then
  echo "❌ nixos-rebuild must use: --flake .#one-piece" >&2
  exit 2
fi

exit 0
```

**Add to settings.json**:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/validate-nixos-rebuild.sh"
          }
        ]
      }
    ]
  }
}
```

---

### 4. Log All Commands (Audit Trail)

```bash
#!/bin/bash
# .claude/hooks/log-commands.sh

HOOK_INPUT=$(cat)
TIMESTAMP=$(date -Iseconds)
COMMAND=$(echo "$HOOK_INPUT" | jq -r '.tool_input.command // "N/A"')
DESCRIPTION=$(echo "$HOOK_INPUT" | jq -r '.tool_input.description // "N/A"')

# Append to audit log
echo "$TIMESTAMP | $COMMAND | $DESCRIPTION" >> ~/.claude/audit.log

exit 0
```

---

## Hook Best Practices

### Security
- ✅ **Validate all inputs**: Check file paths, commands for malicious content
- ✅ **Use absolute paths**: Relative paths may not work (cwd resets)
- ✅ **Quote variables**: Use `"${var}"` not `$var` to prevent injection
- ✅ **Verify file access**: Check files exist and are within project
- ❌ **Never log secrets**: Avoid processing `.env`, secrets, or credentials

### Performance
- ✅ **Keep hooks fast**: Long-running hooks slow down the agent loop
- ✅ **Use appropriate exit codes**: 0 = allow, 2 = block
- ✅ **Fail gracefully**: Handle missing tools (e.g., `nixfmt` not installed)
- ✅ **Avoid side effects**: Don't modify files unexpectedly

### Integration
- ✅ **Complement skills**: Hooks enforce rules, skills perform actions
- ✅ **Document behavior**: Explain what each hook does
- ✅ **Test hooks**: Run manually with sample JSON input
- ✅ **Use project paths**: Reference `.claude/hooks/` not absolute paths

---

## Testing Hooks

### Manual Test

Simulate hook input to test your script:

```bash
echo '{
  "tool": "Edit",
  "tool_input": {
    "file_path": "modules/hosts/one-piece/_hardware.nix"
  }
}' | .claude/hooks/protect-files.sh
```

Expected output:
```
🛡️  PROTECTED FILE: modules/hosts/one-piece/_hardware.nix
This file requires explicit user confirmation per CLAUDE.md guidelines.
```

### Debug Mode

Run Claude Code with debugging to see hook execution:

```bash
claude --debug
```

This shows:
- Which hooks matched
- Hook execution results
- Exit codes and output

---

## Troubleshooting

### Hook Not Running

**Check**:
1. Hook script is executable: `chmod +x .claude/hooks/script.sh`
2. Path is correct in `settings.json`
3. Matcher pattern matches tool (e.g., `"Edit"` for Edit tool)
4. Hook script has no syntax errors: `bash -n .claude/hooks/script.sh`

### Hook Blocking Legitimate Operations

**Solutions**:
1. Adjust protected patterns in hook script
2. Add exceptions for specific cases
3. Use exit code 0 instead of 2 to allow operation

### Hook Script Errors

**Debug**:
```bash
# Test with sample input
echo '{"tool":"Edit","tool_input":{"file_path":"test.nix"}}' | \
  .claude/hooks/auto-format-nix.sh
```

Check for:
- Missing tools (`jq`, `nixfmt`)
- Permission errors
- Invalid JSON parsing

---

## Hook Lifecycle

```
User Request
    ↓
[PreToolUse Hook] ← protect-files.sh checks file
    ↓
Tool Executes (Edit/Write/Bash)
    ↓
[PostToolUse Hook] ← auto-format-nix.sh formats file
    ↓
Result Returned to Claude
```

---

## Environment Variables

Hooks have access to:
- `$CLAUDE_PROJECT_DIR` - Project root directory
- `$PWD` - Current working directory
- `$HOME` - User home directory
- Standard environment variables

---

## Disabling Hooks

### Temporarily Disable All Hooks

Add to `.claude/settings.local.json`:
```json
{
  "disableAllHooks": true
}
```

### Disable Specific Hook

Remove from `settings.json` or comment out in the hooks array.

---

## See Also

- `.claude/README.md` - Configuration overview
- `.claude/SKILLS_GUIDE.md` - Skill selection guide
- `.claude/SKILL_VS_AGENT.md` - Agent vs skill usage
- `CLAUDE.md` - Project guidelines (what hooks enforce)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide.md) - Official documentation
- [Hooks Reference](https://code.claude.com/docs/en/hooks.md) - Complete API reference
