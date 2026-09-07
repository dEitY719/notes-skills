#!/bin/sh
# Runs lib/collect-commits.sh's own selftest. Invoked from tests/run.sh, which
# is the single entry point the reusable skill-check workflow executes
# (dEitY719/harness-skills skill-check.yml, "Repo self-checks pass (tests/)").
set -eu
exec bash "$(dirname "$0")/../lib/collect-commits.sh" --selftest
