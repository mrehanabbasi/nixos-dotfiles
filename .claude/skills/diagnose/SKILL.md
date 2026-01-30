---
name: diagnose
description: Run system diagnostics for network, boot, and hardware issues
disable-model-invocation: false
context: fork
allowed-tools: [Bash, Read]
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

## Pre-approved commands

I use bash patterns already allowed in your `settings.local.json`:
- `Bash(dmesg:*)`
- `Bash(nmcli:*)`
- `Bash(journalctl:*)`
- `Bash(systemctl status:*)`
- `Bash(iwctl:*)`
- `Bash(ip addr:*)`
- `Bash(lsmod:*)`
- `Bash(modinfo:*)`
- `Bash(iw dev:*)`

These don't require confirmation since they're read-only diagnostic commands.

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

## Token optimization

Running in fork context saves 3-5K tokens per troubleshooting session by:
- Keeping verbose logs out of main context
- Isolating diagnostic output
- Summarizing findings before returning to main conversation

## Example usage

Just say:
- "Diagnose network issues"
- "Check system logs for errors"
- "Why isn't WiFi working?"
- "Show me recent boot logs"
