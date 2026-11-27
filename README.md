[![ShellCheck](https://github.com/Bla-vk/bash-server-toolkit/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/Bla-vk/bash-server-toolkit/actions/workflows/shellcheck.yml)

# Bash Server Toolkit

Four Bash scripts for checking and maintaining a Linux server: [your own one-sentence summary].

## Scripts

| Script               | What it does                                                 | Example                                              |
| -------------------- | ------------------------------------------------------------ | ---------------------------------------------------- |
| `health-report.sh`   | Host, disk, memory, failed services, top processes           | `./scripts/health-report.sh 80`                      |
| `log-summary.sh`     | Counts failed SSH logins by IP and username                  | `./scripts/log-summary.sh samples/auth-sample.txt 3` |
| `backup.sh`          | Timestamped tar.gz backup with rotation                      | `./scripts/backup.sh ~/data ~/backups 5`             |
| `hardening-check.sh` | Read-only checks for SSH, ports, passwords, file permissions | `sudo ./scripts/hardening-check.sh`                  |

## Requirements

Bash 4+, GNU coreutils, `systemd` (for the service check), `ss`.

## Sample output

[screenshots: health report, log summary, backup rotation and restore, hardening check]

## What I learned / problems I hit

- [e.g. why `set -e` and `grep` with no matches caused an early exit, and the `|| true` fix]
- [add your real problems]

## Limits

- Tested on Ubuntu only.
- `hardening-check.sh` is a basic check, not a full audit (not a CIS benchmark).
- The SSH setting lookup is simplified; `sshd -T` is the authoritative source.
- `log-summary.sh` expects the OpenSSH "Failed password" format.
