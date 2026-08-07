# Parmind Skill

Give your agents better context through [Parmind](https://parmind.app) — your personal knowledge
base ("second brain"). This skill teaches **Claude Code** to search, read, and save knowledge in
your Minds, straight from the conversation.

> Built and verified for Claude Code, which installs it as a **plugin**. Other agents (Codex, Cursor,
> Copilot, …) are on the roadmap but not supported yet.

## Install

Parmind is a Claude Code plugin, served from this repo's own marketplace:

```
/plugin marketplace add NebulaeSoft/parmind-skill
/plugin install parmind@parmind-plugins
```

Then link a Mind once — this opens your browser to approve the account link and lets you pick a Mind:

```sh
parmind-cli login
parmind-cli status     # confirm what's linked
```

The plugin ships the skill, the CLI and the per-turn context hook together. The hook is registered by
the plugin's own `hooks/hooks.json` — nothing is merged into your `~/.claude/settings.json`, and
disabling the plugin removes it atomically.

**Updating.** Self-hosted marketplaces don't auto-update. After a new release:

```
/plugin marketplace update parmind-plugins
```

### Other agents

Not supported yet. `parmind-cli install --agent <name>` fails loudly rather than half-installing a
host with no context-hook transport — that would look like success and behave like nothing.

### Per-project Minds

- Your **global default** Mind is used everywhere (`~/.parmind/config.json`, created by login).
- `install --project` (or `link`) writes a secret-free `.parmind/config.json` into a repo choosing
  that project's Mind. Commit it — teammates get the right Mind automatically and just run `login`
  for their own key. The project's Mind always beats the global default.
- Switch any time: `link` (browser picker), `link --kb <id>`, `kb:list`, `status`.

## Usage

Once installed, Claude Code uses the skill automatically when your knowledge base is relevant.
The bundled CLI (full reference: [USAGE](skills/parmind/USAGE.md)):

```
search --query <q>          full-text search of the active Mind
note:create / node:update   save or extend notes (markdown, [[wikilinks]])
note:get / node:context     read a note and its connections
node:list / area:*          browse and organize
login / link / status       account + Mind management
doctor                      diagnose setup problems
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `PARMIND_SETUP_REQUIRED` + exit code 3 | Not set up — run the `install` command above |
| "Not linked" | `… parmind-cli.mjs login` |
| "…no key for it — run `parmind-cli link`" | The project's Mind isn't in your keyring yet — `… parmind-cli.mjs link` |
| Anything else | `… parmind-cli.mjs doctor`, then open an issue |

Questions & bugs: [GitHub Issues](https://github.com/NebulaeSoft/parmind-skill/issues).
Security reports: see [SECURITY.md](SECURITY.md) — please do not open public issues for those.

## Prerequisites

- **Node.js 22+** — the CLI is a bundled Node ESM script (`scripts/parmind-cli.mjs`), not a native
  binary.
- A [Parmind](https://parmind.app) account.

## Provenance & verification

The bundle is compiled and minified from the private Parmind monorepo
(`libs/parmind-skill`, commit `939495b0`) via esbuild
(`nx bundle-cli parmind-skill` — `--bundle --minify --platform=node --format=esm --target=node22`).
It talks only to Parmind endpoints (`merlin.parmind.com` API, `parmind.app/connect` for browser
approval) — no telemetry. Notable bundled dependencies: commander, marked.

Each release tag has the bundle + SHA-256 attached on
[GitHub Releases](https://github.com/NebulaeSoft/parmind-skill/releases). Verify a placed copy:

```sh
shasum -a 256 "$HOME/.claude/skills/parmind/scripts/parmind-cli.mjs"
# compare with parmind-cli.mjs.sha256 on the matching release
```

Credentials are stored only in `~/.parmind/config.json` (mode 0600). Never pass `--api-key` on the
command line (shell history), and treat `--api-base`/`PARMIND_API_BASE` as sensitive — it controls
where your key is sent (see [SECURITY.md](SECURITY.md)).

## Releases

Git tags are the release mechanism (`v0.0.1`, …) — see [CHANGELOG](CHANGELOG.md). Claude Code reads
this repository through the marketplace defined in `.claude-plugin/marketplace.json`; GitHub Release
assets are a convenience mirror for verification, never the install source.
