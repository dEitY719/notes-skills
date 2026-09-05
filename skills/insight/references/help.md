# notes:insight — help

## Usage

```
/notes:insight [topic-hint]
/notes:insight [topic-hint]
```

## Arguments

- `topic-hint` (optional) — a phrase anchoring which insight from the
  current chat to capture. If omitted, the skill scans recent turns and
  proposes 1–3 candidates for you to pick.

## What it does

Archives one reusable insight from the current conversation as a short
Korean note in `<repo-root>/docs/guide/learnings/<slug>.md`, following the
repo's README-defined template (5 sections, 50–80 lines, source links to
PR / commit / file:line). Also updates `docs/guide/learnings/README.md` index.

## Examples

```
/notes:insight                       # propose candidates from recent chat
/notes:insight upstream short        # focus on the %(upstream:short) finding
/notes:insight gh deprecation        # focus on the gh CLI deprecation workaround
```

## Related skills

- `notes:blog-dev-learnings` — narrative "삽질" blog posts in `~/para/archive/`
- `notes:rca` — formal RCA / postmortem (Jekyll)
- `notes:task-history` — JIRA / PR description drafting from session work

If your intent matches one of those, use that skill instead — notes:insight
is for short, repo-internal technical patterns aimed at human teammates.

## Refuses to write

See `references/routing.md`. Topics belonging in `docs/guide/technic/`,
`docs/.ssot/`, `docs/feature/<name>/`, `<plugin>-skills/skills/`, or `memory/`
are routed to the correct home instead of forced into `docs/guide/learnings/`.
