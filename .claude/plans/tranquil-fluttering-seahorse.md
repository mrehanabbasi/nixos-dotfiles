# Implementation Plan: Add Session and Weekly Usage Limits to Claude Code Status Line

## Overview

Add real-time session (5-hour) and weekly (7-day) usage limits to the Claude Code status line by fetching data from the Anthropic OAuth API. The implementation will use pure Bash with intelligent caching to minimize latency and maintain the existing Catppuccin Mocha theme.

## Recommended Approach

### Architecture

1. **Fetch usage data from Anthropic API**: Query `https://api.anthropic.com/api/oauth/usage` with OAuth authentication
2. **Cache responses for 60 seconds**: Store API responses in `~/.cache/claude/usage-cache.json` to prevent excessive API calls
3. **Display on separate line**: Insert below main status line (multi-line output)
4. **Graceful error handling**: Fall back to cached data or omit section when API unavailable

### Display Format

**Updated Format**: Two-line output with enhanced reset time display

```
Sonnet 4.5 | [████████░░░░░░░░░░░░] 5.2K/200K (3%) | main | project
Session: 45% (resets in 1h 3m) | Weekly: 45% (resets in 2h 30m)
```

OR when session has no full hours:

```
Sonnet 4.5 | [████████░░░░░░░░░░░░] 5.2K/200K (3%) | main | project
Session: 23% (resets in 45m) | Weekly: 45% (resets in 2h 30m)
```

OR when session is in the last 5 minutes:

```
Sonnet 4.5 | [████████░░░░░░░░░░░░] 5.2K/200K (3%) | main | project
Session: 92% (resets in 4m 30s) | Weekly: 45% (resets in 2h 30m)
```

OR when session is under 60 seconds:

```
Sonnet 4.5 | [████████░░░░░░░░░░░░] 5.2K/200K (3%) | main | project
Session: 98% (resets in 45s) | Weekly: 45% (resets in 2h 30m)
```

OR when weekly reset is on a different day:

```
Sonnet 4.5 | [████████░░░░░░░░░░░░] 5.2K/200K (3%) | main | project
Session: 45% (resets in 1h 3m) | Weekly: 23% (resets on 21st Sep)
```

**Position**: Second line, below main status line

**Format**: `Session: {percentage}% (resets in {time}) | Weekly: {percentage}% (resets {when})`

**Reset Time Display Logic**:
- **Session**: Relative time with smart zero-skipping
  - If time >= 5 minutes: show hours+minutes, but skip zero components
    - If hours > 0 and minutes > 0: "1h 30m"
    - If hours > 0 and minutes = 0: "2h" (skip zero minutes)
    - If hours = 0: "45m" (skip zero hours)
  - If time < 5 minutes and >= 60 seconds: show minutes AND seconds, but skip zero components
    - If seconds > 0: "4m 30s", "2m 15s"
    - If seconds = 0: "4m", "2m" (skip zero seconds)
  - If time < 60 seconds: show only seconds (e.g., "45s")
- **Weekly**:
  - Same day as today: same time display rules as session
  - Different day: date with ordinal suffix and abbreviated month (e.g., "resets on 21st Sep")
- **Color**: Dynamic based on utilization, with "resets in/on" text in dimmed color (SUBTEXT0)

**Time Format Examples**:
- **Last 5 minutes range (smart zero-skipping):**
  - 4 minutes 30 seconds → "4m 30s"
  - 4 minutes 0 seconds → "4m" (skip zero seconds)
  - 3 minutes 45 seconds → "3m 45s"
  - 2 minutes 15 seconds → "2m 15s"
  - 1 minute 45 seconds → "1m 45s"
  - 1 minute 0 seconds → "1m" (skip zero seconds)
  - 60 seconds (edge) → "1m" (skip zero seconds)
- **5+ minutes range (smart zero-skipping):**
  - Hours + minutes (hours > 0, minutes > 0): "1h 3m", "2h 30m"
  - Hours only (hours > 0, minutes = 0): "2h", "9h" (skip zero minutes)
  - Minutes only (hours = 0): "45m", "75m", "120m"
- **Under 60 seconds:**
  - Seconds only: "45s", "12s", "3s"
- **Date format:** "1st Jan", "2nd Feb", "3rd Mar", "21st Sep", "22nd Oct", "23rd Nov"

**Colors**:
- Percentages colored dynamically based on utilization
- "resets in/on" and timestamps in SUBTEXT0 (dimmed)
- Labels ("Session:", "Weekly:") in SUBTEXT1

## Implementation Details

### 1. Authentication

- Read OAuth token from `~/.local/share/claude/secrets/credentials.json`
- Extract `access_token` field using `jq` (already a dependency)
- Credentials file already exists and is properly secured

### 2. API Fetching

**Endpoint**: `https://api.anthropic.com/api/oauth/usage`

**Required Headers**:
- `Authorization: Bearer $ACCESS_TOKEN`
- `anthropic-beta: oauth-2025-04-20`

**Tool**: Use `curl` (available system-wide)
- Timeout: 2 seconds to prevent status line hangs
- Silent mode: No progress bars or errors to terminal
- Response format: JSON with `five_hour` and `seven_day` objects containing `utilization` (0.0-1.0) and `resets_at` timestamp

### 3. Caching Strategy

**Location**: `~/.cache/claude/usage-cache.json`

**Cache Duration**: 60 seconds

**Cache Structure**:
```json
{
  "timestamp": 1738843200,
  "five_hour": {"utilization": 0.45, "resets_at": "2026-02-06T18:00:00Z"},
  "seven_day": {"utilization": 0.23, "resets_at": "2026-02-10T12:00:00Z"}
}
```

**Logic**:
1. Check cache file existence and age
2. If cache age < 60 seconds: use cached data
3. If cache expired or missing: fetch from API and update cache
4. On API failure: use stale cache if available
5. If no data available: omit usage section

### 4. Color Coding Scheme

**User Confirmed**: Standard thresholds (warn at 51%, alert at 91%)

Uses existing Catppuccin Mocha colors:

| Utilization | Color | Meaning |
|-------------|-------|---------|
| 0-50% | GREEN `#a6e3a1` | Plenty of capacity |
| 51-75% | YELLOW `#f9e2af` | Moderate usage |
| 76-90% | PEACH `#fab387` | High usage |
| 91-100% | RED `#f38ba8` | Critical/at limit |

### 5. Error Handling

**User Confirmed**: Omit section entirely when data unavailable

Graceful degradation priority:
1. Fresh API data (< 60s old)
2. Cached data (any age)
3. Omit usage section entirely if no data available

No errors printed to terminal - all failures are silent. The usage section only appears when we successfully have data to display.

### 6. Performance

**Target**: < 100ms status line render time

**Optimizations**:
- 60-second cache ensures most renders use cached data (~2ms)
- 2-second API timeout prevents hangs
- First render with API fetch: ~150-500ms (acceptable one-time cost)
- Lazy loading: skip if credentials don't exist
- Single jq invocation for cache reads

## Implementation Steps

### Step 1: Add Helper Functions to Script

Location: `modules/programs/development/claude/statusline-command.sh` after line 21 (after color definitions)

Add four helper functions:
1. **`get_usage_color()`** - Returns appropriate Catppuccin color based on utilization percentage
2. **`format_percentage()`** - Converts decimal utilization (0.45) to percentage string (45%)
3. **`format_reset_time()`** - Formats reset timestamps with enhanced logic (hours+minutes, ordinals, same-day detection)
4. **`fetch_usage_data()`** - Main function that handles authentication, caching, and API fetching

### Step 2: Call Usage Fetcher

Location: After line 111 (after `context_info` is built)

Call `fetch_usage_data` which sets global variables:
- `session_usage` - Decimal utilization for 5-hour limit
- `weekly_usage` - Decimal utilization for 7-day limit
- `session_resets_at` - ISO 8601 timestamp for session reset
- `weekly_resets_at` - ISO 8601 timestamp for weekly reset

### Step 3: Build Usage Display

After fetching data, build `usage_info` string:
- Format: `Session: 45% (resets in 1h 3m) | Weekly: 23% (resets on 21st Sep)`
- Apply color coding based on utilization levels
- Use SUBTEXT1 color for labels ("Session:", "Weekly:")
- Use dynamic colors for percentages based on utilization
- Use SUBTEXT0 for "resets in/on" text and timestamps (dimmed)
- Use SUBTEXT0 for separators (|)
- Session: Always use relative time with `format_reset_time` (type "relative")
- Weekly: Smart detection - same day = relative time, different day = date with `format_reset_time` (type "weekly")

### Step 4: Insert into Status Line

Location: Line 121 (in final output assembly)

Output usage info on a new line after main status line:
```bash
# Build main status line as before
output="$output ${SUBTEXT0}|${RESET} $context_info"

if [ -n "$git_info" ]; then
    output="$output ${SUBTEXT0}|${RESET} ${git_info}"
fi

# Add usage limits on separate line if available
if [ -n "$usage_info" ]; then
    output="$output\n$usage_info"
fi
```

### Step 5: Verify Dependencies

No changes needed:
- `jq` - Already in `home.packages` in `default.nix:16`
- `curl` - Available system-wide
- Cache directory - Already managed by XDG structure

## Reset Timestamp Implementation

### format_reset_time() Function

**Purpose**: Format ISO 8601 timestamps for display with smart hour skipping

**Parameters**:
- `$1` - ISO 8601 timestamp (e.g., "2026-02-06T18:00:00Z")
- `$2` - Format type: "relative" or "weekly"

**Relative Mode** (for session and same-day weekly):
- Calculate time remaining until reset
- If < 60 seconds: Format as "Xs" (seconds only)
  - Examples: "45s", "12s", "3s"
- If >= 60 seconds and < 300 seconds (< 5 minutes): Format as "Xm" or "Xm Ys" (skip zero components)
  - If seconds > 0: "4m 30s", "3m 45s", "2m 15s", "1m 45s"
  - If seconds = 0: "4m", "3m", "2m", "1m" (skip zero seconds)
  - Examples: "4m 30s", "3m 45s", "2m 15s", "1m 45s", "1m", "4m"
- If >= 300 seconds (>= 5 minutes) and hours = 0: Format as "Xm" (minutes only)
  - Examples: "45m", "75m", "120m"
  - Drop seconds when >= 5 minutes
- If >= 300 seconds (>= 5 minutes) and hours > 0: Format as "Xh" or "Xh Ym" (skip zero components)
  - If minutes > 0: "1h 3m", "2h 30m", "9h 15m"
  - If minutes = 0: "2h", "9h" (skip zero minutes)
  - Examples: "1h 3m", "2h", "9h"
- Returns empty string if timestamp invalid/expired

**Weekly Mode** (for weekly on different day):
- Check if reset date is same as today
  - If same day: use relative mode logic
  - If different day: format as "DDth MMM" with ordinal suffix
- Ordinal suffix logic:
  - 1, 21, 31 → "st"
  - 2, 22 → "nd"
  - 3, 23 → "rd"
  - All others → "th"
- Month abbreviations: Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
- Examples: "1st Jan", "2nd Feb", "3rd Mar", "21st Sep", "22nd Oct", "23rd Nov"

**Implementation**:
```bash
format_reset_time() {
    local timestamp="$1"
    local type="$2"  # "relative" or "weekly"

    [ -z "$timestamp" ] || [ "$timestamp" = "null" ] && echo "" && return

    local now_seconds=$(date +%s)
    local target_seconds=$(date -d "$timestamp" +%s 2>/dev/null)
    [ -z "$target_seconds" ] && echo "" && return

    local diff=$((target_seconds - now_seconds))
    [ $diff -lt 0 ] && echo "" && return

    # For weekly type, check if same day as today
    if [ "$type" = "weekly" ]; then
        local today=$(date +%Y-%m-%d)
        local target_day=$(date -d "$timestamp" +%Y-%m-%d 2>/dev/null)
        
        # If same day, treat as relative
        if [ "$today" = "$target_day" ]; then
            type="relative"
        fi
    fi

    # Relative time format (used for session and same-day weekly)
    if [ "$type" = "relative" ]; then
        # Less than 60 seconds - show only seconds
        if [ $diff -lt 60 ]; then
            echo "${diff}s"
            return
        fi

        # Less than 5 minutes (300 seconds) - show minutes and/or seconds (skip zeros)
        if [ $diff -lt 300 ]; then
            local minutes=$((diff / 60))
            local seconds=$((diff % 60))

            # Skip zero seconds
            if [ $seconds -eq 0 ]; then
                echo "${minutes}m"
            else
                echo "${minutes}m ${seconds}s"
            fi
            return
        fi

        # 5 minutes or more - calculate hours and minutes
        local hours=$((diff / 3600))
        local minutes=$(( (diff % 3600) / 60 ))

        # Skip hours if zero - only show minutes
        if [ $hours -eq 0 ]; then
            echo "${minutes}m"
            return
        fi

        # Show hours, skip zero minutes when >= 5 minutes
        if [ $minutes -eq 0 ]; then
            echo "${hours}h"
        else
            echo "${hours}h ${minutes}m"
        fi
        return
    fi

    # Weekly absolute date format (different day)
    local day=$(date -d "$timestamp" +%-d 2>/dev/null)
    local month=$(date -d "$timestamp" +%b 2>/dev/null)
    
    # Generate ordinal suffix
    local suffix="th"
    case $day in
        1|21|31) suffix="st" ;;
        2|22) suffix="nd" ;;
        3|23) suffix="rd" ;;
    esac
    
    echo "${day}${suffix} ${month}"
}
```

**Performance**: ~5-10ms per call (date command overhead)

### Updated fetch_usage_data() Function

Add extraction of `resets_at` fields:
```bash
if [ -f "$cache_file" ]; then
    session_usage=$(jq -r '.five_hour.utilization // -1' "$cache_file")
    weekly_usage=$(jq -r '.seven_day.utilization // -1' "$cache_file")
    session_resets_at=$(jq -r '.five_hour.resets_at // ""' "$cache_file")
    weekly_resets_at=$(jq -r '.seven_day.resets_at // ""' "$cache_file")
fi
```

### Updated Usage Display Logic

Build usage string with new format:
```bash
# Format session with relative time
local session_pct=$(format_percentage "$session_usage")
local session_color=$(get_usage_color "$session_usage")
local session_time=$(format_reset_time "$session_resets_at" "relative")

# Format weekly with smart same-day detection
local weekly_pct=$(format_percentage "$weekly_usage")
local weekly_color=$(get_usage_color "$weekly_usage")
local weekly_time=$(format_reset_time "$weekly_resets_at" "weekly")

# Build the output string
if [ -n "$session_time" ] && [ -n "$weekly_time" ]; then
    usage_info="${SUBTEXT1}Session:${RESET} ${session_color}${session_pct}%${RESET} ${SUBTEXT0}(resets in ${session_time})${RESET} ${SUBTEXT0}|${RESET} ${SUBTEXT1}Weekly:${RESET} ${weekly_color}${weekly_pct}%${RESET} ${SUBTEXT0}(resets in/on ${weekly_time})${RESET}"
fi
```

Note: The "resets in" vs "resets on" distinction is handled by the display logic - "in" for relative times, "on" for dates.

## Critical Files

1. **modules/programs/development/claude/statusline-command.sh** - Main implementation (~100 lines total added/modified)
   - Add enhanced `format_reset_time()` function (~45 lines) with ordinal suffix, month abbreviation, same-day detection, and seconds display
   - Update `fetch_usage_data()` to extract reset timestamps (~2 lines)
   - Update usage display logic to use new format with "resets in/on" prefix (~15 lines)
   - Update output assembly to use multi-line format (~5 lines)
2. **modules/programs/development/claude/default.nix** - Verify dependencies (no changes needed)

## Testing Strategy

1. **Test with valid credentials**: Verify usage percentages display with correct colors and new format
2. **Test time formats with zero-skipping**:
   - Session with hours > 0 and minutes > 0: e.g., "1h 3m", "2h 30m"
   - Session with hours > 0 and minutes = 0: e.g., "2h", "9h" (skip zero minutes)
   - Session with hours = 0 and >= 5 min: e.g., "45m", "75m", "120m"
   - Session with 1-5 minute range and seconds > 0: e.g., "4m 30s", "3m 45s", "2m 15s"
   - Session with 1-5 minute range and seconds = 0: e.g., "4m", "3m", "2m", "1m" (skip zero seconds)
   - Session under 60s: e.g., "45s", "12s"
   - Weekly same-day with hours and minutes: e.g., "2h 30m"
   - Weekly same-day with hours only: e.g., "2h" (skip zero minutes)
   - Weekly same-day in 1-5 minute range with seconds: e.g., "4m 30s", "2m 15s"
   - Weekly same-day in 1-5 minute range without seconds: e.g., "4m", "2m" (skip zero seconds)
   - Weekly same-day without hours and >= 5 min: e.g., "45m"
   - Weekly different day: e.g., "21st Sep", "2nd Oct"
3. **Test last 5 minutes threshold**:
   - Exactly 300 seconds (5 minutes): should show "5m" (no seconds) - at threshold
   - 299 seconds: should show "4m 59s" (with seconds) - just under threshold
   - 60 seconds: should show "1m" (skip zero seconds) - still in last 5 min range
   - 59 seconds: should show "59s" (seconds only) - under 60 sec threshold
4. **Test zero-skipping edge cases**:
   - 1 minute 0 seconds: should show "1m" (skip zero seconds)
   - 4 minutes 0 seconds: should show "4m" (skip zero seconds)
   - 2 hours 0 minutes: should show "2h" (skip zero minutes)
   - 9 hours 0 minutes: should show "9h" (skip zero minutes)
   - 1 minute 45 seconds: should show "1m 45s" (both non-zero)
   - 4 minutes 30 seconds: should show "4m 30s" (both non-zero)
   - Ordinal suffixes: Verify 1st, 2nd, 3rd, 4th, 21st, 22nd, 23rd, 31st
5. **Test without credentials**: Verify graceful omission of usage section
6. **Test with stale cache**: Verify API refetch after 60 seconds
7. **Test with network offline**: Verify fallback to cached data
8. **Test color thresholds**: Manually create cache with different utilization values
9. **Test performance**: Verify status line renders quickly (< 120ms cached, < 520ms fresh)

## Rollback Plan

If issues occur:
1. Immediate rollback: `git checkout HEAD~1 modules/programs/development/claude/statusline-command.sh`
2. Quick disable: Comment out `fetch_usage_data` call
3. Debug: Check `~/.cache/claude/usage-cache.json` and API manually with curl

## Security Considerations

- OAuth token never logged or written to cache (only API response data cached)
- Token remains in memory only during script execution
- Credentials file permissions already secured (600)
- Uses official Anthropic API endpoint with timeout protection

## Dependencies

**Required**: None (all dependencies already available)
- `jq` - Already included in `default.nix`
- `curl` - Available system-wide via `/run/current-system/sw/bin/curl`

**XDG Structure**: Already managed
- Cache directory: `~/.cache/claude/` (created by `xdg.cacheFile."claude/.keep"`)
- Credentials: `~/.local/share/claude/secrets/` (already exists)

## Success Criteria

1. ✓ Usage percentages display correctly with color coding
2. ✓ Reset timestamps display correctly with zero-skipping logic:
   - Session with hours > 0 and minutes > 0 shows both (e.g., "resets in 1h 3m", "resets in 2h 30m")
   - Session with hours > 0 and minutes = 0 shows hours only (e.g., "resets in 2h", "resets in 9h")
   - Session with hours = 0 and >= 5 min shows minutes only (e.g., "resets in 45m", "resets in 120m")
   - Session with 1-5 minutes and seconds > 0 shows both (e.g., "resets in 4m 30s", "resets in 2m 15s")
   - Session with 1-5 minutes and seconds = 0 shows minutes only (e.g., "resets in 4m", "resets in 2m")
   - Session shows seconds only when < 60s (e.g., "resets in 45s")
   - Weekly shows relative time with same zero-skipping logic when same day as reset
   - Weekly shows minutes + seconds when same day and < 5 min with seconds (e.g., "resets in 4m 30s")
   - Weekly shows minutes when same day and < 5 min without seconds (e.g., "resets in 4m")
   - Weekly shows date with ordinal suffix when different day (e.g., "resets on 21st Sep")
   - Timestamps use "resets in" prefix for relative times and "resets on" prefix for dates
   - Timestamps gracefully omitted if unavailable
   - Edge case: exactly 5 minutes (300 seconds) shows "5m" without seconds
   - Edge case: just under 5 minutes (299 seconds) shows "4m 59s" with seconds
   - Edge case: 1 minute exactly shows "1m" (skip zero seconds)
   - Edge case: 4 minutes exactly shows "4m" (skip zero seconds)
   - Edge case: 2 hours exactly shows "2h" (skip zero minutes)
3. ✓ Usage info appears on separate line below main status line (multi-line output)
4. ✓ Status line renders in < 120ms (cached) and < 520ms (API fetch)
5. ✓ No errors or warnings in terminal output
6. ✓ Graceful degradation when credentials missing or API unavailable
7. ✓ Maintains existing status line functionality and visual consistency
8. ✓ Cache prevents excessive API calls (max 1 request per 60 seconds)
9. ✓ Visual hierarchy: labels (SUBTEXT1), percentages (colored), "resets in/on" + timestamps (SUBTEXT0)
10. ✓ Ordinal suffixes work correctly (1st, 2nd, 3rd, 4th, 21st, 22nd, 23rd, 31st)
11. ✓ Month abbreviations display correctly (Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec)
12. ✓ Zero components are skipped properly:
    - "1h 3m" for 1h 3m (not "1h 3m 0s")
    - "2h" for 2h 0m (not "2h 0m")
    - "45m" for 45m (not "0h 45m")
    - "4m 30s" for 4m 30s (kept as is)
    - "4m" for 4m 0s (not "4m 0s")
    - "1m" for 1m 0s (not "1m 0s")
13. ✓ Seconds display correctly in last 5 minutes with zero-skipping: "4m 30s", "2m 15s", "4m", "2m" formats work
14. ✓ Threshold transitions work correctly: at 300s shows "5m", below 300s shows "Xm Ys" or "Xm"
15. ✓ Test cases verify all format combinations work correctly including last 5 minute range with proper zero-skipping
