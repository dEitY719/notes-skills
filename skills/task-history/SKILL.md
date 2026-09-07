---
name: task-history
description: >-
  오늘 한 작업을 JIRA 티켓 + PR 설명 형식으로 daily log 에 기록. Use for
  `/notes:task-history` or "record what I did this session". Do NOT use for reusable
  patterns (notes:insight), postmortems (notes:rca), or vault notes
  (pkm:obsidian-session-clip).
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
license: MIT
metadata:
  model_recommendation:
    tier: haiku
    reason: "simple session summary: conversation mining -> JIRA + PR templates -> append file + auto-commit; bounded structured output"
    claude: prefer
    non_claude: advisory-only
---

# notes:task-history

## Help

If args is `-h`/`--help`/`help`, read `references/help.md` verbatim and stop.

Document completed work from the current conversation into a daily task history file,
producing two copy-paste-ready formats: a JIRA ticket (plain text with section
symbols) and a git PR description (markdown). Works across any project — the
output directory is global, not repo-relative.

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `<description>` | Free-text extra context | none — mine the conversation |
| `-h` / `--help` / `help` | Print `references/help.md` verbatim and stop. | — |

Env: `TASK_HISTORY_DIR` (default `~/para/archive/playbook/docs/task-history/`)

## Step-by-step workflow

Steps 1–8 are sequential — if Step 1 cannot resolve a writable directory or Step 7 commit fails, stop and report rather than producing a partial entry.

### Step 1: Determine output file path

Resolve the storage directory and today's filename:

```
directory = $TASK_HISTORY_DIR or ~/para/archive/playbook/docs/task-history/
filename  = YYYY-MM-DD-task-list.md  (e.g. 2026-03-20-task-list.md)
```

Run `mkdir -p` on the directory if it does not exist.

### Step 2: Analyze the current conversation

Extract **what was done** (concrete actions/changes), **why** (background, trigger), and **what resulted** (outcomes, files, PRs, issues). Use any description argument as extra context, but still analyze the conversation for completeness.

### Step 3: Gather git information

Run `bash "${CLAUDE_PLUGIN_ROOT}/skills/task-history/lib/gather-git-context.sh"` — it prints
`project`/`branch`/`base`/`commits`/`diffstat`/`log` and exits 0 even outside a repo.
**`CLAUDE_PLUGIN_ROOT` is Claude Code only** — every other harness takes the path fallback, and the field table, from `references/git-context.md` before running anything.

### Step 4: Generate JIRA ticket format

Read `references/jira-template.md` for the JIRA Description-pasteable text block.

### Step 5: Generate PR format (conditional)

Read `references/pr-template.md` for the markdown PR template. Skip entirely if no
commits exist in the conversation.

### Step 6: Write to file

Read `references/file-entry-structure.md` for the append/create + separator policy,
per-entry structure, and output conventions (emoji-free, append-only, language).

### Step 7–8: Auto-commit + confirm

Read `references/commit-confirm.md` for the commit pattern.

## Example

Read `references/example.md` for a full worked entry.

## Final Output

```
[OK] notes:task-history — entry appended
  path: <task-history-file>
  time: HH:MM
  project: <project-name>
  pr_section: included | skipped
  commit: <hash> chore(task-history): YYYY-MM-DD <summary>

Next: paste JIRA block into ticket / open PR with the markdown block
```

## Related skills

재사용 패턴 문서화는 [[notes:insight]], 장애 분석은 [[notes:rca]]. 세션 1건을 PARA vault Inbox 노트로 남기는 것은 [[pkm:obsidian-session-clip]] — 이쪽은 일자별 daily log append 다.
