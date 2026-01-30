---
name: diagnose
description: Run system diagnostics for network, boot, and hardware issues
license: MIT
compatibility: opencode
---

# System Diagnostics

I run common diagnostic commands to troubleshoot network, boot, and hardware issues without cluttering your main conversation context.

## What I do

1. **Network diagnostics**
   - Check network manager status: `nmcli`
   - Show device connections: `nmcli device`
   - Display connection profiles: `nmcli connection`
   - Show IP addresses: `ip addr`
   - Check wireless status: `iwctl` commands

2. **System logs**
   - Recent system logs: `journalctl -n 50`
   - Service-specific logs: `systemctl status <service>`
   - Kernel messages: `dmesg`
   - Boot issues analysis

3. **Hardware status**
   - Loaded kernel modules: `lsmod`
   - Module information: `modinfo`
   - Wireless device status: `iw dev`

4. **Service status**
   - Check if services are running
   - Identify failed units
   - Recent restart events

## When to use me

- "Network isn't working"
- "Check why X service failed"
- "Diagnose boot issues"
- "Is WiFi connected?"
- "What's wrong with the system?"

## What I won't do

- Make configuration changes
- Restart services (I only check status)
- Modify network connections (only view)
