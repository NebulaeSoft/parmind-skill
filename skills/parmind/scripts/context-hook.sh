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
#
# PARMIND_VERBOSE=1 adds a `systemMessage` (shown to the user by Claude Code)
# reporting what happened. Off by default: exiting 0 with no output makes every
# failure — timeout, nothing relevant, not linked — look identical, which is
# invisible in normal use but the first thing you want when debugging.
# The extra timing costs two node spawns, so it is only paid when enabled.
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

DEADLINE=1150
VERBOSE="$PARMIND_VERBOSE"

START=''
if [ -n "$VERBOSE" ]; then
  START=$(node -e "process.stdout.write(String(Date.now()))" 2>/dev/null) || START=''
fi

CONTEXT=$(node "$CLI" context --prompt "$PROMPT" --mode search --budget-tokens 1500 --deadline-ms "$DEADLINE" 2>/dev/null) || CONTEXT=''

# Quiet path (default): emit context when there is some, otherwise nothing.
if [ -z "$VERBOSE" ]; then
  if [ -n "$CONTEXT" ]; then
    printf '%s' "$CONTEXT" | node -e "
      const ctx = require('fs').readFileSync(0, 'utf8').trim();
      if (ctx) process.stdout.write(JSON.stringify({ hookSpecificOutput: { hookEventName: 'UserPromptSubmit', additionalContext: ctx } }));
    " 2>/dev/null || true
  fi
  exit 0
fi

# Verbose path: always report, whether or not anything was injected.
ELAPSED='?'
if [ -n "$START" ]; then
  ELAPSED=$(node -e "process.stdout.write(String(Date.now() - Number(process.argv[1] || 0)))" "$START" 2>/dev/null) || ELAPSED='?'
fi

printf '%s' "$CONTEXT" | PARMIND_ELAPSED="$ELAPSED" PARMIND_DEADLINE="$DEADLINE" node -e "
  const ctx = require('fs').readFileSync(0, 'utf8').trim();
  const ms = process.env.PARMIND_ELAPSED;
  const dl = Number(process.env.PARMIND_DEADLINE || 0);
  const n = ms === '?' ? NaN : Number(ms);
  let msg;
  if (ctx) {
    const rel = (ctx.match(/relevance=\"([0-9.]+)\"/) || [])[1] || '?';
    const notes = (ctx.match(/parmind:node:/g) || []).length;
    msg = 'parmind: ' + notes + ' note' + (notes === 1 ? '' : 's') + ' injected · relevance ' + rel + ' · ' + ms + 'ms';
  } else if (!isNaN(n) && dl && n >= dl) {
    msg = 'parmind: no context — timed out at ' + dl + 'ms (took ' + ms + 'ms)';
  } else {
    msg = 'parmind: no context — nothing relevant, not linked, or backend unreachable (' + ms + 'ms)';
  }
  const out = { systemMessage: msg };
  if (ctx) out.hookSpecificOutput = { hookEventName: 'UserPromptSubmit', additionalContext: ctx };
  process.stdout.write(JSON.stringify(out));
" 2>/dev/null || true

exit 0
