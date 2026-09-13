#!/usr/bin/env bash
# AEGIS full advisory pipeline - INTEGRATION test (live)
# Runs the REAL aegis-advisory-check.sh in a sandbox BASE against
# live wireshark.org + cveawg.mitre.org. Bounded: 1 page fetch +
# 1 advisory page + 1 CVE lookup. Skips gracefully when offline.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0; FAIL=0
t() { if [ "$2" = "$3" ]; then PASS=$((PASS+1)); echo "  [PASS] $1"; else FAIL=$((FAIL+1)); echo "  [FAIL] $1 (expected '$2' got '$3')"; fi; }

echo "== integration: full advisory pipeline (live) =="
if ! curl -fsSL -m 25 "https://www.wireshark.org/security/" -o /tmp/it-sec.html 2>/dev/null; then
  echo "  [SKIP] network unavailable - integration test skipped (exit 77)"
  exit 77
fi

# 1) extraction on the REAL page
source "$HERE/aegis-advisory-lib.sh"
IDS=$(aegis_extract_ids /tmp/it-sec.html)
N=$(printf '%s\n' "$IDS" | grep -c .)
t "live page advisory count > 80" "yes" "$([ "$N" -gt 80 ] && echo yes || echo no)"

# 2) run the REAL check script twice in a sandbox BASE
SB=$(mktemp -d)
cp /tmp/it-sec.html "$SB/sec.html"
R1=$(AEGIS_ADVISORY_BASE="$SB" bash "$HERE/aegis-advisory-check.sh" 2>&1)
t "first run: baseline set" "yes" "$(echo "$R1" | grep -qi 'first run' && echo yes || echo no)"
t "first run: baseline file" 1 "$([ -f "$SB/advisory-baseline.txt" ] && echo 1 || echo 0)"
t "first run: status.last" "yes" "$(grep -q 'FIRST-RUN' "$SB/status.last" && echo yes || echo no)"
R2=$(AEGIS_ADVISORY_BASE="$SB" bash "$HERE/aegis-advisory-check.sh" 2>&1)
t "second run: stable (no NEW)" "yes" "$(echo "$R2" | grep -q 'no new advisories' && echo yes || echo no)"

# 3) advisory page -> CVE -> CVSS (live chain, bounded to 1)
PID=$(echo "$IDS" | tail -1)
PAGE=$(curl -fsSL -m 25 "https://www.wireshark.org/security/$PID.html" 2>/dev/null || echo "")
CVE=$(echo "$PAGE" | grep -oE 'CVE-[0-9]{4}-[0-9]+' | sort -u | head -1)
t "advisory page has CVE" "yes" "$([ -n "$CVE" ] && echo yes || echo no)"
FIXED=$(echo "$PAGE" | python3 -c '
import re, sys, html
t = re.sub(r"<[^>]+>", " ", sys.stdin.read())
t = html.unescape(re.sub(r"\s+", " ", t))
i = t.find("Fixed versions")
print(t[i+15:i+45].strip() if i >= 0 else "")')
t "advisory page has fixed versions" "yes" "$([ -n "$FIXED" ] && echo yes || echo no)"
if [ -n "$CVE" ]; then
  SCORE=$(curl -fsSL -m 25 "https://cveawg.mitre.org/api/cve/$CVE" 2>/dev/null | python3 -c '
import json,sys
try:
    d=json.load(sys.stdin)
    print(d["containers"]["cna"]["metrics"][0].get("cvssV3_1",{}).get("baseScore",0.0))
except Exception:
    print(0.0)' 2>/dev/null || echo 0.0)
  SBUCKET=$(aegis_severity_bucket "$SCORE")
  case "$SBUCKET" in CRITICAL|HIGH|MODERATE|LOW) VALID=yes;; *) VALID=no;; esac
  t "CVSS 0..10" "yes" "$(python3 -c "print('yes' if 0<=float('$SCORE')<=10 else 'no')")"
  t "bucket valid" "yes" "$VALID"
fi
rm -rf "$SB"
echo ""
echo "RESULT: $PASS passed, $FAIL failed (live)"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
