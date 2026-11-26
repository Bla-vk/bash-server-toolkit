#!/usr/bin/env bash
# Summarises failed SSH logins in an auth log.
# Usage: ./log-summary.sh <logfile> [top_n]
set -euo pipefail

usage() {
  echo "Usage: $0 <logfile> [top_n]" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
LOG="$1"
TOP="${2:-5}"
[[ -r "$LOG" ]] || { echo "Cannot read: $LOG" >&2; exit 2; }

total="$(grep -c "Failed password" "$LOG" || true)"
echo "Failed SSH logins: $total"

echo
echo "Top $TOP source IPs:"
(grep "Failed password" "$LOG" || true) \
  | awk '{for (i = 1; i <= NF; i++) if ($i == "from") print $(i + 1)}' \
  | sort | uniq -c | sort -rn | head -n "$TOP"

echo
echo "Top $TOP usernames tried:"
(grep "Failed password" "$LOG" || true) \
  | sed -E 's/.*Failed password for (invalid user )?([^ ]+) from.*/\2/' \
  | sort | uniq -c | sort -rn | head -n "$TOP"