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

# Helper function: Get color based on utilization percentage
get_usage_color() {
    local utilization="$1"
    [ -z "$utilization" ] || [ "$utilization" = "-1" ] && echo "$SUBTEXT0" && return

    local percentage=$(awk "BEGIN {printf \"%.0f\", $utilization}")

    if [ $percentage -le 50 ]; then
        echo "$GREEN"
    elif [ $percentage -le 75 ]; then
        echo "$YELLOW"
    elif [ $percentage -le 90 ]; then
        echo "$PEACH"
    else
        echo "$RED"
    fi
}

# Helper function: Format utilization as percentage string
format_percentage() {
    local utilization="$1"
    [ -z "$utilization" ] || [ "$utilization" = "-1" ] && echo "0" && return
    awk "BEGIN {printf \"%.0f\", $utilization}"
}

# Helper function: Format reset timestamp with smart zero-skipping
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

# Helper function: Fetch usage data from Anthropic API with caching
fetch_usage_data() {
    local credentials_file="$HOME/.local/share/claude/secrets/credentials.json"
    local cache_file="$HOME/.cache/claude/usage-cache.json"
    local cache_duration=60  # seconds

    # Reset global variables
    session_usage="-1"
    weekly_usage="-1"
    session_resets_at=""
    weekly_resets_at=""

    # Check if credentials exist
    [ ! -f "$credentials_file" ] && return

    # Check cache validity
    local use_cache=0
    if [ -f "$cache_file" ]; then
        local cache_timestamp=$(jq -r '.timestamp // 0' "$cache_file" 2>/dev/null)
        local now=$(date +%s)
        local cache_age=$((now - cache_timestamp))

        if [ $cache_age -lt $cache_duration ]; then
            use_cache=1
        fi
    fi

    # Use cached data if valid
    if [ $use_cache -eq 1 ]; then
        session_usage=$(jq -r '.five_hour.utilization // -1' "$cache_file" 2>/dev/null)
        weekly_usage=$(jq -r '.seven_day.utilization // -1' "$cache_file" 2>/dev/null)
        session_resets_at=$(jq -r '.five_hour.resets_at // ""' "$cache_file" 2>/dev/null)
        weekly_resets_at=$(jq -r '.seven_day.resets_at // ""' "$cache_file" 2>/dev/null)
        return
    fi

    # Extract OAuth token (nested under claudeAiOauth with camelCase field name)
    local access_token=$(jq -r '.claudeAiOauth.accessToken // ""' "$credentials_file" 2>/dev/null)
    [ -z "$access_token" ] && return

    # Fetch from API with timeout
    local api_response=$(curl -s --max-time 2 \
        -H "Authorization: Bearer $access_token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

    # Check if API call succeeded
    if [ -n "$api_response" ]; then
        # Extract data
        session_usage=$(echo "$api_response" | jq -r '.five_hour.utilization // -1' 2>/dev/null)
        weekly_usage=$(echo "$api_response" | jq -r '.seven_day.utilization // -1' 2>/dev/null)
        session_resets_at=$(echo "$api_response" | jq -r '.five_hour.resets_at // ""' 2>/dev/null)
        weekly_resets_at=$(echo "$api_response" | jq -r '.seven_day.resets_at // ""' 2>/dev/null)

        # Update cache
        mkdir -p "$(dirname "$cache_file")"
        local now=$(date +%s)
        echo "$api_response" | jq --arg ts "$now" '. + {timestamp: ($ts | tonumber)}' > "$cache_file" 2>/dev/null
    elif [ -f "$cache_file" ]; then
        # API failed, fall back to stale cache
        session_usage=$(jq -r '.five_hour.utilization // -1' "$cache_file" 2>/dev/null)
        weekly_usage=$(jq -r '.seven_day.utilization // -1' "$cache_file" 2>/dev/null)
        session_resets_at=$(jq -r '.five_hour.resets_at // ""' "$cache_file" 2>/dev/null)
        weekly_resets_at=$(jq -r '.seven_day.resets_at // ""' "$cache_file" 2>/dev/null)
    fi
}

# Read JSON input from stdin
input=$(cat)

# Extract values
model_name=$(echo "$input" | jq -r '.model.display_name')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir')
transcript_path=$(echo "$input" | jq -r '.transcript_path')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')

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

# Calculate context usage from transcript
if [ -f "$transcript_path" ]; then
    # Count tokens (approximation: characters / 4)
    char_count=$(wc -c < "$transcript_path")
    token_count=$((char_count / 4))

    # Context limits for different models (approximate)
    # Claude Sonnet 4.5 has 200k context window
    max_tokens=200000

    # Calculate percentage
    percentage=$((token_count * 100 / max_tokens))
    [ $percentage -gt 100 ] && percentage=100

    # Create progress bar (20 characters wide)
    bar_width=20
    filled=$((percentage * bar_width / 100))
    empty=$((bar_width - filled))

    # Choose color based on percentage (remaining context)
    # Green when plenty left, red when running out
    remaining=$((100 - percentage))
    if [ $remaining -gt 50 ]; then
        bar_color="$GREEN"
        context_color="$GREEN"
    elif [ $remaining -gt 25 ]; then
        bar_color="$YELLOW"
        context_color="$YELLOW"
    elif [ $remaining -gt 10 ]; then
        bar_color="$PEACH"
        context_color="$PEACH"
    else
        bar_color="$RED"
        context_color="$RED"
    fi

    # Build progress bar with block characters
    bar="${SUBTEXT0}[${bar_color}"
    for ((i=0; i<filled; i++)); do bar+="█"; done
    printf -v bar "%s${SUBTEXT0}" "$bar"
    for ((i=0; i<empty; i++)); do bar+="░"; done
    bar+="]${RESET}"

    # Format token count (e.g., 5.2K, 120K)
    if [ $token_count -ge 1000 ]; then
        tokens_display="$(awk "BEGIN {printf \"%.1f\", $token_count/1000}")K"
    else
        tokens_display="${token_count}"
    fi

    max_display="$(awk "BEGIN {printf \"%.0f\", $max_tokens/1000}")K"

    context_info="$bar ${context_color}${tokens_display}${SUBTEXT0}/${SUBTEXT1}${max_display}${RESET} ${SUBTEXT0}(${context_color}${percentage}%${SUBTEXT0})${RESET}"
else
    context_info="${SUBTEXT0}[${SUBTEXT0}░░░░░░░░░░░░░░░░░░░░]${RESET} ${GREEN}0K${SUBTEXT0}/${SUBTEXT1}200K${RESET} ${SUBTEXT0}(${GREEN}0%${SUBTEXT0})${RESET}"
fi

# Fetch usage data from Anthropic API (Step 2)
fetch_usage_data

# Build usage display string (Step 3)
usage_info=""
if [ "$session_usage" != "-1" ] && [ "$weekly_usage" != "-1" ]; then
    # Format session with relative time
    session_pct=$(format_percentage "$session_usage")
    session_color=$(get_usage_color "$session_usage")
    session_time=$(format_reset_time "$session_resets_at" "relative")

    # Calculate absolute reset time for session (12-hour format)
    session_absolute_time=""
    if [ -n "$session_resets_at" ] && [ "$session_resets_at" != "null" ]; then
        session_absolute_time=$(date -d "$session_resets_at" +"%I:%M%P" 2>/dev/null | sed 's/^0//')
    fi

    # Format weekly with smart same-day detection
    weekly_pct=$(format_percentage "$weekly_usage")
    weekly_color=$(get_usage_color "$weekly_usage")
    weekly_time=$(format_reset_time "$weekly_resets_at" "weekly")

    # Build the output string with appropriate "resets in/on" prefix
    if [ -n "$session_time" ] && [ -n "$weekly_time" ]; then
        # Determine "in" vs "on" for weekly based on whether it's a date format
        weekly_prefix="in"
        if [[ "$weekly_time" =~ ^[0-9]+[a-z]+[[:space:]][A-Z][a-z]+$ ]]; then
            # Matches date format like "21st Sep"
            weekly_prefix="on"
        fi

        # Build session string with absolute time if available
        session_reset_text="resets in ${session_time}"
        if [ -n "$session_absolute_time" ]; then
            session_reset_text="resets in ${session_time} - ${session_absolute_time}"
        fi

        usage_info="${SUBTEXT1}Session:${RESET} ${session_color}${session_pct}%${RESET} ${SUBTEXT0}(${session_reset_text})${RESET} ${SUBTEXT0}|${RESET} ${SUBTEXT1}Weekly:${RESET} ${weekly_color}${weekly_pct}%${RESET} ${SUBTEXT0}(resets ${weekly_prefix} ${weekly_time})${RESET}"
    fi
fi

# Build status line with colors
output="${MAUVE}${model_name}${RESET}"

# Add output style if not default
if [ "$output_style" != "default" ] && [ "$output_style" != "null" ]; then
    output="$output ${SUBTEXT0}|${RESET} ${PINK}${output_style}${RESET}"
fi

output="$output ${SUBTEXT0}|${RESET} $context_info"

if [ -n "$git_info" ]; then
    output="$output ${SUBTEXT0}|${RESET} ${git_info}"
fi

output="$output ${SUBTEXT0}|${RESET} ${LAVENDER}${project_name}${RESET}"

# Add usage limits on separate line if available (Step 4)
if [ -n "$usage_info" ]; then
    output="$output\n$usage_info"
fi

printf "%b\n" "$output"
