---
description: Run system diagnostics for troubleshooting
agent: nixos-builder
# model: default
---

Run system diagnostics using the diagnose skill to troubleshoot:
- Network connectivity issues
- Boot problems
- Service failures
- Hardware detection issues

This runs common diagnostic commands (journalctl, systemctl, nmcli, dmesg, etc.) to help identify system issues.

All diagnostic commands are read-only.
