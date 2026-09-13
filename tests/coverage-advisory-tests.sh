#!/usr/bin/env bash
# ============================================================
#  AEGIS/ZEUS test coverage report v1
#  Generates tests/coverage-report.txt (+ .html) after running
#  all suites. Coverage = function-level: which lib functions
#  each suite exercises (grep-proven, not line coverage - the
#  honest scope of shell testing).
# ============================================================
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT="$HERE/coverage-report.txt"
HTML="$HERE/coverage-report.html"
: > "$REPORT"

echo "== ZEUS/AEGIS TEST COVERAGE REPORT ==" | tee -a "$REPORT"
echo "Generated: $(date -u '+%Y-%m-%d %H:%M UTC')" | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

# --- run each suite, capture the RESULT line ---
run_suite() {
  local name="$1" script="$2" base="$3"
  echo "--- $name ---" | tee -a "$REPORT"
  local out
  out=$(cd "$base" && bash "$script" 2>&1)
  local rc=$?
  echo "$out" | grep -E "RESULT|SKIP" | tee -a "$REPORT"
  echo "exit: $rc" | tee -a "$REPORT"
  echo "$out"
  return $rc
}

ADV_DIR="$HERE"; ALE_DIR="$HERE"
[ -f "$HERE/test-advisory-check.sh" ] && ADV_DIR="$HERE" || ADV_DIR="$(dirname "$(find / -name test-advisory-check.sh 2>/dev/null | head -1)")"
[ -f "$HERE/test-advisory-alert.sh" ] && ALE_DIR="$HERE" || ALE_DIR="${ADV_DIR}"
OUT1=$(run_suite "advisory unit" "$ADV_DIR/test-advisory-check.sh" "$ADV_DIR")
OUT2=$(run_suite "advisory integration" "$ADV_DIR/integration-advisory-check.sh" "$ADV_DIR")
OUT3=$(run_suite "alert unit" "$ALE_DIR/test-advisory-alert.sh" "$ALE_DIR")

parse_result() { echo "$1" | grep -oE "[0-9]+ passed, [0-9]+ failed" | tail -1; }
P1=$(parse_result "$OUT1") ; P2=$(parse_result "$OUT2"); P3=$(parse_result "$OUT3")

echo "== SUITE RESULTS ==" | tee -a "$REPORT"
echo "advisory unit      : ${P1:-not-run}" | tee -a "$REPORT"
echo "advisory integration: ${P2:-not-run}" | tee -a "$REPORT"
echo "alert unit         : ${P3:-not-run}" | tee -a "$REPORT"

echo "" | tee -a "$REPORT"
echo "== FUNCTION COVERAGE (lib functions referenced by suites) ==" | tee -a "$REPORT"
ALL_REF="$(cat "$HERE"/*.sh "$ADV_DIR"/*.sh "$ALE_DIR"/*.sh 2>/dev/null)"
for fn in aegis_severity_bucket aegis_rank_keep aegis_extract_ids aegis_new_ids aegis_alert_count aegis_alert_is_new aegis_alert_build_payload aegis_alert_mask; do
  N=$(echo "$ALL_REF" | grep -c "$fn")
  [ "$N" -gt 0 ] && ST="covered" || ST="NOT covered"
  printf "  %-28s %-11s (%d refs)\n" "$fn" "$ST" "$N" | tee -a "$REPORT"
done

echo "" | tee -a "$REPORT"
echo "Honest scope: function-level coverage proven by grep across the suites; shell line coverage is not measured." | tee -a "$REPORT"

# HTML rendering
python3 - "$REPORT" > "$HTML" <<'HTMLPY'
import sys, html
lines = open(sys.argv[1]).read().splitlines()
body = "".join("<li>%s</li>" % html.escape(l) for l in lines)
print("<!DOCTYPE html><html><head><meta charset='utf-8'><title>ZEUS test coverage</title>"
      "<style>body{font:13px/1.6 Segoe UI,Arial,sans-serif;color:#14213d;background:#fff;max-width:760px;margin:0 auto;padding:24px}"
      "h1{font-size:19px;border-bottom:2px solid #0e4a8f;padding-bottom:8px}li{list-style:none;white-space:pre;font-family:Consolas,monospace;font-size:12px}</style></head>"
      "<body><h1>ZEUS/AEGIS Test Coverage Report</h1><ul>%s</ul></body></html>" % body)
HTMLPY
echo "report written: $REPORT (+ $HTML)" | tee -a "$REPORT"
echo "All IP belongs to Darren Birch - ZEUSTRUSTAEGISSECURITY LTD." | tee -a "$REPORT"
exit 0
