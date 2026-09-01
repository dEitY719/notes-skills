# notes — skill index

Five skills for writing up finished work. Each lives in this extension's
`skills/` directory. They are task-triggered: load the one that matches the job
by reading its `SKILL.md`, then follow it. Do not load all five.

| Skill | Read | Use when |
|-------|------|----------|
| `rca` | `@./skills/rca/SKILL.md` | Documenting an incident, a non-obvious bug fix, or a repeated mistake as a formal nine-section root-cause analysis. |
| `insight` | `@./skills/insight/SKILL.md` | Capturing one reusable pattern from the current chat as a short note in the current repo's `docs/guide/learnings/`. |
| `release-note` | `@./skills/release-note/SKILL.md` | Turning git history between two releases into user-facing release notes grouped by theme. |
| `task-history` | `@./skills/task-history/SKILL.md` | Recording this session's work into a daily log as a JIRA ticket plus a PR description. |
| `blog-dev-learnings` | `@./skills/blog-dev-learnings/SKILL.md` | Turning a debugging war story into an entertaining Korean blog post. |

Each skill's `references/` directory holds the detail it loads on demand;
`SKILL.md` says which file to read and when. Do not read `references/` files up
front.

## Picking between them

The discriminator is **where the file lands** and **how formal it is**:

- `insight` writes inside the **current repo** (`docs/guide/learnings/`).
- `release-note` writes inside the **current repo** (`docs/release-notes/` or
  the project's existing convention).
- `rca`, `task-history`, and `blog-dev-learnings` write to absolute paths
  outside it (`$RCA_REPO_PATH`, `$TASK_HISTORY_DIR`, `~/para/archive/`).
- Same incident, three registers: `rca` is the formal postmortem,
  `blog-dev-learnings` is the narrative retelling, `insight` is the one-pattern
  takeaway. Pick one; do not write all three unasked.

## Tool mapping for Gemini CLI

The skills speak in actions. On Gemini CLI these resolve to:

- "Read a file" -> `read_file` / `read_many_files`
- "Create a file" / "edit a file" -> `write_file`, `replace`
- "Run a shell command" -> `run_shell_command`
- "Search file contents" -> `grep_search`
- "Find files by name" -> `glob`
- "Create a todo" -> `write_todos`
- "Ask the user" -> `ask_user`
- "Dispatch a subagent" -> `invoke_agent` with `agent_name: "generalist"`

The full mapping, including every capability gap and its workaround, is owned by
the sibling repo `dEitY719/harness-skills` at `references/gemini-tools.md`
(dotfiles #1410 F-5) — read it there; this repo keeps no copy. On Antigravity
read that repo's `references/antigravity-tools.md` instead: `agy` shares
`~/.gemini` but not Gemini CLI's tool names.

## Capability gaps on Gemini CLI

- Every skill here builds its document from the current conversation. Gemini CLI
  cannot read a past session's transcript: use what is in the live context, and
  when that is empty, ask the user for the story rather than inventing one.
- `rca` (`--commit`) and `task-history` (auto-commit) run `git commit` through
  `run_shell_command`. Neither pushes unless its documented env var says so —
  do not add a push.
- `insight` refuses to run outside a repo that already has
  `docs/guide/learnings/`, and re-reads that directory's `README.md` as its
  rulebook every run. Do not substitute a remembered version of those rules.

## Safety rules

- **Never overwrite silently.** `insight` surfaces a diff and asks; `rca` and
  `blog-dev-learnings` stop rather than clobber an existing slug;
  `task-history` appends, never rewrites.
- **Never auto-write to a memory store.** `insight` may *suggest* a
  `memory/` pointer and then wait for a yes.
- **Never fabricate provenance.** A note with no PR, commit SHA, issue number,
  or `file:line` is not worth keeping — say so and stop instead of padding.
