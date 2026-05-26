# CLAUDE.md

## Pattern

- Always follow Dentritric pattern.
- Never use file paths but instead use module names for module references.

## Verify the target first

- Before making changes, identify the exact target config and the host required to validate it.
- Do not assume the edited path name matches the flake output or the machine that must run the verification command.
- State this explicitly before editing: `Target config: <name>. Validation host: <machine/host>. Planned verification: <command>.`

## Prefer upstream fixes

- If an issue appears to come from upstream, first check whether it is already fixed upstream.
- If the repo uses flakes, update the relevant flake input first. If the repo does not use flakes, update the channel first.
- If the fix is not in the pinned version, prefer an upstream PR commit or a commit already merged upstream before writing a local patch.
- If the repo has its own nixpkgs fork, ask whether the change should be made there and consumed by commit hash instead of patching locally.
- Only write a local patch when those options fail. Keep it minimal and put it in a separate file named `{package}-path-{fix-reason}.nix`.

## Always validate with eval

- After every Nix change, run a matching `nix eval` against the exact target output before claiming success.
- When practical, follow eval with the matching dry-run/build/test command. Eval is the minimum bar, not the whole test plan.
- `nix flake check` can also be used for validation.

## Avoid Destructive Changes

- `nix run` or `nixos-switch` are destructive and you should always confirm with user before running it.

**Note:** NEVER RUN `nixos-rebuild switch` COMMAND under any circumstances. It will be done by the user.

## Behavioral guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
