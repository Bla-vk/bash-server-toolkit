#!/usr/bin/env bash
# Prints a quich health report for this machine
# Usage: ./health-report.sh [disk_warn_percent]
set -euo pipefail

DISK_THRESHOLD="${1:-80}"

section() { printf '\n== %s ==\n' "$1";}

report_system() {
    section "System Information"
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
}

report_disk() {
  section "Disk usage (warn at ${DISK_THRESHOLD}%)"
  df -h --output=target,pcent -x tmpfs -x devtmpfs | tail -n +2 | while read -r mount pct; do
    value="${pct%\%}"
    if (( value >= DISK_THRESHOLD )); then
      echo "WARN  $mount at $pct"
    else
      echo "ok    $mount at $pct"
    fi
  done
}

report_memory() {
  section "Memory"
  free -h
  free | awk '/^Mem:/ {printf "Used: %.0f%%\n", $3 / $2 * 100}'
}

report_failed_services() {
  section "Failed services"
  if ! command -v systemctl > /dev/null 2>&1; then
    echo "systemctl not available"
    return
  fi
  local failed
  failed="$(systemctl --failed --no-legend --plain || true)"
  if [[ -z "$failed" ]]; then
    echo "none"
  else
    echo "$failed"
  fi
}

report_top_processes() {
  section "Top 5 processes by memory"
  ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n 6
}

main() {
  report_system
  report_disk
  report_memory
  report_failed_services
  report_top_processes
}

main