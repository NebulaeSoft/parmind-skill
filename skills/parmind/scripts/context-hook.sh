#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Parmind UserPromptSubmit hook for Claude Code.
#
# Reads the prompt from stdin JSON, calls parmind-cli context, and emits
# hookSpecificOutput.additionalContext JSON on stdout.
#
# CONTRACT: never blocks the user's turn — every path exits 0.
# No `set -e` (a failing substitution must not kill the script) and no
# external `timeout` binary (absent on stock macOS; GNU timeout takes
# SECONDS, not ms). The outer time bound is the settings.json hook timeout;
# the inner bound is the CLI's own --deadline-ms.
# ---------------------------------------------------------------------------

INPUT=$(cat 2>/dev/null) || INPUT=''
[ -z "$INPUT" ] && exit 0

command -v node >/dev/null 2>&1 || exit 0

PROMPT=$(printf '%s' "$INPUT" | node -e "
  let d;
  try { d = JSON.parse(require('fs').readFileSync(0, 'utf8')); } catch { process.exit(0); }
  const p = d.prompt ?? d.user_prompt ?? '';
  if (typeof p === 'string') process.stdout.write(p.slice(0, 4000));
" 2>/dev/null) || PROMPT=''

[ -z "$PROMPT" ] && exit 0

DIR=$(cd "$(dirname "$0")" 2>/dev/null && pwd) || exit 0
CLI="$DIR/parmind-cli.mjs"
[ -f "$CLI" ] || exit 0

CONTEXT=$(node "$CLI" context --prompt "$PROMPT" --mode search --budget-tokens 1500 --deadline-ms 1150 2>/dev/null) || CONTEXT=''

if [ -n "$CONTEXT" ]; then
  printf '%s' "$CONTEXT" | node -e "
    const ctx = require('fs').readFileSync(0, 'utf8').trim();
    if (ctx) process.stdout.write(JSON.stringify({ hookSpecificOutput: { hookEventName: 'UserPromptSubmit', additionalContext: ctx } }));
  " 2>/dev/null || true
fi

exit 0
