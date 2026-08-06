# Parmind Skill

Give your agents better context through [Parmind](https://parmind.app) — your personal knowledge
base ("second brain"). This skill teaches **Claude Code** to search, read, and save knowledge in
your Minds, straight from the conversation.

> Built and verified for Claude Code. The [skills](https://github.com/vercel-labs/skills) installer
> can place the files for other agents too (`--agent '*'`), but only Claude Code is tested today.

## Install

```sh
npx github:NebulaeSoft/parmind-skill install
```

That runs the guided setup: it places the skill files, opens your browser to approve the account
link, lets you pick a Mind, and wires your `CLAUDE.md` — one flow, safe to re-run any time. Pin a
release with `npx github:NebulaeSoft/parmind-skill#v0.1.0 install`. If you only want to
authenticate, swap `install` for `login`; running `install` later completes the rest.

Prefer a persistent command, or installing for agents other than Claude Code?

```sh
npm i -g github:NebulaeSoft/parmind-skill   # then: parmind-cli install
# or place the files yourself, then run the setup:
npx -y skills@1.5.21 add NebulaeSoft/parmind-skill@v0.1.0 --skill parmind --agent '*'
node "$HOME/.claude/skills/parmind/scripts/parmind-cli.mjs" install
```

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

Git tags are the release mechanism (`v0.0.1`, …) — see [CHANGELOG](CHANGELOG.md). Installs go
through `skills add` reading this repository at a pinned tag; GitHub Release assets are a
convenience mirror for verification, never the install source.
