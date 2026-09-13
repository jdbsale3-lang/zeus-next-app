#!/usr/bin/env bash
# AEGIS alert lib - pure logic (no network, no side effects)
# Sourced by aegis-advisory-alert.sh and test-advisory-alert.sh.

# aegis_alert_count <statuslast> -> advisory count (0 when not NEW-ADVISORIES:n)
aegis_alert_count() {
  case "$1" in
    NEW-ADVISORIES:*) echo "${1#NEW-ADVISORIES:}" ;;
    *) echo 0 ;;
  esac
}

# aegis_alert_is_new <statuslast> -> 1 if a NEW-ADVISORIES alert is pending, else 0
aegis_alert_is_new() {
  case "$1" in
    NEW-ADVISORIES:*) echo 1 ;;
    *) echo 0 ;;
  esac
}

# aegis_alert_build_payload <count> <summary> -> Slack JSON payload
aegis_alert_build_payload() {
  python3 -c 'import json,sys
print(json.dumps({"text": "AEGIS advisory alert: "+sys.argv[1]+" new Wireshark advisory/-ies above filter.\n"+sys.argv[2]}))' "$1" "$2"
}

# aegis_alert_mask <url> -> masked display form (never prints the token)
aegis_alert_mask() {
  case "$1" in
    *hooks.slack.com/*) echo "https://hooks.slack.com/***MASKED***" ;;
    *) echo "***UNRECOGNISED-HOST-MASKED***" ;;
  esac
}
