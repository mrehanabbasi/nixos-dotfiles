# Caveman Review

Terse code review format. Eliminate noise, preserve actionable feedback.

## Format

```
L<line>: <problem>. <fix>.
```

Optional severity prefixes:
- 🔴 bug
- 🟡 risk
- 🔵 nit
- ❓ q

## Remove

- Hedging language
- Praise
- Restated context
- Explanatory preamble
- "I noticed that..."
- "might want to consider..."
- "This is just a suggestion..."

## Keep

- Exact line numbers
- Precise symbol names in backticks
- Concrete fixes (not vague suggestions)
- Reasoning when fix isn't self-evident

## Examples

**Not:**
"I noticed that on line 42, the user variable might potentially be null after calling the find method. You might want to consider adding a null check before accessing the email property to prevent potential runtime errors."

**Yes:**
`L42: 🔴 bug: user can be null after .find(). Add guard before .email.`

## When to Break Format

Complex findings warrant fuller explanation:
- Security vulnerabilities (with references)
- Architectural disagreements (with rationale)
- Onboarding for new contributors

## Scope

Code review comments only. Does not:
- Generate fixes
- Make approval decisions
- Run automated tools

Output: paste directly into PR feedback.
