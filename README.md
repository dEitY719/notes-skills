# notes-skills

Five skills for writing up finished work — the root-cause analysis, the
reusable-pattern note, the release notes, the daily task log, the debugging
war story. Packaged as a single plugin named `notes`, installable on six
coding-agent harnesses.

Each skill mines the conversation you just had instead of asking you to retype
it.

## Skills

| Skill | Invoke | What it does |
|-------|--------|--------------|
| `rca` | `/notes:rca [--commit] [--audience blog\|private\|internal]` | Writes a nine-section, Jekyll-ready root-cause analysis to `${RCA_REPO_PATH}/docs/analysis/YYYY-MM-DD-<slug>.md`. One document serves postmortem review, blog, AI training, and onboarding. |
| `insight` | `/notes:insight [topic-hint]` | Captures one reusable pattern from the chat as a 50-80 line Korean note in the **current repo's** `docs/guide/learnings/`, and updates that directory's index. Refuses without real provenance. |
| `release-note` | `/notes:release-note [<anchor-ref>] [<head-ref>]` | Finds the anchor commit, categorizes by conventional-commit prefix, and groups commits into user-facing themes rather than listing them one-to-one. |
| `task-history` | `/notes:task-history ["<description>"]` | Appends this session's work to a daily log as a JIRA-pasteable block plus a markdown PR description, then auto-commits. |
| `blog-dev-learnings` | `/notes:blog-dev-learnings "<topic-hint>"` | Retells a debugging war story as an entertaining Korean blog post following the arc 고통 -> 삽질 -> 깨달음 -> 해결. |

### Picking between them

Same incident, three registers: `rca` is the formal postmortem,
`blog-dev-learnings` is the narrative retelling, `insight` is the one-pattern
takeaway. Pick one.

The other discriminator is **where the file lands**:

| Writes inside the current repo | Writes to an absolute path outside it |
|---|---|
| `insight` -> `docs/guide/learnings/` | `rca` -> `$RCA_REPO_PATH` (default `~/para/archive/rca-knowledge`) |
| `release-note` -> the project's existing release-note convention | `task-history` -> `$TASK_HISTORY_DIR` (default `~/para/archive/playbook/docs/task-history/`) |
| | `blog-dev-learnings` -> `~/para/archive/playbook/docs/dev-learnings/` |

`insight` is the only skill that requires the target repo to already have
`docs/guide/learnings/` — it re-reads that directory's `README.md` as its
rulebook on every run.

## Install

### Claude Code

```
/plugin marketplace add dEitY719/notes-skills
/plugin install notes@notes-skills
```

### Codex

```
codex plugin install dEitY719/notes-skills
```

### Kimi CLI

```
kimi plugin install dEitY719/notes-skills
```

### Hermes Agent

```
hermes plugins install dEitY719/notes-skills
```

### OpenCode

See [`.opencode/INSTALL.md`](.opencode/INSTALL.md).

### Gemini CLI / Antigravity

```
gemini extensions install https://github.com/dEitY719/notes-skills
```

Antigravity (`agy`) shares `~/.gemini`, so it inherits the install.

## Harness support

These skills are written in Claude Code's vocabulary, but they are mostly
read-conversation / write-markdown work, so they port cleanly. The per-harness
tool mappings and capability gaps are documented once, in
[`dEitY719/harness-skills/references/`](https://github.com/dEitY719/harness-skills/tree/main/references)
(#1410 F-5); read the one file for the harness you are on.

| Skill | Claude Code | Codex | Kimi | Gemini / Antigravity | Hermes | OpenCode |
|-------|:-----------:|:-----:|:----:|:--------------------:|:------:|:--------:|
| `rca` | full | full | full | full | full | full |
| `insight` | full | full | full | full | full | full |
| `release-note` | full | full | full | full | full | full |
| `task-history` | full | full | full | full | full | full |
| `blog-dev-learnings` | full | full | full | full | full | full |

The one thing every harness must supply itself is the raw material: these skills
read the **current conversation**. None of them can reach a past session's
transcript, on any harness — when the live context is empty, they ask rather
than invent.

Skills that pause for an answer (`insight` picking a candidate,
`blog-dev-learnings` picking a title) need a real user reply; an auto-approve
session setting is not one.

## Layout

Manifests live at the repo root and all point at one flat `skills/` directory:

```
.
├── skills/{rca,insight,release-note,task-history,blog-dev-learnings}/
│   ├── SKILL.md
│   └── references/
├── .claude-plugin/{marketplace,plugin}.json     Claude Code
├── .codex-plugin/plugin.json                    Codex
├── .kimi-plugin/plugin.json                     Kimi CLI
├── .hermes-plugin/{plugin.yaml,__init__.py}     Hermes Agent
├── .opencode/plugins/notes.js + INSTALL.md      OpenCode
├── .agents/plugins/marketplace.json             Antigravity
├── gemini-extension.json + GEMINI.md            Gemini CLI
├── package.json
├── CLAUDE.md · AGENTS.md -> CLAUDE.md
└── LICENSE
```

Only Claude Code understands a nested `plugins/<name>/skills/` layout. The other
five harnesses resolve manifests at the repo root and a skills tree at
`./skills/`, so this repo keeps everything flat. See [`CLAUDE.md`](CLAUDE.md) for
the full rationale and contribution rules.

The `.kimi-plugin/` manifest is pre-provisioned: Kimi CLI is not installed on the
maintainer's machines yet, and shipping the manifest now costs nothing and saves
a migration later.

## CI

[`.github/workflows/validate.yml`](.github/workflows/validate.yml) calls the
reusable workflow owned by
[`dEitY719/harness-skills`](https://github.com/dEitY719/harness-skills/blob/main/.github/workflows/skill-check.yml)
(#1410 D-10) — manifest parsing, required files, skill frontmatter,
progressive-disclosure line limits, the Codex description budget, version
agreement, shellcheck, and an emoji gate.

There are no checks defined in this repo. To change what is validated here, open
a PR against `harness-skills`; a merge to its `main` ships to all fifteen repos
at once.

## Provenance

These skills were extracted from
[`dEitY719/dotfiles`](https://github.com/dEitY719/dotfiles)
(`claude/skills/write-{rca,insight,release-note,task-history,blog-dev-learnings}`)
as a content snapshot — no history rewriting. The source commit SHA is recorded
in this repo's first commit message. The `write-` prefix is dropped here because
the plugin namespace (`notes:`) now supplies it; the dotfiles originals stay put
and `/write:rca` keeps working until #1410 Phase 4 removes them.

This is part of Phase 1 of the dotfiles #1410 migration; `packaging-skills` was
Phase 0 and `harness-skills` is its sibling.

## License

MIT. See [LICENSE](LICENSE).
