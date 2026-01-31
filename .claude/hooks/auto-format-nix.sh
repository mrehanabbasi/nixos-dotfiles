#!/bin/bash
# Hook: Auto-format Nix files after edits
# Event: PostToolUse (Edit tool)
# Automatically runs nixfmt on modified .nix files

set -e

# Read hook input JSON from stdin
HOOK_INPUT=$(cat)

# Extract file path from tool output (after edit completes)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_output.file_path // .tool_input.file_path // empty')

# If no file path or not a .nix file, skip
if [[ -z "$FILE_PATH" ]] || [[ "$FILE_PATH" != *.nix ]]; then
  exit 0
fi

# Check if file exists and is readable
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Run nixfmt (suppress errors if nixfmt not available)
if command -v nixfmt &> /dev/null; then
  nixfmt "$FILE_PATH" 2>/dev/null || true
  echo "✨ Auto-formatted: $FILE_PATH" >&2
else
  echo "⚠️  nixfmt not available, skipping auto-format" >&2
fi

exit 0
