#!/usr/bin/env bash
# Basic hardening checks for the machine this script runs on.
# Usage: ./hardening-check.sh [sshd_config_file]
#   With a file, the two SSH checks read that file. Without one, they are skipped.
#   Run with sudo to also check for accounts with empty passwords.
set -euo pipefail

SSH_CONFIG="${1:-}"
failed=0

pass() { echo "PASS  $1"; }
info() { echo "INFO  $1"; }
fail() { echo "FAIL  $1"; failed=$((failed + 1)); }

config_value() {
  local file="$1" key="$2"
  awk -v k="$key" 'tolower($1) == tolower(k) {print tolower($2); exit}' "$file"
}

check_ssh_setting() {
  local label="$1" key="$2" want="$3" value
  value="$(config_value "$SSH_CONFIG" "$key")"
  if [[ "$value" == "$want" ]]; then
    pass "$label"
  else
    fail "$label (found: ${value:-unset})"
  fi
}

ssh_checks() {
  if [[ -z "$SSH_CONFIG" ]]; then
    info "SSH checks skipped (give a config file: $0 path/to/sshd_config)"
    return
  fi
  if [[ ! -r "$SSH_CONFIG" ]]; then
    echo "ERROR cannot read $SSH_CONFIG" >&2
    exit 2
  fi
  check_ssh_setting "SSH root login disabled" PermitRootLogin no
  check_ssh_setting "SSH password login disabled" PasswordAuthentication no
}

port_checks() {
  info "Listening ports:"
  if ! command -v ss > /dev/null 2>&1; then
    info "ss not available"
    return
  fi
  ss -tuln | awk 'NR > 1 {printf "      %s %s\n", $1, $5}'
}

password_checks() {
  if [[ $EUID -ne 0 ]]; then
    info "Run with sudo to check for accounts with empty passwords"
    return
  fi
  local empty
  empty="$(awk -F: '$2 == "" {print $1}' /etc/shadow)"
  if [[ -z "$empty" ]]; then
    pass "No accounts with empty passwords"
  else
    fail "Accounts with empty passwords: $empty"
  fi
}

file_checks() {
  local writable
  writable="$(find /etc -xdev -type f -perm -0002 2> /dev/null || true)"
  if [[ -z "$writable" ]]; then
    pass "No world-writable files in /etc"
  else
    fail "World-writable files in /etc:"
    while IFS= read -r line; do
      echo "        $line"
    done <<< "$writable"
  fi
}

main() {
  ssh_checks
  port_checks
  password_checks
  file_checks
  echo
  echo "Failed checks: $failed"
  (( failed == 0 ))
}

main