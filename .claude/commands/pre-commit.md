---
description: Validate Nix modules before committing or rebuilding
---

Run comprehensive pre-commit validation checks using the pre-commit-check skill.

This will:
1. Check code style and syntax with audit-agent
2. Validate formatting with nixfmt
3. Run `nix flake check` to verify flake structure
4. Lint with statix (if available)
5. Report all findings without modifying files

Use this before `/rebuild` to catch errors early and save rebuild cycles.
