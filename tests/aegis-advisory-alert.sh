#!/usr/bin/env bash
# ============================================================
#  AEGIS - advisory alert v2 (Slack webhook integration)
#  Slack: set SLACK_WEBHOOK_URL to an INCOMING WEBHOOK YOU
#  create in your Slack workspace (apps -> Incoming Webhooks).
#  Unset = local alert file only. Never an invented URL.
#  Run after aegis-advisory-check.sh (weekly) and on demand.
# ============================================================
set -uo pipefail
# DRY-RUN: print exactly what would be sent, send nothing.
# Usage: aegis-advisory-alert --dry-run   or   AEGIS_ALERT_DRYRUN=1 aegis-advisory-alert
DRYRUN=0
if [ "${1:-}" = "--dry-run" ] || [ "${AEGIS_ALERT_DRYRUN:-0}" = "1" ]; then DRYRUN=1; fi
BASE=${AEGIS_ALERT_BASE:-/var/lib/aegis-net}
LIBDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$LIBDIR/aegis-alert-lib.sh" ]; then
  source "$LIBDIR/aegis-alert-lib.sh"
else
  echo "FATAL: aegis-alert-lib.sh not beside this script" >&2
  exit 2
fi
LAST=$(cat "$BASE/status.last" 2>/dev/null || echo "unknown")
ALERTS=$BASE/alerts
mkdir -p "$ALERTS"
case "$LAST" in
  NEW-ADVISORIES:*)
    COUNT=$(aegis_alert_count "$LAST")
    STAMP=$(date -u '+%Y-%m-%d_%H%M')
    FILE="$ALERTS/alert-$STAMP.txt"
    REPORT=$(ls -t "$BASE/reports"/advisories-*.txt 2>/dev/null | head -1)
    {
      echo "AEGIS ADVISORY ALERT - $STAMP UTC"
      echo "Advisories above filter: $COUNT"
      echo "---"
      [ -n "$REPORT" ] && cat "$REPORT" || echo "(no report)"
    } > "$FILE"
    echo "ALERT WRITTEN: $FILE"
    if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
      SUMMARY=$(grep -E '^\|' "$REPORT" 2>/dev/null | sed 's/| */ - /g' | tr '\n' '\n' | head -15)
      PAYLOAD=$(aegis_alert_build_payload "$COUNT" "$SUMMARY")
      if [ "$DRYRUN" -eq 1 ]; then
        echo "DRY-RUN: no message sent. Hook URL masked below."
        echo "  would POST : $(aegis_alert_mask "$SLACK_WEBHOOK_URL")"
        echo "  payload    : $PAYLOAD"
      else
        if curl -fsSL -m 15 -H "Content-Type: application/json" -d "$PAYLOAD" "$SLACK_WEBHOOK_URL" >/dev/null 2>&1; then
          echo "SLACK: delivered"
        else
          echo "SLACK: FAILED (check SLACK_WEBHOOK_URL) - local alert kept"
        fi
      fi
    else
      echo "SLACK: not configured (set SLACK_WEBHOOK_URL to enable) - local alert kept"
    fi
    ;;
  *)
    echo "NO-ALERT (last status: $LAST)"
    ;;
esac
exit 0
