#!/usr/bin/env bash

# Portable command guard for Codex and local tooling.
#
# Usage:
#   .codex/guardrails/bash-guard.sh 'git push origin feature/my-change'
#   printf '%s' '{"cmd":"git reset --hard"}' | .codex/guardrails/bash-guard.sh
#
# Exit codes:
#   0  command is not covered by this guard
#   10 explicit user confirmation is required
#   64 no command was supplied

set -u

if [ "$#" -gt 0 ]; then
  command_to_check="$*"
else
  input="$(sed -n '1p')"

  if [ -z "$input" ]; then
    printf '%s\n' 'Usage: bash-guard.sh <command> or provide a JSON command on stdin.' >&2
    exit 64
  fi

  if command -v jq >/dev/null 2>&1 && printf '%s' "$input" | jq -e . >/dev/null 2>&1; then
    command_to_check="$(printf '%s' "$input" | jq -r '.cmd // .command // .tool_input.command // empty')"
  else
    command_to_check="$input"
  fi
fi

if [ -z "$command_to_check" ]; then
  printf '%s\n' 'No command found in the supplied input.' >&2
  exit 64
fi

reasons=()

if printf '%s' "$command_to_check" | grep -qE '\brm[[:space:]]+(-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*|-[a-zA-Z]*f[a-zA-Z]*r[a-zA-Z]*)\b'; then
  reasons+=("destructive command (rm -rf)")
fi

if printf '%s' "$command_to_check" | grep -qE '\bgit[[:space:]]+push\b.*(--force\b|--force-with-lease\b|-f\b)'; then
  reasons+=("forced git push")
fi

if printf '%s' "$command_to_check" | grep -qE '\bgit[[:space:]]+reset[[:space:]]+--hard\b'; then
  reasons+=("git reset --hard")
fi

if printf '%s' "$command_to_check" | grep -qiE '\bdrop[[:space:]]+table\b'; then
  reasons+=("DROP TABLE")
fi

if printf '%s' "$command_to_check" | grep -qE '\bgit[[:space:]]+(commit|push)\b'; then
  current_branch="$(git branch --show-current 2>/dev/null || true)"
  if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
    reasons+=("direct action on protected branch '$current_branch'")
  fi
fi

if printf '%s' "$command_to_check" | grep -qE '\bgit[[:space:]]+push\b.*\b(origin[[:space:]]+)?(main|master)\b'; then
  reasons+=("explicit push to main/master")
fi

if [ "${#reasons[@]}" -gt 0 ]; then
  joined_reasons="$(IFS='; '; printf '%s' "${reasons[*]}")"
  printf 'REQUIRES_CONFIRMATION: %s\n' "$joined_reasons" >&2
  exit 10
fi

printf '%s\n' 'ALLOW'
exit 0
