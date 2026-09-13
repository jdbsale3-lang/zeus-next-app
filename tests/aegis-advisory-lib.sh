#!/usr/bin/env bash
# ============================================================
#  AEGIS advisory lib - pure logic (no network, no side effects)
#  Sourced by aegis-advisory-check.sh and test-advisory-check.sh
#  so unit tests exercise the SAME code the droplet runs.
# ============================================================

# aegis_severity_bucket <cvss_score> -> echo CRITICAL|HIGH|MODERATE|LOW|NONE
aegis_severity_bucket() {
  local s="$1"
  awk "BEGIN{ s=$s;
    if (s>=9.0) print \"CRITICAL\";
    else if (s>=7.0) print \"HIGH\";
    else if (s>=4.0) print \"MODERATE\";
    else if (s>0) print \"LOW\";
    else print \"NONE\"; }"
}

# aegis_rank_keep <severity> <min> -> echo 1 (keep) or 0 (filter)
# N/A and NONE score 0 -> filtered (conservative: never alert unscored)
aegis_rank_keep() {
  local sev="$1" mn="$2"
  case "$sev" in
    CRITICAL) [ "$mn" != "CRITICAL" ] && echo 1 || echo 0 ;;
    HIGH)     case "$mn" in CRITICAL) echo 0;; *) echo 1;; esac ;;
    MODERATE) case "$mn" in CRITICAL|HIGH) echo 0;; *) echo 1;; esac ;;
    LOW)      case "$mn" in CRITICAL|HIGH|MODERATE) echo 0;; *) echo 1;; esac ;;
    *)        echo 0 ;;
  esac
}

# aegis_extract_ids <htmlfile> -> sorted unique wnpa-sec-2026 ids
aegis_extract_ids() {
  grep -oE 'wnpa-sec-2026-[0-9]+' "$1" | sort -u
}

# aegis_new_ids <baseline> <today> -> ids in today not in baseline
aegis_new_ids() {
  comm -13 <(sort "$1") <(sort "$2")
}
