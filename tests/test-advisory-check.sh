#!/usr/bin/env bash
# AEGIS advisory-check unit tests - run offline, tests the SHARED lib.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/aegis-advisory-lib.sh"
PASS=0; FAIL=0
t() { if [ "$2" = "$3" ]; then PASS=$((PASS+1)); echo "  [PASS] $1"; else FAIL=$((FAIL+1)); echo "  [FAIL] $1 (expected '$2' got '$3')"; fi; }
echo "== severity bucketing =="
t "bucket 9.9"   "CRITICAL" "$(aegis_severity_bucket 9.9)"
t "bucket 9.0"   "CRITICAL" "$(aegis_severity_bucket 9.0)"
t "bucket 8.1"   "HIGH"     "$(aegis_severity_bucket 8.1)"
t "bucket 7.0"   "HIGH"     "$(aegis_severity_bucket 7.0)"
t "bucket 6.9"   "MODERATE" "$(aegis_severity_bucket 6.9)"
t "bucket 4.0"   "MODERATE" "$(aegis_severity_bucket 4.0)"
t "bucket 3.9"   "LOW"      "$(aegis_severity_bucket 3.9)"
t "bucket 0.1"   "LOW"      "$(aegis_severity_bucket 0.1)"
t "bucket 0.0"   "NONE"     "$(aegis_severity_bucket 0.0)"
echo "== rank filter =="
t "CRITICAL vs HIGH keep"   1 "$(aegis_rank_keep CRITICAL HIGH)"
t "CRITICAL vs MOD keep"    1 "$(aegis_rank_keep CRITICAL MODERATE)"
t "HIGH vs HIGH keep"       1 "$(aegis_rank_keep HIGH HIGH)"
t "HIGH vs CRITICAL filter" 0 "$(aegis_rank_keep HIGH CRITICAL)"
t "MODERATE vs HIGH filter" 0 "$(aegis_rank_keep MODERATE HIGH)"
t "MODERATE vs MOD keep"    1 "$(aegis_rank_keep MODERATE MODERATE)"
t "LOW vs MODERATE filter"  0 "$(aegis_rank_keep LOW MODERATE)"
t "N/A vs LOW filter"       0 "$(aegis_rank_keep N/A LOW)"
t "NONE vs HIGH filter"     0 "$(aegis_rank_keep NONE HIGH)"
echo "== id extraction (fixture) =="
FIX=$(mktemp)
printf '%s\n' '<a href="/security/wnpa-sec-2026-91.html">91</a>' '<a href="/security/wnpa-sec-2026-87.html">87</a>' '<a href="/security/wnpa-sec-2026-91.html">dup</a>' > "$FIX"
OUT=$(aegis_extract_ids "$FIX")
t "extract unique count" 2 "$(printf '%s\n' "$OUT" | grep -c .)"
t "extract contains 87"  "wnpa-sec-2026-87" "$(echo "$OUT" | grep 87)"
t "extract contains 91"  "wnpa-sec-2026-91" "$(echo "$OUT" | grep 91)"
rm -f "$FIX"
echo "== baseline diff =="
B=$(mktemp); T=$(mktemp)
printf 'wnpa-sec-2026-90\nwnpa-sec-2026-91\n' > "$B"
printf 'wnpa-sec-2026-90\nwnpa-sec-2026-91\nwnpa-sec-2026-92\n' > "$T"
t "new ids found" "wnpa-sec-2026-92" "$(aegis_new_ids "$B" "$T")"
# no-new case: baseline must be updated to today's full list first
printf 'wnpa-sec-2026-90\nwnpa-sec-2026-91\nwnpa-sec-2026-92\n' > "$B"
t "no new ids (empty)" "" "$(aegis_new_ids "$B" "$T")"
rm -f "$B" "$T"
echo ""
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
