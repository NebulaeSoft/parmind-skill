# Changelog

## v0.0.1 — 2026-07-30

First publish.

- Parmind skill for Claude Code (`skills/parmind/`): SKILL.md + USAGE.md
  (agentskills.io-valid, `skills-ref validate` clean).
- Compiled, minified CLI bundle (`scripts/parmind-cli.mjs`, Node 22+): search, notes, areas,
  relations; device-flow `login` (browser approval, no copied keys); scoped `install` wizard
  (global or per-project Minds); `link`/`unlink`/`kb:list`/`status`/`doctor`;
  machine-readable `PARMIND_SETUP_REQUIRED` contract (exit 3) for agents.
- Built from Parmind monorepo `libs/parmind-skill` @ `939495b0`.
