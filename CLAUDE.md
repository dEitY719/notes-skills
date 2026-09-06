# notes-skills — Contributor Guidelines

This file is the AI context document for this repo. `AGENTS.md` is a symlink to
it, so Claude Code, Codex, Gemini CLI, and every other harness read the same
text. Edit `CLAUDE.md`; never replace the symlink with a second copy.

## What this repo is

A single-plugin skill marketplace. The plugin is named `notes` and it bundles
five skills that turn finished work into a written document:

| Skill | Role |
|-------|------|
| `rca` | Nine-section root-cause analysis / postmortem, Jekyll-ready. |
| `insight` | One reusable pattern captured into the current repo's `docs/guide/learnings/`. |
| `release-note` | Git history between two releases, grouped into user-facing themes. |
| `task-history` | This session's work appended to a daily log as JIRA text plus a PR description. |
| `blog-dev-learnings` | A debugging war story retold as an entertaining Korean blog post. |

The skills were extracted from `dEitY719/dotfiles` (then at
`claude/skills/write-*`) as a snapshot — see the first commit for the source SHA.
Those dotfiles originals have since been removed
(dEitY719/dotfiles#1410 Phase 4), so this repo is now their only home.

## Layout: root manifests, one flat `skills/`

This repo deliberately does **not** use the nested `plugins/<name>/skills/`
"mono" layout. Every harness manifest sits at the repo root and points at a
single flat `./skills/` directory:

```
.claude-plugin/{marketplace,plugin}.json   Claude Code
.codex-plugin/plugin.json                  Codex
.kimi-plugin/plugin.json                   Kimi CLI
.hermes-plugin/{plugin.yaml,__init__.py}   Hermes Agent
.opencode/plugins/notes.js                 OpenCode
.agents/plugins/marketplace.json           Antigravity
gemini-extension.json + GEMINI.md          Gemini CLI
skills/<name>/SKILL.md                     the skills themselves
```

Only Claude Code understands the nested mono layout. The other five harnesses
resolve manifests at the repo root and a skills tree at `./skills/`, so nesting
would silently cut this plugin down to Claude-Code-only. **Do not move the
manifests under a `plugins/` directory.**

## Shared assets live in `harness-skills` — link, never copy

Two things this repo depends on are owned by `dEitY719/harness-skills`
(dEitY719/dotfiles#1410 F-5 / D-10):

1. **Per-harness tool mappings** — `references/{codex,kimi,gemini,antigravity,hermes,opencode}-tools.md`.
   This repo carries no `references/` tree of its own; `GEMINI.md`,
   `.opencode/INSTALL.md`, and `.kimi-plugin/plugin.json` link there instead.
   If you are about to paste one in, stop and add a link — one tool rename must
   stay one edit, not fifteen (NF-2).
2. **The CI workflow** — `.github/workflows/skill-check.yml`. This repo's
   `validate.yml` calls it with `plugin-name: notes`. Do not re-inline the
   checks here; to change what is checked, open a PR against `harness-skills`.

## Rules for changing skills

- **Skill directory name is the identity.** `skills/<name>/` must match the
  `name:` field in that skill's `SKILL.md` frontmatter, and that field is the
  **bare** name (`rca`), never namespaced (`notes:rca`). The harness supplies
  the `notes:` prefix at invocation time.
- **Invocation form in prose is namespaced.** Body text referring to a skill as
  a command writes `/notes:rca`.
- **Progressive disclosure.** `SKILL.md` stays under 100 lines (CI enforces it)
  and names which `references/` file to read and when. Detail lives in that
  skill's own `references/`. Do not inline a reference file back into
  `SKILL.md`.
- **Description budget.** CI sums every skill description and fails past 5,440
  characters — Codex's context budget. Keep new descriptions tight.
- **Honour each skill's safety contract.** Nothing here overwrites silently:
  `insight` surfaces a diff and asks, `task-history` appends, `rca` and
  `blog-dev-learnings` stop on an existing slug. `rca --commit` and
  `task-history` commit but never push unless their documented env var says so.
- **Provenance is non-negotiable.** These skills mine the conversation for PR
  numbers, commit SHAs, and `file:line` anchors. A step that would let a skill
  fabricate that instead of failing is a bug, not a convenience.

- **Helper scripts are optional, and self-testing when present.** A skill that
  needs a deterministic check ships it as `skills/<name>/lib/*.sh` with a
  `--self-test` case. `tests/run.sh` discovers every such script and runs it,
  and CI runs `tests/run.sh` — so nothing needs registering, but a helper
  without a `--self-test` is untested code.

## Emojis

Not in prose, manifests, or workflow files — token efficiency, same rule as the
upstream dotfiles repo. **One exception:** `skills/blog-dev-learnings/references/`
contains emoji as *subject matter* — that skill teaches emoji-styled Korean blog
headings, and its examples must show the real glyphs. CI's emoji gate is passed
`allow-emoji-paths: skills/blog-dev-learnings/references/` for exactly that
reason. Do not widen the allowlist; do not add emoji anywhere else.

## Version bumps

The version appears in seven manifests: `.claude-plugin/marketplace.json`,
`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`,
`.kimi-plugin/plugin.json`, `.hermes-plugin/plugin.yaml`,
`gemini-extension.json`, and `package.json`. CI checks that they agree — bump
all of them together. Versioning is independent per repo
(dEitY719/dotfiles#1410 D-9); this repo does not move in lockstep with its
siblings.
