# Changelog

## v0.1.0 — 2026-08-07

One-command install.

- Added a root `package.json` with a `bin` entry, so the repo is directly runnable from GitHub:
  `npx github:NebulaeSoft/parmind-skill install`. No npm registry publish and no separate
  `skills add` step required — the CLI bootstraps itself, then places the skill files.
- `npm i -g github:NebulaeSoft/parmind-skill` installs a persistent `parmind-cli` command.
- The two-step `skills add` + `parmind-cli install` flow still works and stays documented as
  the alternative for non-Claude-Code agents.
- Skill payload unchanged from v0.0.1.

## v0.0.1 — 2026-07-30

First publish.

- Parmind skill for Claude Code (`skills/parmind/`): SKILL.md + USAGE.md
  (agentskills.io-valid, `skills-ref validate` clean).
- Compiled, minified CLI bundle (`scripts/parmind-cli.mjs`, Node 22+): search, notes, areas,
  relations; device-flow `login` (browser approval, no copied keys); scoped `install` wizard
  (global or per-project Minds); `link`/`unlink`/`kb:list`/`status`/`doctor`;
  machine-readable `PARMIND_SETUP_REQUIRED` contract (exit 3) for agents.
- Built from Parmind monorepo `libs/parmind-skill` @ `939495b0`.
