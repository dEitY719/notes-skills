#!/usr/bin/env bash
# Repo self-checks, run by the reusable skill-check workflow
# (harness-skills `skill-check.yml`, "Repo self-checks pass (tests/)").
#
# That step lists `tests/*.sh`, but as soon as `tests/run.sh` is one of them it
# runs THIS FILE ONLY. So every other check in tests/ must be invoked from
# here, or it silently never runs in CI (PR #12 review, codex BLOCKER — which
# is also how `collect-commits-selftest.sh` had been dark since PR #11).
#
# Per harness-skills' README ("Where a repo's tests live"): an existing check
# in another shape is adapted by a two-line `tests/` script, not by a
# discovery loop that greps every skill's lib/ for a marker.
set -eu
here="$(dirname "$0")"

bash "$here/collect-commits-selftest.sh"
bash "$here/gather-git-context-selftest.sh"
bash "$here/../skills/rca/lib/validate-rca.sh" --self-test
