#!/usr/bin/env bash
# lib/collect-commits.sh — one categorized commit list for release-note Step 2.
#
# Replaces the five separate `git log | grep` passes that used to live in
# references/git-commands.md with one git invocation, and closes the
# prefix-list gap where `test`/`build`/`ci`/`perf`/`style` commits fell into
# neither a categorized bucket nor the non-conventional (`grep -vE`) one —
# they appeared in the exclusion pattern but had no include line of their own,
# so they were silently dropped from both (notes-skills#4).
#
#   bash lib/collect-commits.sh <anchor-ref> [<head-ref>]
#   bash lib/collect-commits.sh --selftest
#
# Output: one TSV line per commit, oldest first: `<type><TAB><sha><TAB><subject>`.
# <type> is the conventional-commit prefix (feat/fix/refactor/docs/chore/test/
# build/ci/perf/style, scope and `!` both tolerated, e.g. `feat(x)!:`) when the
# subject matches one, else `other` — so every commit lands in exactly one
# bucket and none can vanish between the categorized and non-conventional sets.
# A trailing summary line reports:
#   total=<n> other=<n> first_date=<YYYY-MM-DD> last_date=<YYYY-MM-DD>
#
# Exit 0 on success (zero commits in range included), 2 on usage/git error.
set -euo pipefail

usage() {
  printf 'usage: collect-commits.sh <anchor-ref> [<head-ref>]\n' >&2
  printf '       collect-commits.sh --selftest\n' >&2
  exit 2
}

CONVENTIONAL='feat|fix|refactor|docs|chore|test|build|ci|perf|style'

classify() { # <subject> -> prints type
  local subject="$1"
  local pattern="^($CONVENTIONAL)(\([^)]*\))?!?: "
  if [[ "$subject" =~ $pattern ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  else
    printf 'other\n'
  fi
}

collect() { # <anchor-ref> <head-ref>
  local anchor="$1" head_ref="$2" sha date subject type
  local total=0 other=0 first_date="" last_date=""

  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "collect-commits.sh: not in a git repo" >&2
    return 2
  fi
  if ! git rev-parse --verify "$anchor" >/dev/null 2>&1; then
    echo "collect-commits.sh: anchor ref not found: $anchor" >&2
    return 2
  fi
  if ! git rev-parse --verify "$head_ref" >/dev/null 2>&1; then
    echo "collect-commits.sh: head ref not found: $head_ref" >&2
    return 2
  fi

  while IFS=$'\t' read -r sha date subject; do
    [ -n "$sha" ] || continue
    type=$(classify "$subject")
    printf '%s\t%s\t%s\n' "$type" "$sha" "$subject"
    total=$((total + 1))
    [ "$type" = "other" ] && other=$((other + 1))
    [ -n "$first_date" ] || first_date="$date"
    last_date="$date"
  done < <(git log --reverse --format='%h%x09%ad%x09%s' --date=short "$anchor..$head_ref")

  printf 'total=%d other=%d first_date=%s last_date=%s\n' \
    "$total" "$other" "${first_date:-none}" "${last_date:-none}"
}

# --selftest: regression cases for the bug this helper exists to fix — a
# `test:`/`build:`/`ci:`/`perf:`/`style:` commit disappearing from every
# bucket. No framework on purpose, this repo ships no test runner.
selftest() {
  local self tmp fails=0
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

  git -C "$tmp" init -q -b main
  git -C "$tmp" config user.email test@example.com
  git -C "$tmp" config user.name test
  git -C "$tmp" commit -q --allow-empty -m "chore: anchor"
  anchor=$(git -C "$tmp" rev-parse HEAD)
  git -C "$tmp" commit -q --allow-empty -m "feat: add widget"
  git -C "$tmp" commit -q --allow-empty -m "test: cover widget"
  git -C "$tmp" commit -q --allow-empty -m "fix(widget): off-by-one"
  git -C "$tmp" commit -q --allow-empty -m "bump deps"

  out=$(cd "$tmp" && bash "$self" "$anchor" HEAD)

  # 1. every non-anchor commit appears exactly once, in order.
  types=$(printf '%s\n' "$out" | head -n -1 | cut -f1)
  chk "types in order" "$types" "$(printf 'feat\ntest\nfix\nother')"

  # 2. THE regression case: `test:` gets its own type, not lost.
  chk "test: commit classified, not dropped" \
    "$(printf '%s\n' "$out" | awk -F'\t' '$1=="test"' | wc -l | tr -d ' ')" "1"

  # 3. non-conventional subject is "other", still counted.
  chk "non-conventional commit is other" \
    "$(printf '%s\n' "$out" | awk -F'\t' '$3=="bump deps" {print $1}')" "other"

  # 4. summary line totals match.
  summary=$(printf '%s\n' "$out" | tail -1)
  chk "summary line" "$summary" "total=4 other=1 first_date=$(date +%Y-%m-%d) last_date=$(date +%Y-%m-%d)"

  # 5. bad anchor fails with exit 2, not a silent empty result.
  set +e
  (cd "$tmp" && bash "$self" "nope-not-a-ref" HEAD >/dev/null 2>&1)
  rc=$?
  set -e
  chk "bad anchor exits 2" "$rc" "2"

  if [ "$fails" -eq 0 ]; then
    printf '[OK] collect-commits selftest: all cases passed\n'
    exit 0
  fi
  printf '[FAIL] collect-commits selftest: %d case(s) failed\n' "$fails"
  exit 1
}

[ $# -ge 1 ] || usage
if [ "$1" = "--selftest" ]; then selftest; fi
[ $# -le 2 ] || usage

collect "$1" "${2:-HEAD}"
