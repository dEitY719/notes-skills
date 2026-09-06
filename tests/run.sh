#!/usr/bin/env bash
# Repo self-checks, run by the reusable skill-check workflow
# (harness-skills `skill-check.yml`, "Repo self-checks pass (tests/)").
#
# Per harness-skills' README ("Where a repo's tests live"): an existing check
# in another shape is adapted by a two-line `tests/` script, not by a
# discovery loop that greps every skill's lib/ for a marker.
exec bash skills/rca/lib/validate-rca.sh --self-test
