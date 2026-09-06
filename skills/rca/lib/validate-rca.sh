#!/usr/bin/env bash
# validate-rca.sh — the mechanical half of notes:rca Step 3.
#
# Asserts what is deterministic about a drafted RCA document so the Step 3
# verdict is reproducible instead of re-derived by the model on every run.
# The judgment half of Step 3 (tone, concreteness, actionability) stays in
# references/phases-detail.md and is not checked here.
#
# Usage:  bash skills/rca/lib/validate-rca.sh <path-to-drafted.md>
#         bash skills/rca/lib/validate-rca.sh --self-test
#
# Output: one `[OK] <check>` / `[FAIL] <check>: <detail>` line per assertion.
#         `[WARN]` marks the document-length range, which the template calls
#         flexible — it is reported but never fails the run.
# Exit:   0 when every assertion passed, 1 otherwise.

set -uo pipefail

fail=0
ok()   { printf '[OK] %s\n' "$1"; }
bad()  { printf '[FAIL] %s: %s\n' "$1" "$2"; fail=1; }
warn() { printf '[WARN] %s: %s\n' "$1" "$2"; }

check_frontmatter() {
  local doc=$1 fm missing=()
  if [ "$(head -n 1 "$doc")" != '---' ]; then
    bad frontmatter "file does not open with a '---' delimiter"
    return
  fi
  fm=$(sed -n '2,/^---$/p' "$doc")
  if ! printf '%s\n' "$fm" | grep -q '^---$'; then
    bad frontmatter "opening '---' has no closing '---'"
    return
  fi
  local key
  for key in id title slug date; do
    printf '%s\n' "$fm" | grep -q "^${key}:" || missing+=("$key")
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    bad frontmatter "required key(s) missing: ${missing[*]}"
  else
    ok "frontmatter (delimited, id/title/slug/date present)"
  fi
}

# Sections 1-9 in template order. Section 6 (Compatibility Matrix) is
# conditional per references/document-template.md, so it is not required —
# but if present it must still sit between 5 and 7.
check_sections() {
  local doc=$1 seen prev=0 n missing=()
  seen=$(grep -o '^## Section [1-9]:' "$doc" | grep -o '[1-9]')
  for n in $seen; do
    if [ "$n" -le "$prev" ]; then
      bad sections "heading order is not ascending (Section $n follows Section $prev)"
      return
    fi
    prev=$n
  done
  for n in 1 2 3 4 5 7 8 9; do
    printf '%s\n' "$seen" | grep -qx "$n" || missing+=("$n")
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    bad sections "required section(s) missing: ${missing[*]}"
  else
    ok "sections (1-5,7-9 present, in order; 6 optional)"
  fi
}

check_summary_length() {
  local doc=$1 words
  words=$(awk '/^## Section 1:/{f=1;next} /^## Section [2-9]:/{f=0} f' "$doc" | wc -w)
  if [ "$words" -eq 0 ]; then
    bad summary-length "Section 1 (Executive Summary) is empty"
  elif [ "$words" -gt 100 ]; then
    bad summary-length "$words words, must be under 100"
  else
    ok "summary-length ($words words)"
  fi
}

check_total_length() {
  local doc=$1 words
  words=$(awk 'NR==1 && $0=="---"{fm=1;next} fm && $0=="---"{fm=0;next} !fm' "$doc" | wc -w)
  if [ "$words" -lt 1500 ] || [ "$words" -gt 2500 ]; then
    warn total-length "$words words, outside the 1500-2500 guide (flexible, not a failure)"
  else
    ok "total-length ($words words)"
  fi
}

# Same rule as the repo CI emoji gate: codepoint >= U+1F000, plus U+FE0F.
check_no_emoji() {
  local doc=$1 hit
  if ! printf 'a\n' | grep -qP 'a' 2>/dev/null; then
    bad no-emoji "grep -P is unavailable, cannot scan for emoji codepoints"
    return
  fi
  # `head` would mask grep's exit status, so test the captured text instead.
  hit=$(LC_ALL=C.UTF-8 grep -nP '[\x{1F000}-\x{10FFFF}\x{FE0F}]' "$doc" | head -n 1)
  if [ -n "$hit" ]; then
    bad no-emoji "emoji at line ${hit%%:*} — use [OK]/[FAIL] or yes/no"
  else
    ok "no-emoji"
  fi
}

validate() {
  local doc=$1
  if [ ! -f "$doc" ]; then
    bad file "not found: $doc"
    return
  fi
  check_frontmatter "$doc"
  check_sections "$doc"
  check_summary_length "$doc"
  check_total_length "$doc"
  check_no_emoji "$doc"
}

# Asserts $2 (the captured output) contains $1, else prints $3 and fails.
assert_contains() {
  case $2 in
    *"$1"*) return 0 ;;
    *) printf '[FAIL] self-test: %s\n%s\n' "$3" "$2"; return 1 ;;
  esac
}

self_test() {
  local tmp good bad_doc out rc
  tmp=$(mktemp -d) || return 1
  trap 'rm -rf "$tmp"' RETURN
  good="$tmp/good.md"
  bad_doc="$tmp/bad.md"

  {
    printf -- '---\nid: "2026-09-06-x"\ntitle: "X"\nslug: "x"\ndate: 2026-09-06\n---\n\n'
    printf '## Section 1: Executive Summary\n\nA short summary of the incident.\n\n'
    local n
    for n in 2 3 4 5 7 8 9; do
      printf '## Section %s: Body\n\n' "$n"
      # shellcheck disable=SC2034  # loop var is only a repeat counter
      for i in $(seq 250); do printf 'word '; done
      printf '\n\n'
    done
  } > "$good"

  # Missing section + an emoji. The glyph is generated, never written into
  # this file: the repo CI bans emoji in tracked text.
  { sed '/^## Section 3:/d' "$good"; printf '\U1F600\n'; } > "$bad_doc"

  out=$("$0" "$good"); rc=$?
  if [ "$rc" -ne 0 ]; then
    printf '[FAIL] self-test: a valid document was rejected\n%s\n' "$out"
    return 1
  fi
  assert_contains '[OK] total-length' "$out" "in-range total-length did not report [OK]" || return 1

  out=$("$0" "$bad_doc"); rc=$?
  if [ "$rc" -eq 0 ]; then
    printf '[FAIL] self-test: a document missing Section 3 was accepted\n%s\n' "$out"
    return 1
  fi
  assert_contains '[FAIL] sections' "$out" "missing Section 3 was not reported" || return 1
  assert_contains '[FAIL] no-emoji' "$out" "an emoji glyph was not detected" || return 1

  out=$("$0" "$tmp/nope.md"); rc=$?
  if [ "$rc" -eq 0 ]; then
    printf '[FAIL] self-test: a missing file was accepted\n'
    return 1
  fi

  printf '[OK] validate-rca.sh self-test\n'
}

case ${1:-} in
  --self-test) self_test; exit $? ;;
  -h|--help|help|'')
    sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
    exit 0 ;;
  *) validate "$1"; exit "$fail" ;;
esac
