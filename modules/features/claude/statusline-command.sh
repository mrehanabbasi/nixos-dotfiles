#!/bin/bash

# Catppuccin Mocha color palette
ROSEWATER="\033[38;2;245;224;220m"
FLAMINGO="\033[38;2;242;205;205m"
PINK="\033[38;2;245;194;231m"
MAUVE="\033[38;2;203;166;247m"
RED="\033[38;2;243;139;168m"
MAROON="\033[38;2;235;160;172m"
PEACH="\033[38;2;250;179;135m"
YELLOW="\033[38;2;249;226;175m"
GREEN="\033[38;2;166;227;161m"
TEAL="\033[38;2;148;226;213m"
SKY="\033[38;2;137;220;235m"
SAPPHIRE="\033[38;2;116;199;236m"
BLUE="\033[38;2;137;180;250m"
LAVENDER="\033[38;2;180;190;254m"
TEXT="\033[38;2;205;214;244m"
SUBTEXT1="\033[38;2;186;194;222m"
SUBTEXT0="\033[38;2;166;173;200m"
RESET="\033[0m"

# Not a Catppuccin swatch: a darker red than RED (#f38ba8) so the context bar
# has a distinct step past the point where long-context recall degrades.
DARK_RED="\033[38;2;155;33;58m"

# Helper function: Get color based on utilization percentage
get_usage_color() {
    local percentage="$1"
    [ -z "$percentage" ] && echo "$SUBTEXT0" && return

    if [ "$percentage" -le 50 ]; then
        echo "$GREEN"
    elif [ "$percentage" -le 75 ]; then
        echo "$YELLOW"
    elif [ "$percentage" -le 90 ]; then
        echo "$PEACH"
    else
        echo "$RED"
    fi
}

# Helper function: Format a rate-limit reset time (Unix epoch seconds).
# type is "relative" (countdown) or "weekly" (countdown same day, date otherwise).
format_reset_time() {
    local target_seconds="$1"
    local type="$2"

    [ -z "$target_seconds" ] && echo "" && return

    local now_seconds=$(date +%s)
    local diff=$((target_seconds - now_seconds))
    [ $diff -lt 0 ] && echo "" && return

    # For weekly type, fall back to a countdown when the reset lands today
    if [ "$type" = "weekly" ]; then
        local today=$(date +%Y-%m-%d)
        local target_day=$(date -d "@$target_seconds" +%Y-%m-%d 2>/dev/null)
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

        if [ $hours -eq 0 ]; then
            echo "${minutes}m"
            return
        fi

        if [ $minutes -eq 0 ]; then
            echo "${hours}h"
        else
            echo "${hours}h ${minutes}m"
        fi
        return
    fi

    # Weekly absolute date format (different day)
    local day=$(date -d "@$target_seconds" +%-d 2>/dev/null)
    local month=$(date -d "@$target_seconds" +%b 2>/dev/null)

    # Generate ordinal suffix
    local suffix="th"
    case $day in
        1|21|31) suffix="st" ;;
        2|22) suffix="nd" ;;
        3|23) suffix="rd" ;;
    esac

    echo "${day}${suffix} ${month}"
}

# Read JSON input from stdin
input=$(cat)

# Extract everything we need in one jq pass. Fields that may be absent or null
# (context_window before the first API call, rate_limits for non-subscribers)
# fall back to empty strings and are handled by the callers below.
# Fields are joined on U+001F rather than @tsv: `read` treats tab as IFS
# whitespace and collapses the runs of empty fields that absent rate_limits
# produce, shifting every value after them.
IFS=$'\037' read -r model_id model_name project_dir transcript_path output_style \
    ctx_size ctx_used_pct ctx_input_tokens \
    session_pct session_resets_at weekly_pct weekly_resets_at <<< "$(
    echo "$input" | jq -r '[
        .model.id // "",
        .model.display_name // "",
        .workspace.project_dir // "",
        .transcript_path // "",
        .output_style.name // "default",
        (.context_window.context_window_size // 200000),
        (.context_window.used_percentage // 0 | floor),
        (.context_window.total_input_tokens // 0),
        (.rate_limits.five_hour.used_percentage // "" | if . == "" then "" else floor end),
        (.rate_limits.five_hour.resets_at // ""),
        (.rate_limits.seven_day.used_percentage // "" | if . == "" then "" else floor end),
        (.rate_limits.seven_day.resets_at // "")
    ] | map(tostring) | join("")'
)"

# Prefer model.id — it carries the version that display_name drops ("Opus" vs
# "claude-opus-5"). Strip the vendor prefix and any trailing release date so
# "claude-haiku-4-5-20251001" renders as "haiku-4-5".
if [ -n "$model_id" ]; then
    model_short=$(echo "$model_id" | sed -e 's/^claude-//' -e 's/-[0-9]\{8\}$//')
else
    model_short=$(echo "$model_name" | sed 's/^Claude //' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
fi

# Get project folder name
project_name=$(basename "$project_dir")

# Get git branch (skip optional locks for performance)
if [ -d "$project_dir/.git" ]; then
    git_branch=$(cd "$project_dir" 2>/dev/null || exit 0 && git --no-optional-locks branch --show-current 2>/dev/null)
    if [ -z "$git_branch" ]; then
        git_branch=$(cd "$project_dir" 2>/dev/null || exit 0 && git --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    fi
    if [ -n "$git_branch" ]; then
        # Check if there are uncommitted changes
        if cd "$project_dir" 2>/dev/null || exit 0 && git --no-optional-locks diff-index --quiet HEAD -- 2>/dev/null; then
            git_status="${GREEN}"
        else
            git_status="${YELLOW}"
        fi
        git_info="${git_status}${git_branch}${RESET}"
    else
        git_info=""
    fi
else
    git_info=""
fi

# Context usage. context_window comes straight from Claude Code, so the window
# size tracks whatever the active model actually has (200K, 1M with extended
# context, etc.) instead of a hardcoded table.
percentage=$ctx_used_pct
[ "$percentage" -gt 100 ] && percentage=100

# Create progress bar (20 characters wide)
bar_width=20
filled=$((percentage * bar_width / 100))
empty=$((bar_width - filled))

# Color by context *used*, on thresholds tuned to recall degradation rather
# than to running out of room: attention thins out long before the window
# fills, so warn early. 40% starts the warning band, 50% is the point to think
# about compacting, 75%+ is the zone to get out of. Applies to this segment
# only — the Session/Weekly windows keep get_usage_color's own scale.
if [ "$percentage" -lt 40 ]; then
    bar_color="$GREEN"
elif [ "$percentage" -lt 50 ]; then
    bar_color="$YELLOW"
elif [ "$percentage" -lt 75 ]; then
    bar_color="$RED"
else
    bar_color="$DARK_RED"
fi
context_color="$bar_color"

# Build progress bar with block characters
bar="${SUBTEXT0}[${bar_color}"
for ((i=0; i<filled; i++)); do bar+="█"; done
printf -v bar "%s${SUBTEXT0}" "$bar"
for ((i=0; i<empty; i++)); do bar+="░"; done
bar+="]${RESET}"

# Format token counts (e.g., 5.2K, 120K, 1.0M)
format_tokens() {
    local n="$1"
    if [ "$n" -ge 1000000 ]; then
        awk "BEGIN {printf \"%.1fM\", $n/1000000}"
    elif [ "$n" -ge 1000 ]; then
        awk "BEGIN {printf \"%.0fK\", $n/1000}"
    else
        echo "$n"
    fi
}

tokens_display=$(format_tokens "$ctx_input_tokens")
max_display=$(format_tokens "$ctx_size")

context_info="$bar ${context_color}${tokens_display}${SUBTEXT0}/${SUBTEXT1}${max_display}${RESET} ${SUBTEXT0}(${context_color}${percentage}%${SUBTEXT0})${RESET}"

# Single transcript pass: cumulative token total (for burn rate) plus the
# per-model distribution. Both need the same scan, so do it once.
cumulative_tokens=0
model_dist=""
if [ -f "$transcript_path" ] && command -v jq >/dev/null 2>&1; then
    transcript_data=$(tr -d '\000-\010\013\014\016-\037' < "$transcript_path" | jq -rs '
        map(select(.message.usage != null)) as $all |
        ([$all[] | (.message.usage.input_tokens // 0) + (.message.usage.output_tokens // 0)] | add // 0) as $total_tokens |
        ($all | map(select(.message.model != null)) | group_by(.message.model) |
            map({
                model: .[0].message.model,
                tokens: (map((.message.usage.input_tokens // 0) + (.message.usage.output_tokens // 0)) | add)
            })
        ) as $groups |
        ($groups | map(.tokens) | add // 0) as $grouped_total |
        ($total_tokens | tostring) + "\t" +
        (if ($groups | length) <= 1 or $grouped_total == 0 then ""
         else
            $groups |
            sort_by(-.tokens) |
            map(
                (.tokens * 100 / $grouped_total | floor | tostring) + "% " +
                (if .tokens >= 1000 then (.tokens / 1000 * 10 | floor / 10 | tostring) + "K" else (.tokens | tostring) end) +
                " tok " + (.model | ltrimstr("claude-"))
            ) |
            "Models: " + join(" | ")
         end)
    ' 2>/dev/null || echo "")
    if [ -n "$transcript_data" ]; then
        IFS=$'\t' read -r cumulative_tokens model_dist <<< "$transcript_data"
    fi
fi
[ -z "$cumulative_tokens" ] && cumulative_tokens=0

model_dist_info=""
if [ -n "$model_dist" ]; then
    model_dist_info=$(echo "$model_dist" | sed \
        -e "s|Models: |${TEAL}Models:${RESET} |" \
        -e "s| | ${SUBTEXT0}|${RESET} |g")
fi

# Burn rate: cumulative tokens consumed per minute, sampled between renders
burn_rate_info=""
burn_rate_file="$HOME/.cache/claude/burn-rate.json"
if [ "$cumulative_tokens" -gt 0 ] 2>/dev/null; then
    now=$(date +%s)
    if [ -f "$burn_rate_file" ]; then
        prev_time=$(jq -r '.timestamp // 0' "$burn_rate_file" 2>/dev/null || echo 0)
        prev_tokens=$(jq -r '.tokens // 0' "$burn_rate_file" 2>/dev/null || echo 0)
        delta_time=$(( now - prev_time ))
        delta_tokens=$(( cumulative_tokens - prev_tokens ))
        if [ "$delta_time" -gt 10 ] && [ "$delta_tokens" -gt 0 ]; then
            burn_per_min=$(( delta_tokens * 60 / delta_time ))
            if [ "$burn_per_min" -ge 1000 ]; then
                burn_display="$(awk "BEGIN {printf \"%.1f\", $burn_per_min/1000}")K tok/min"
            else
                burn_display="${burn_per_min} tok/min"
            fi
            if [ "$burn_per_min" -lt 500 ]; then
                burn_color="$GREEN"
            elif [ "$burn_per_min" -lt 2000 ]; then
                burn_color="$YELLOW"
            else
                burn_color="$RED"
            fi
            burn_rate_info="${burn_color}↑ ${burn_display}${RESET}"
        fi
    fi
    # Update state file
    mkdir -p "$(dirname "$burn_rate_file")"
    printf '{"timestamp":%s,"tokens":%s}\n' "$now" "$cumulative_tokens" > "$burn_rate_file"
fi

# Subscription rate limits, straight from the statusline payload. Present only
# for Claude.ai Pro/Max, and only after the first API response of the session;
# Claude Code drops a window once its resets_at passes.
usage_info=""
if [ -n "$session_pct" ] || [ -n "$weekly_pct" ]; then
    segments=()

    if [ -n "$session_pct" ]; then
        session_color=$(get_usage_color "$session_pct")
        session_time=$(format_reset_time "$session_resets_at" "relative")
        session_reset_text=""
        if [ -n "$session_time" ]; then
            session_absolute_time=$(date -d "@$session_resets_at" +"%I:%M%P" 2>/dev/null | sed 's/^0//')
            session_reset_text=" ${SUBTEXT0}(resets in ${session_time}"
            [ -n "$session_absolute_time" ] && session_reset_text="${session_reset_text} - ${session_absolute_time}"
            session_reset_text="${session_reset_text})${RESET}"
        fi
        segments+=("${SUBTEXT1}Session:${RESET} ${session_color}${session_pct}%${RESET}${session_reset_text}")
    fi

    if [ -n "$weekly_pct" ]; then
        weekly_color=$(get_usage_color "$weekly_pct")
        weekly_time=$(format_reset_time "$weekly_resets_at" "weekly")
        weekly_reset_text=""
        if [ -n "$weekly_time" ]; then
            # "on 21st Sep" for a future day, "in 3h 10m" for a countdown
            weekly_prefix="in"
            weekly_absolute_time=""
            if [[ "$weekly_time" =~ ^[0-9]+[a-z]+[[:space:]][A-Z][a-z]+$ ]]; then
                weekly_prefix="on"
            else
                weekly_absolute_time=$(date -d "@$weekly_resets_at" +"%I:%M%P" 2>/dev/null | sed 's/^0//')
            fi
            weekly_reset_text=" ${SUBTEXT0}(resets ${weekly_prefix} ${weekly_time}"
            [ -n "$weekly_absolute_time" ] && weekly_reset_text="${weekly_reset_text} - ${weekly_absolute_time}"
            weekly_reset_text="${weekly_reset_text})${RESET}"
        fi
        segments+=("${SUBTEXT1}Weekly:${RESET} ${weekly_color}${weekly_pct}%${RESET}${weekly_reset_text}")
    fi

    usage_info="${segments[0]}"
    if [ "${#segments[@]}" -gt 1 ]; then
        usage_info="${segments[0]} ${SUBTEXT0}|${RESET} ${segments[1]}"
    fi
fi

# Build status line with colors
output="${MAUVE}${model_short}${RESET}"

# Add output style if not default
if [ "$output_style" != "default" ] && [ "$output_style" != "null" ]; then
    output="$output ${SUBTEXT0}|${RESET} ${PINK}${output_style}${RESET}"
fi

output="$output ${SUBTEXT0}|${RESET} $context_info"

# Add caveman mode badge if active (only when Claude Code session is running)
caveman_flag="$HOME/.claude/.caveman-active"
if [ -f "$caveman_flag" ] && pgrep -x "claude" > /dev/null 2>&1; then
    caveman_mode=$(cat "$caveman_flag" 2>/dev/null)
    if [ "$caveman_mode" = "full" ] || [ -z "$caveman_mode" ]; then
        caveman_badge="${PEACH}CAVEMAN${RESET}"
    else
        caveman_suffix=$(echo "$caveman_mode" | tr '[:lower:]' '[:upper:]')
        caveman_badge="${PEACH}CAVEMAN:${caveman_suffix}${RESET}"
    fi
    output="$output ${SUBTEXT0}|${RESET} ${caveman_badge}"
fi

if [ -n "$git_info" ]; then
    output="$output ${SUBTEXT0}|${RESET} ${git_info}"
fi

output="$output ${SUBTEXT0}|${RESET} ${LAVENDER}${project_name}${RESET}"

# Add usage limits on separate line if available
if [ -n "$usage_info" ]; then
    output="$output\n$usage_info"
fi

# Add burn rate line if available
if [ -n "$burn_rate_info" ]; then
    output="$output\n$burn_rate_info"
fi

# Add model distribution line if multiple models were used
if [ -n "$model_dist_info" ]; then
    output="$output\n$model_dist_info"
fi

printf "%b\n" "$output"
