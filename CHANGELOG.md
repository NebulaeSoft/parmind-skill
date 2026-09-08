# Changelog

## v0.1.3 — 2026-09-08

- Payload regenerated from parmind-sirius 6b89360.

## v0.1.2 — 2026-09-03

- Payload regenerated from parmind-sirius 2560914.

## v0.1.1 — 2026-08-11

- Payload regenerated from parmind-sirius 6c32e362.

## v0.1.0 — 2026-08-07

Claude Code plugin. **Installation has changed — see below.**

> This tag was re-issued on 2026-08-07 to carry the plugin surface. An earlier `v0.1.0` described
> a `npx github:…` / `skills add` install flow that this release replaces.

- **Parmind is now a Claude Code plugin**, served from this repo's own marketplace
  (`.claude-plugin/marketplace.json`, marketplace id `parmind-plugins`):

  ```
  /plugin marketplace add NebulaeSoft/parmind-skill
  /plugin install parmind@parmind-plugins
  ```

  This is the only supported way to install on Claude Code. `npx skills add` no longer places
  the skill there.
- **Proactive context.** A `UserPromptSubmit` hook consults the linked Mind each turn and injects
  what is relevant. It is registered by the plugin's own `hooks/hooks.json` — nothing is merged
  into your `~/.claude/settings.json`, and disabling the plugin removes the hook atomically.
  The hook is fail-open by contract: it never blocks a turn, and it is bounded by both a 5s hook
  timeout and the CLI's own `--deadline-ms`.
- **`bin/parmind-cli`** joins PATH for Claude Code's Bash tool, so `parmind-cli` works without a
  separate shim or a global npm install.
- **Other agents (Codex, Cursor, Copilot, …) are not supported yet.**
  `parmind-cli install --agent <name>` now fails with a clear message instead of half-installing a
  host that has no context-hook transport. The skill payload itself stays agent-agnostic so these
  can be enabled individually later.
- `parmind-cli install` no longer places skill files — the plugin ships them. It still performs
  account/Mind linking, and now writes its managed block to `AGENTS.md` (an existing `CLAUDE.md`
  still wins if present).
- Rebuilt CLI bundle; `SKILL.md` / `USAGE.md` rewritten for the adapter. The root `package.json`
  `bin` entry is retained.

## v0.0.1 — 2026-07-30

First publish.

- Parmind skill for Claude Code (`skills/parmind/`): SKILL.md + USAGE.md
  (agentskills.io-valid, `skills-ref validate` clean).
- Compiled, minified CLI bundle (`scripts/parmind-cli.mjs`, Node 22+): search, notes, areas,
  relations; device-flow `login` (browser approval, no copied keys); scoped `install` wizard
  (global or per-project Minds); `link`/`unlink`/`kb:list`/`status`/`doctor`;
  machine-readable `PARMIND_SETUP_REQUIRED` contract (exit 3) for agents.
- Built from Parmind monorepo `libs/parmind-skill` @ `939495b0`.
