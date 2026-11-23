#!/usr/bin/env bash
# Saves context and rate-limit numbers for the Herdr usage mods, then runs the normal status line.
input=$(cat)
dir="$HOME/.config/herdr-app/data/claude-usage"
mkdir -p "$dir"
sid=$(echo "$input" | jq -r '.session_id // empty')
if [ -n "$sid" ]; then
  echo "$input" | jq -c --argjson ts "$(date +%s)" '{
    cwd: (.workspace.current_dir // .cwd),
    terminal: ($ENV.HC_TERMINAL_ID // null),
    ctx: (.context_window.used_percentage // null),
    week: (.rate_limits.seven_day.used_percentage // null),
    week_resets: (.rate_limits.seven_day.resets_at // null),
    five_hour: (.rate_limits.five_hour.used_percentage // null),
    five_hour_resets: (.rate_limits.five_hour.resets_at // null),
    ts: $ts }' > "$dir/$sid.json.tmp" && mv "$dir/$sid.json.tmp" "$dir/$sid.json"
fi
echo "$input" | bash "$HOME/.claude/statusline-command.sh"
