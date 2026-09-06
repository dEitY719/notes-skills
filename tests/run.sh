#!/usr/bin/env bash
# Repo self-checks, discovered and run by the reusable skill-check workflow
# (harness-skills `skill-check.yml`, "Repo self-checks pass (tests/)").
#
# Every `skills/*/lib/*.sh` that advertises `--self-test` is run. Discovery
# rather than an explicit list: nothing here mutates anything outside a
# temporary directory, so there is no script that must be kept off the list —
# and a new helper cannot be forgotten.

set -euo pipefail
cd "$(dirname "$0")/.."

# Through a file, never `< <(...)`: a process substitution hides git's exit
# status from `set -e`, which turns a failed discovery into a green no-op.
listing=$(mktemp)
trap 'rm -f "$listing"' EXIT
git ls-files -z -- 'skills/*/lib/*.sh' > "$listing"
mapfile -t -d '' scripts < "$listing"

ran=0
for s in "${scripts[@]}"; do
    grep -qE -- '^[[:space:]]*(-[^)]*\|)*--self-test(\|[^)]*)?\)' "$s" || continue
    echo "note  $s --self-test"
    bash "$s" --self-test
    ran=$((ran + 1))
done

echo "ok    $ran self-test(s) passed"
