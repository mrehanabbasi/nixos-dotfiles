---
description: Run system diagnostics for troubleshooting
---

Run system diagnostics using the diagnose skill to troubleshoot:
- Network connectivity issues
- Boot problems
- Service failures
- Hardware detection issues

This runs common diagnostic commands (journalctl, systemctl, nmcli, dmesg, etc.) in an isolated context to keep verbose output from cluttering the main conversation.

All diagnostic commands are read-only and pre-approved in settings.local.json.
