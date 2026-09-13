#!/usr/bin/env bash
# ============================================================
#  AEGIS - weekly Wireshark advisory check v2 (severity-aware)
#  Pipeline (all sources VERIFIED live 13 Sep 2026):
#    wireshark.org/security/   -> new wnpa-sec ids vs baseline
#    wireshark advisory page   -> CVE reference + fixed versions
#    cveawg.mitre.org/api/cve  -> CVSS v3.1 baseScore/severity
#  Filter: only NEW advisories are fetched + scored. Each new
#  advisory costs one advisory-page fetch + one CVE fetch.
#  Config: AEGIS_ADV_SEVERITY_MIN (default HIGH) - CRITICAL/HIGH/
#  MODERATE/LOW all accepted, lowercase-insensitive.
# ============================================================
set -euo pipefail
BASE=${AEGIS_ADVISORY_BASE:-/var/lib/aegis-net}
URL=https://www.wireshark.org/security/
BASELINE=$BASE/advisory-baseline.txt
TODAY=$BASE/advisories-today.txt
REPORT=$BASE/reports/advisories-$(date +%Y-%m-%d).txt
MIN=${AEGIS_ADV_SEVERITY_MIN:-HIGH}
mkdir -p "$BASE/reports"
# load shared pure logic (lib next to this script)
LIBDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$LIBDIR/aegis-advisory-lib.sh" ]; then
  source "$LIBDIR/aegis-advisory-lib.sh"
else
  echo "FATAL: aegis-advisory-lib.sh not beside this script" >&2
  exit 2
fi
echo "== AEGIS advisory check v2 (min severity: $MIN): $(date -u '+%Y-%m-%d %H:%M UTC') =="

tmp=$(mktemp)
if ! curl -fsSL -m 30 -o "$tmp" "$URL"; then
  echo "FETCH-FAILED" > "$REPORT"; echo "ADVISORY-CHECK-FAILED" > "$BASE/status.last"
  rm -f "$tmp"; exit 1
fi
grep -oE 'wnpa-sec-2026-[0-9]+' "$tmp" | sort -u > "$TODAY"; rm -f "$tmp"
COUNT=$(wc -l < "$TODAY")
[ ! -f "$BASELINE" ] && { cp "$TODAY" "$BASELINE"; echo "FIRST-RUN ($COUNT)" > "$BASE/status.last"; echo "FIRST-RUN baseline set ($COUNT)" > "$REPORT"; echo "== first run - baseline set =="; exit 0; }

NEW=$(comm -13 <(sort "$BASELINE") "$TODAY")
NEWCOUNT=$(printf '%s\n' "$NEW" | grep -c . || true); [ "$NEWCOUNT" -eq 0 ] && NEWCOUNT=0

if [ "$NEWCOUNT" -eq 0 ]; then
  { echo "No new advisories this week."; echo "Total on page: $COUNT"; } > "$REPORT"
  echo "NO-NEW" > "$BASE/status.last"
  echo "== no new advisories (total $COUNT) =="
  cp "$TODAY" "$BASELINE"
  exit 0
fi

# score each new advisory via its page -> CVE -> MITRE CVSS
{
  echo "NEW ADVISORIES THIS WEEK: $NEWCOUNT"
  echo "Severity filter: >= $MIN"
  echo "---"
  HIGHEST=0.0; HIGHEST_ID=""
  for ID in $NEW; do
    PAGE=$(mktemp)
    if curl -fsSL -m 20 "https://www.wireshark.org/security/$ID.html" -o "$PAGE" 2>/dev/null; then
      CVE=$(grep -oE 'CVE-[0-9]{4}-[0-9]+' "$PAGE" | sort -u | head -1)
      CVE=${CVE:-N/A}
      FIXED=$(python3 - "$PAGE" <<'STRIP'
import re, sys, html
t = re.sub(r'<[^>]+>', ' ', open(sys.argv[1], encoding='utf-8', errors='ignore').read())
t = html.unescape(re.sub(r'\s+', ' ', t))
i = t.find('Fixed versions')
print(t[i+15:i+45].strip() if i >= 0 else '?')
STRIP
)
    else
      CVE="fetch-failed"; FIXED="?"
    fi
    rm -f "$PAGE"
    SCORE=0.0; SEV="N/A"; LINE=""
    if [ "$CVE" != "N/A" ] && [ "$CVE" != "fetch-failed" ]; then
      M=$(mktemp)
      if curl -fsSL -m 20 "https://cveawg.mitre.org/api/cve/$CVE" -o "$M" 2>/dev/null; then
        SCORE=$(python3 - "$M" <<'PY'
import json,sys
try:
    d=json.load(open(sys.argv[1]))
    m=d['containers']['cna']['metrics'][0]
    print(m.get('cvssV3_1',{}).get('baseScore',0.0))
except Exception:
    print(0.0)
PY
)
        SEV=$(aegis_severity_bucket "$SCORE")
      fi
      rm -f "$M"
    fi
    [ "$SCORE" = "0.0" ] && SEV="N/A"
    # severity-rank filter (lib): keep if rank(SEV) >= rank(MIN); unscored filtered
    KEPT=$(aegis_rank_keep "$SEV" "$MIN")
    [ "$KEPT" = "0" ] && SEV="filtered"
    echo "$ID | $SEV | CVSS $SCORE | $CVE | fixed: $FIXED"
    if [ "$SEV" != "filtered" ] && [ "$SEV" != "N/A" ]; then
      awk "BEGIN{exit !($SCORE>$HIGHEST)}" && { HIGHEST=$SCORE; HIGHEST_ID=$ID; }
    fi
  done
  echo "---"
  echo "Highest: $HIGHEST ($HIGHEST_ID)"
} > "$REPORT"

ALERT_COUNT=$(grep -cE '\| (CRITICAL|HIGH|MODERATE|LOW) \|' "$REPORT" || true)
[ "$ALERT_COUNT" = "0" ] && ALERT_COUNT=0
if [ "$ALERT_COUNT" -gt 0 ]; then
  echo "NEW-ADVISORIES:$ALERT_COUNT" > "$BASE/status.last"
  echo "SEV-MIN:$MIN HIGEST:$HIGHEST_ID:$HIGHEST" >> "$BASE/status.last"
else
  echo "NO-NEW-ABOVE-FILTER" > "$BASE/status.last"
fi
cp "$TODAY" "$BASELINE"
echo "== done: $NEWCOUNT new, $ALERT_COUNT above $MIN filter =="
exit 0
