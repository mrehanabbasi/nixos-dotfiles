#!/bin/bash
# Hook: Protect sensitive files from modifications
# Event: PreToolUse (Edit/Write tools)
# Per CLAUDE.md guidelines: Require confirmation for sensitive files

set -e

# Read hook input JSON from stdin
HOOK_INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

# If no file path, allow operation (not a file operation)
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# List of protected file patterns (per CLAUDE.md)
PROTECTED_PATTERNS=(
  "_hardware.nix"
  "secrets.yaml"
  "stateVersion"
  ".env"
  ".age"
  "keys.txt"
)

# Check if file matches any protected pattern
for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "🛡️  PROTECTED FILE: $FILE_PATH" >&2
    echo "This file requires explicit user confirmation per CLAUDE.md guidelines." >&2
    echo "Protected patterns: _hardware.nix, secrets.yaml, stateVersion, .env files" >&2
    exit 2  # Exit code 2 = blocking error (shown to Claude)
  fi
done

# Allow operation
exit 0
