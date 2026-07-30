# Security Policy

## Reporting a vulnerability

Please report vulnerabilities privately via
[GitHub Security Advisories](https://github.com/NebulaeSoft/parmind-skill/security/advisories/new)
— do **not** open a public issue. We'll acknowledge within a few business days.

## Scope

This repository ships the Parmind agent skill and a compiled CLI bundle
(`skills/parmind/scripts/parmind-cli.mjs`). Reports about the Parmind service itself
([parmind.app](https://parmind.app)) are also welcome through the same channel.

## Handling credentials safely

- Credentials live only in `~/.parmind/config.json` (created `0600` in a `0700` dir, written
  atomically). Keys are Mind-scoped; `logout` revokes every stored key server-side.
- **Never pass `--api-key` on the command line** — it can leak via shell history and process
  listings. The flag exists for CI/automation with ephemeral keys only.
- **Treat `--api-base` / `PARMIND_API_BASE` as sensitive.** It controls where your API key is sent
  (`Authorization: ParmindKey …`). Only point it at hosts you trust; a malicious value exfiltrates
  your key.
- Project files (`.parmind/config.json` in repos) are secret-free by design — they contain only a
  Mind id and display metadata, and are safe to commit.

## Agent safety

Content returned from your knowledge base is wrapped in randomized
`<untrusted-parmind-data-…>` fences and SKILL.md instructs agents to treat it strictly as data —
never as instructions. If you find a way to break that boundary, that is a vulnerability we want
to hear about.
