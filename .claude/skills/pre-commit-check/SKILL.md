---
name: pre-commit-check
description: Validate Nix modules and config before committing or rebuilding
disable-model-invocation: false
context: fork
allowed-tools: [Read, Glob, Grep, Bash, Skill, Task]
---

# Pre-Commit Validation

I validate your NixOS configuration and Nix modules before you commit or rebuild, catching issues early to save you from the frustrating cycle of rebuild → fail → fix → rebuild.

## What I do

1. **Style and syntax checks**
   - Invoke audit-agent for naming conventions and idiomatic Nix
   - Check for common anti-patterns
   - Verify module structure follows dendritic pattern

2. **Format validation**
   - Run `nixfmt` on changed Nix files
   - Report formatting issues without auto-fixing (you decide)

3. **Flake validation**
   - Run `nix flake check` to validate flake syntax
   - Check for missing inputs or circular dependencies
   - Verify flake.lock is in sync

4. **Configuration lint**
   - Use statix for Nix linting (if available)
   - Check for deprecated options
   - Identify unused variables

## When to use me

- Before running `/rebuild` to catch issues early
- After editing Nix modules or configuration files
- Before committing changes to git
- When you want quick validation without building

## What I won't do

- Automatically fix issues (I report only)
- Run the actual rebuild (use `/rebuild` for that)
- Modify your files (you maintain control)

## Token optimization

Running me first saves 4-6K tokens per rebuild cycle by:
- Catching errors before expensive rebuild attempts
- Running in isolated fork context
- Using targeted checks instead of full builds

## Example usage

Just say:
- "Check my changes before rebuilding"
- "Validate the new module I created"
- "Ready to commit, run pre-commit checks"
