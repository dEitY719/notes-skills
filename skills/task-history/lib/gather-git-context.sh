#!/usr/bin/env bash
# gather-git-context.sh — the read-only git half of notes:task-history Step 3.
#
# Replaces the four commands Step 3 used to spell out in prose, and owns the
# two parts of them that were error-prone (notes-skills#5, check 12):
#
#   * the project-name fallback chain (origin remote -> checkout directory
#     name -> N/A), which used to be described in references/rules.md — a
#     different file from the command that needed it;
#   * the base branch, which used to be hardcoded as `main` in
#     `git diff main...HEAD --stat`. It is now resolved from
#     refs/remotes/origin/HEAD, falling back to origin/main, origin/master,
#     main, master, then N/A.
#
# Usage:  bash skills/task-history/lib/gather-git-context.sh [<max-commits>]
#         bash skills/task-history/lib/gather-git-context.sh --selftest
#
# Output: `key=value` lines on stdout. A value never spans lines, so every
#         line is `<key>=<rest of line>`:
#
#   project=<name>       repo name from origin, else checkout dir name, else N/A
#   branch=<name>        current branch, else `detached@<short-sha>`, else N/A
#   base=<name>          detected default branch, no `origin/` prefix, else N/A
#   commits=<n>          commits in `<base>..HEAD` (0 when base is N/A or is HEAD)
#   diffstat=<summary>   `git diff --shortstat <base>...HEAD`, empty when none
#   log=<sha> <subject>  one line per recent commit, newest first, at most
#                        <max-commits> of them (default 10); absent if none
#
# Exit:   0 always when the arguments are valid — including outside a git
#         repo, which prints `project=N/A` and the rest of the keys so the
#         caller reads one shape instead of branching on "am I in a repo".
#         2 on a usage error.

set -uo pipefail

usage() {
  printf 'usage: gather-git-context.sh [<max-commits>]\n' >&2
  printf '       gather-git-context.sh --selftest\n' >&2
  exit 2
}

# One line, no tabs: keeps the `key=value` grammar intact for a caller that
# splits on the first `=` and reads to end of line.
oneline() { printf '%s' "$1" | tr '\n\r\t' '   '; }

project_name() {
  local url top
  if url=$(git remote get-url origin 2>/dev/null) && [ -n "$url" ]; then
    url=${url%/}
    url=${url%.git}
    # `*[:/]`, not `*/`: an SCP-style remote with no path component
    # (`git@host:repo.git`) has no slash to cut at, and would otherwise
    # report `git@host:repo` as the project name (PR #12 review, agy).
    printf '%s\n' "${url##*[:/]}"
    return
  fi
  if top=$(git rev-parse --show-toplevel 2>/dev/null) && [ -n "$top" ]; then
    basename "$top"
    return
  fi
  printf 'N/A\n'
}

base_branch() {
  local ref cand
  if ref=$(git symbolic-ref --short -q refs/remotes/origin/HEAD); then
    printf '%s\n' "${ref#origin/}"
    return
  fi
  for cand in origin/main origin/master main master; do
    if git rev-parse --verify -q "${cand}^{commit}" >/dev/null; then
      printf '%s\n' "${cand#origin/}"
      return
    fi
  done
  printf 'N/A\n'
}

gather() { # <max-commits>
  local max="$1" branch base base_ref cand commits diffstat line

  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    printf 'project=N/A\nbranch=N/A\nbase=N/A\ncommits=0\ndiffstat=\n'
    return 0
  fi

  branch=$(git symbolic-ref --short -q HEAD) ||
    branch="detached@$(git rev-parse --short HEAD 2>/dev/null || printf 'unknown')"

  base=$(base_branch)
  base_ref=""
  if [ "$base" != "N/A" ]; then
    # Local branch first, remote-tracking second. The local base tip is what
    # this branch was actually cut from, so unpushed commits on it belong to
    # neither `commits` nor `diffstat`; preferring `origin/<base>` would fold
    # them in and change the meaning of the `main...HEAD` scope this helper
    # replaced (PR #12 review, codex BLOCKER). A fresh clone that never
    # created the local branch still resolves through `origin/<base>`.
    for cand in "$base" "origin/$base"; do
      if git rev-parse --verify -q "${cand}^{commit}" >/dev/null; then
        base_ref="$cand"
        break
      fi
    done
  fi

  commits=0
  diffstat=""
  # No HEAD commit yet (unborn branch) => nothing to count or diff.
  if [ -n "$base_ref" ] && git rev-parse --verify -q HEAD >/dev/null; then
    commits=$(git rev-list --count "$base_ref..HEAD" 2>/dev/null) || commits=0
    # Three-dot: diff against the merge base, matching the `main...HEAD` form
    # this helper replaced.
    diffstat=$(git diff --shortstat "$base_ref...HEAD" 2>/dev/null | sed 's/^ *//')
  fi

  printf 'project=%s\n' "$(oneline "$(project_name)")"
  printf 'branch=%s\n' "$(oneline "$branch")"
  printf 'base=%s\n' "$(oneline "$base")"
  printf 'commits=%s\n' "$commits"
  printf 'diffstat=%s\n' "$(oneline "$diffstat")"

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    printf 'log=%s\n' "$(oneline "$line")"
  done < <(git log --format='%h %s' -n "$max" 2>/dev/null)
}

# --selftest: the cases that would have caught the two bugs this helper
# exists to fix — a non-`main` default branch, and a project name resolved
# without a remote. No framework on purpose; this repo ships no test runner.
selftest() {
  local self tmp fails=0 out
  self="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  chk() { # <label> <got> <want>
    if [ "$2" = "$3" ]; then
      printf '[OK] selftest: %s\n' "$1"
    else
      printf '[FAIL] selftest: %s -- got %q want %q\n' "$1" "$2" "$3"
      fails=$((fails + 1))
    fi
  }
  val() { printf '%s\n' "$1" | sed -n "s/^$2=//p"; }

  export GIT_AUTHOR_DATE="2025-06-01T00:00:00" GIT_COMMITTER_DATE="2025-06-01T00:00:00"
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

  # Fixture: an "upstream" whose default branch is `trunk`, not `main`, then a
  # clone of it — cloning is what sets refs/remotes/origin/HEAD.
  git init -q -b trunk "$tmp/upstream.git"
  git -C "$tmp/upstream.git" config user.email test@example.com
  git -C "$tmp/upstream.git" config user.name test
  git -C "$tmp/upstream.git" commit -q --allow-empty -m "chore: root"
  git clone -q "$tmp/upstream.git" "$tmp/work"
  git -C "$tmp/work" config user.email test@example.com
  git -C "$tmp/work" config user.name test

  out=$(cd "$tmp/work" && bash "$self")
  # 1. THE regression case: the default branch is `trunk`, and nothing here
  # may assume `main`.
  chk "base is the real default branch, not main" "$(val "$out" base)" "trunk"
  # 2. project name comes from the origin URL, `.git` suffix stripped.
  chk "project from origin url" "$(val "$out" project)" "upstream"
  chk "branch on a fresh clone" "$(val "$out" branch)" "trunk"
  chk "no commits ahead of base" "$(val "$out" commits)" "0"
  chk "diffstat empty with no diff" "$(val "$out" diffstat)" ""

  # 3. commits/diffstat/log on a feature branch measured against `trunk`.
  git -C "$tmp/work" checkout -q -b feature
  printf 'one\n' >"$tmp/work/a.txt"
  git -C "$tmp/work" add a.txt
  git -C "$tmp/work" commit -q -m "feat: add a"
  printf 'two\n' >>"$tmp/work/a.txt"
  git -C "$tmp/work" commit -q -am "fix: extend a"
  out=$(cd "$tmp/work" && bash "$self")
  chk "commits counted against detected base" "$(val "$out" commits)" "2"
  chk "diffstat reported" \
    "$(val "$out" diffstat | grep -c 'file changed')" "1"
  chk "log lines newest first" \
    "$(val "$out" log | head -1 | cut -d' ' -f2-)" "fix: extend a"
  chk "log line count" "$(val "$out" log | wc -l | tr -d ' ')" "3"
  # 4. max-commits argument caps the log lines.
  out=$(cd "$tmp/work" && bash "$self" 1)
  chk "max-commits caps log lines" "$(val "$out" log | wc -l | tr -d ' ')" "1"

  # 5. unpushed commits on the local base branch are NOT counted as this
  # branch's work — the local base tip wins over origin/<base> (PR #12
  # review, codex BLOCKER).
  git -C "$tmp/work" checkout -q trunk
  printf 'local only\n' >"$tmp/work/b.txt"
  git -C "$tmp/work" add b.txt
  git -C "$tmp/work" commit -q -m "chore: unpushed on trunk"
  git -C "$tmp/work" checkout -q -b later
  printf 'c\n' >"$tmp/work/c.txt"
  git -C "$tmp/work" add c.txt
  git -C "$tmp/work" commit -q -m "feat: add c"
  out=$(cd "$tmp/work" && bash "$self")
  chk "local base tip wins over origin/<base>" "$(val "$out" commits)" "1"

  # 6. an SCP-style remote with no path component still yields a bare name.
  git -C "$tmp/work" remote set-url origin "git@example.com:solo.git"
  out=$(cd "$tmp/work" && bash "$self")
  chk "scp-style remote without a path" "$(val "$out" project)" "solo"
  git -C "$tmp/work" remote set-url origin "$tmp/upstream.git"

  # 7. a repo with no remote falls back to the checkout directory name.
  git init -q -b main "$tmp/plain"
  git -C "$tmp/plain" config user.email test@example.com
  git -C "$tmp/plain" config user.name test
  git -C "$tmp/plain" commit -q --allow-empty -m "chore: root"
  out=$(cd "$tmp/plain" && bash "$self")
  chk "project falls back to directory name" "$(val "$out" project)" "plain"

  # 8. detached HEAD still reports a usable branch value.
  git -C "$tmp/plain" checkout -q --detach HEAD
  out=$(cd "$tmp/plain" && bash "$self")
  chk "detached HEAD labelled" \
    "$(val "$out" branch)" "detached@$(git -C "$tmp/plain" rev-parse --short HEAD)"

  # 9. outside a git repo: exit 0 with project=N/A, not an error the caller
  # has to branch on. GIT_CEILING_DIRECTORIES stops discovery from walking up
  # into whatever repo happens to contain $TMPDIR.
  mkdir -p "$tmp/outside"
  out=$(cd "$tmp/outside" && GIT_CEILING_DIRECTORIES="$tmp" bash "$self")
  rc=$?
  chk "outside a repo exits 0" "$rc" "0"
  chk "outside a repo: project=N/A" "$(val "$out" project)" "N/A"
  chk "outside a repo: base=N/A" "$(val "$out" base)" "N/A"
  chk "outside a repo: no log lines" "$(val "$out" log | wc -l | tr -d ' ')" "0"

  # 10. a bad argument is a usage error, not a silently ignored one.
  (cd "$tmp/work" && bash "$self" not-a-number >/dev/null 2>&1)
  chk "non-numeric max-commits exits 2" "$?" "2"
  (cd "$tmp/work" && bash "$self" 1 2 >/dev/null 2>&1)
  chk "extra argument exits 2" "$?" "2"
  (cd "$tmp/work" && bash "$self" --selftest extra >/dev/null 2>&1)
  chk "--selftest with extra args exits 2" "$?" "2"

  if [ "$fails" -eq 0 ]; then
    printf '[OK] gather-git-context selftest: all cases passed\n'
    exit 0
  fi
  printf '[FAIL] gather-git-context selftest: %d case(s) failed\n' "$fails"
  exit 1
}

if [ $# -ge 1 ] && [ "$1" = "--selftest" ]; then
  [ $# -eq 1 ] || usage
  selftest
fi
[ $# -le 1 ] || usage
MAX=${1:-10}
[[ "$MAX" =~ ^[1-9][0-9]*$ ]] || usage

gather "$MAX"
