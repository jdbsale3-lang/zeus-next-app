#!/usr/bin/env bash
# ZEUS VERIFY for Linux/macOS v1 - build artifact integrity check
# Usage:  ./zeus-verify.sh            (remote check against live site)
#         ./zeus-verify.sh <file|url> (check any artifact)
# Exits 0 = PASS, 1 = FAIL. Run on the droplet or any Linux/macOS box.
set -u
EXPECT="1e3496aa1a4b0364da7f225158265491dbbcfeb539746e6ed15e7f64c0982f41"
MIN=600000
SRC="${1:-https://zeusaiintelligence.com}"
FAIL=0
tmp=""
if [[ "$SRC" =~ ^https?:// ]]; then
  tmp="$(mktemp)"
  curl -sL -m 30 -o "$tmp" "$SRC" || { echo "FATAL: download failed: $SRC"; exit 1; }
  F="$tmp"
else
  F="$SRC"
fi
SIZE=$(wc -c < "$F")
echo "== ZEUS VERIFY (Linux/macOS) =="
echo "[1] size: $SIZE bytes"
if [ "$SIZE" -lt "$MIN" ]; then echo "    FAIL - too small"; FAIL=1; else echo "    ok"; fi
echo "[2] markers:"
for m in zeusPaymentCheck zeusReminderSet "AEGIS BUILT-IN" zeusFilingCheck zeusDementiaPanel zeusSwarmMonitor; do
  if grep -q "$m" "$F"; then echo "    $m: ok"; else echo "    $m: FAIL"; FAIL=1; fi
done
echo "[3] sha256:"
H=$(sha256sum "$F" | cut -d' ' -f1)
echo "    $H"
if [ "$H" != "$EXPECT" ]; then echo "    FAIL - mismatch, expected $EXPECT"; FAIL=1; else echo "    MATCH - sealed standard"; fi
[ -n "$tmp" ] && rm -f "$tmp"
echo "== RESULT: $([ $FAIL -ne 0 ] && echo FAIL || echo PASS) =="
exit $FAIL
