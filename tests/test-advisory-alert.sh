#!/usr/bin/env bash
# AEGIS Slack alert unit tests - offline. Tests the SHARED lib
# aegis-alert-lib.sh AND the script's file/state behaviour via a
# sandbox BASE (AEGIS_ALERT_BASE) with DRY-RUN forced on.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/aegis-alert-lib.sh"
PASS=0; FAIL=0
t() { if [ "$2" = "$3" ]; then PASS=$((PASS+1)); echo "  [PASS] $1"; else FAIL=$((FAIL+1)); echo "  [FAIL] $1 (expected '$2' got '$3')"; fi; }

echo "== status parsing =="
t "count NEW:2"     2 "$(aegis_alert_count 'NEW-ADVISORIES:2')"
t "count NEW:7"     7 "$(aegis_alert_count 'NEW-ADVISORIES:7')"
t "count NO-NEW"    0 "$(aegis_alert_count 'NO-NEW')"
t "count FETCH-FAIL" 0 "$(aegis_alert_count 'FETCH-FAILED')"
t "count empty"     0 "$(aegis_alert_count '')"
t "is_new NEW:2"    1 "$(aegis_alert_is_new 'NEW-ADVISORIES:2')"
t "is_new NO-NEW"   0 "$(aegis_alert_is_new 'NO-NEW')"

echo "== payload builder =="
P=$(aegis_alert_build_payload "2" "- wnpa-sec-2026-91 - HIGH")
echo "$P" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert "2 new" in d["text"]' && t "payload valid JSON + count" "ok" "ok"
echo "$P" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert "wnpa-sec-2026-91" in d["text"]' && t "payload includes summary" "ok" "ok"

echo "== URL masking =="
t "slack hook masked" "https://hooks.slack.com/***MASKED***" "$(aegis_alert_mask 'https://hooks.slack.com/services/T000/B000/SECRETTOKEN')"
t "unknown host masked" "***UNRECOGNISED-HOST-MASKED***" "$(aegis_alert_mask 'https://evil.example.com/hook')"

echo "== script behaviour (sandbox BASE, DRY-RUN=1) =="
SB=$(mktemp -d)
mkdir -p "$SB/alerts" "$SB/reports"
echo "NEW-ADVISORIES:1" > "$SB/status.last"
printf '| wnpa-sec-2026-88 | HIGH | CVSS 8.1 | CVE-2026-77777 | fixed: 4.6.8\n' > "$SB/reports/advisories-2026-09-13.txt"
OUT=$(AEGIS_ALERT_BASE="$SB" AEGIS_ALERT_DRYRUN=1 bash "$HERE/aegis-advisory-alert.sh" 2>&1)
t "script exit on dry-run alert" 0 "$?"
echo "$OUT" | grep -q 'DRY-RUN' && t "dry-run marker printed" "ok" "ok"
echo "$OUT" | grep -q 'MASKED' && t "hook url masked" "ok" "ok"
t "local alert file written" 1 "$(ls "$SB/alerts/"*.txt 2>/dev/null | wc -l | tr -d ' ')"
echo "NO-NEW" > "$SB/status.last"
OUT2=$(AEGIS_ALERT_BASE="$SB" AEGIS_ALERT_DRYRUN=1 bash "$HERE/aegis-advisory-alert.sh" 2>&1)
echo "$OUT2" | grep -q 'NO-ALERT' && t "no-alert path" "ok" "ok"
rm -rf "$SB"

echo ""
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
