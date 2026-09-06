#!/bin/sh
# Runs lib/collect-commits.sh's own selftest. Discovered by the reusable
# skill-check workflow's tests/*.sh convention (dEitY719/harness-skills
# skill-check.yml, "Repo self-checks pass (tests/)").
set -eu
exec bash "$(dirname "$0")/../lib/collect-commits.sh" --selftest
