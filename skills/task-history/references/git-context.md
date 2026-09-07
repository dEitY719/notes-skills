# Git Context — Step 3

Step 3 is one call:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/task-history/lib/gather-git-context.sh" [<max-commits>]
```

`<max-commits>` defaults to 10. The helper is read-only — it never writes,
commits, or fetches.

## Output fields

Every line is `<key>=<value>`, and a value never spans lines:

| Key | Value |
|-----|-------|
| `project` | Repo name from the `origin` URL (`.git` stripped); falls back to the checkout directory name, then `N/A`. |
| `branch` | Current branch, or `detached@<short-sha>`, or `N/A` outside a repo. |
| `base` | Detected default branch, no `origin/` prefix — from `refs/remotes/origin/HEAD`, falling back to `origin/main`, `origin/master`, `main`, `master`, then `N/A`. |
| `commits` | Commit count in `<base>..HEAD`. `0` when there is no base, no commit yet, or HEAD is the base. |
| `diffstat` | `git diff --shortstat <base>...HEAD`, empty when there is no diff. |
| `log` | One line per recent commit, `<short-sha> <subject>`, newest first, at most `<max-commits>`. Absent when the repo has no commits. |

Exit code is 0 whenever the arguments are valid — **including outside a git
repo**, where the output is `project=N/A`, `branch=N/A`, `base=N/A`,
`commits=0`, `diffstat=` and no `log` lines. So Step 3 reads one output shape
instead of branching on "am I in a repo"; a `project` of `N/A` is what the
entry records. Exit 2 means a usage error (a non-numeric or extra argument).

`project` is the value the entry's `## HH:MM | project-name | title` heading
uses (`file-entry-structure.md`), and the `log` lines are the raw material for
the JIRA and PR blocks — pick this session's commits out of them using the
conversation, not just everything dated today.

## Running it outside Claude Code

`CLAUDE_PLUGIN_ROOT` is a Claude Code-only environment variable, and this
workflow runs in whatever project the user is working in, so the CWD is not
this plugin's repo. No other harness (Codex, Kimi, Gemini, Hermes, OpenCode)
sets an equivalent. Compute the path from this file's own absolute path
instead — fill in `THIS_FILE` with the path the tool that just read this file
reported:

```bash
THIS_FILE="<absolute path of the file you are reading now>"
d="$(dirname "$THIS_FILE")"
while [ "$(basename "$d")" != "skills" ] && [ "$d" != "/" ]; do d="$(dirname "$d")"; done
bash "$d/task-history/lib/gather-git-context.sh"
```

Walking up to `skills/` rather than counting `../` levels keeps the snippet
correct from both depths it can be pasted at (`skills/task-history/SKILL.md`
and this file).

## If the helper cannot run

These are the commands it wraps. Use them only as a fallback — the base branch
is the part worth not hardcoding:

```bash
basename "$(git remote get-url origin)" .git   # project, when a remote exists
git symbolic-ref --short refs/remotes/origin/HEAD   # -> origin/<base>
git rev-list --count <base>..HEAD
git diff --shortstat <base>...HEAD
git log --format='%h %s' -n 10
```

## Self-test

`bash skills/task-history/lib/gather-git-context.sh --selftest` builds
throwaway repos in `$TMPDIR` and asserts the two behaviours this helper exists
for: a default branch that is not `main` is detected, and a repo with no
remote still gets a project name. CI runs it through
`tests/gather-git-context-selftest.sh`.
