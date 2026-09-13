#!/usr/bin/env bash
# ============================================================
#  AEGIS Slack alert INTEGRATION test (end-to-end, local mock)
#  Executes the REAL aegis-advisory-alert.sh against a local
#  mock HTTP server that captures the POST - no real Slack,
#  no external URLs. Then tests the failure path (dead port).
#  Run: bash integration-advisory-alert.sh
# ============================================================
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# make the suite self-sufficient: the alert script needs its lib beside it
if [ ! -f "$HERE/aegis-alert-lib.sh" ] && [ -f "$HERE/aegis-alert-lib.sh.txt" ]; then
  cp "$HERE/aegis-alert-lib.sh.txt" "$HERE/aegis-alert-lib.sh"
fi
[ -x "$HERE/aegis-advisory-alert.sh" ] || chmod +x "$HERE/aegis-advisory-alert.sh"
PASS=0; FAIL=0
t() { if [ "$2" = "$3" ]; then PASS=$((PASS+1)); echo "  [PASS] $1"; else FAIL=$((FAIL+1)); echo "  [FAIL] $1 (expected '$2' got '$3')"; fi; }

echo "== integration: Slack alert (mock webhook POST) =="
SB=$(mktemp -d)
mkdir -p "$SB/alerts" "$SB/reports"
echo "NEW-ADVISORIES:2" > "$SB/status.last"
printf '| wnpa-sec-2026-91 | HIGH | CVSS 8.1 | CVE-2026-76917 | fixed: 4.6.8\n| wnpa-sec-2026-87 | CRITICAL | CVSS 9.8 | CVE-2026-77777 | fixed: 4.6.8\n' > "$SB/reports/advisories-2026-09-13.txt"

# start mock receiver on an ephemeral port
PORT=$(( 20000 + RANDOM % 20000 ))
LOG="$SB/http.log"
python3 - "$PORT" "$LOG" <<'MOCK' &
import http.server, socketserver, sys
port, log = int(sys.argv[1]), sys.argv[2]
class H(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        n = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(n).decode("utf-8", "ignore")
        with open(log, "a") as f: f.write(body + "\n")
        self.send_response(200); self.end_headers(); self.wfile.write(b"ok")
    def log_message(self, *a): pass
with socketserver.TCPServer(("127.0.0.1", port), H) as srv:
    srv.timeout = 20
    try:
        while True: srv.handle_request()
    except Exception: pass
MOCK
MOCK_PID=$!
sleep 1

t "mock server up" "yes" "$(curl -s -o /dev/null --max-time 3 "http://127.0.0.1:$PORT/" && echo yes || echo no)"

OUT=$(AEGIS_ALERT_BASE="$SB" SLACK_WEBHOOK_URL="http://127.0.0.1:$PORT/hook" bash "$HERE/aegis-advisory-alert.sh" 2>&1)
echo "$OUT" | grep -q "SLACK: delivered" && t "webhook delivered" "ok" "ok" || t "webhook delivered" "ok" "no"
t "alert file written" 1 "$(ls "$SB/alerts/"*.txt 2>/dev/null | wc -l | tr -d ' ')"
sleep 1
RECV=$(cat "$LOG" 2>/dev/null || echo "")
echo "$RECV" | grep -q "wnpa-sec-2026-91" && t "payload contains advisory line" "ok" "ok" || t "payload contains advisory line" "ok" "no"
echo "$RECV" | python3 -c 'import json,sys
d=json.loads(sys.stdin.read().splitlines()[0]); assert "WNPA" not in d["text"]' 2>/dev/null   && t "payload valid JSON" "ok" "ok" || t "payload valid JSON" "ok" "no"

kill $MOCK_PID 2>/dev/null; wait $MOCK_PID 2>/dev/null

# failure path: dead port
echo "NEW-ADVISORIES:1" > "$SB/status.last"
OUT2=$(AEGIS_ALERT_BASE="$SB" SLACK_WEBHOOK_URL="http://127.0.0.1:1/hook" timeout 30 bash "$HERE/aegis-advisory-alert.sh" 2>&1)
echo "$OUT2" | grep -q "SLACK: FAILED" && t "dead webhook -> FAILED reported" "ok" "ok" || t "dead webhook -> FAILED reported" "ok" "no"
grep -q "above filter: 1" "$SB"/alerts/*.txt 2>/dev/null && t "local alert kept on failure" "ok" "ok" || t "local alert kept on failure" "ok" "no"
rm -rf "$SB"

echo ""
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
