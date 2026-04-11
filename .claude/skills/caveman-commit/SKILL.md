# Caveman Commit

Ultra-compressed commit message generator. Terse, signal-rich, Conventional Commits format.

## Activation

Invoke on commit-related commands or staging changes.

## Subject Line

Format: `<type>(<scope>): <imperative summary>`

**Constraints:**
- Max 50 chars (hard limit: 72)
- Imperative mood ("add", "fix" not "added", "adds")

**Allowed types:**
`feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`

## Body

Include **only** when:
- Non-obvious why
- Breaking changes
- Migration notes
- Linked issues

Otherwise omit entirely. Wrap at 72 chars.

## Prohibited

- "This commit does X"
- First-person pronouns
- AI attribution statements
- Emoji (unless project convention)
- Filename restatement when scope covers it

## Scope

**Only generates** the message. Does not:
- Execute git commands
- Stage files
- Amend commits

Output: code block ready for manual use.

## Example

```
fix(auth): handle null user in middleware

Guard against .find() returning null before accessing .email property.

Closes #123
```
