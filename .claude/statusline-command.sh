#!/bin/env bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
SESSION_ID=$(echo "$input" | jq -r '.session_id // empty')
CWD=$(echo "$input" | jq -r '.cwd')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
RATE_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
PR_NUMBER=$(echo "$input" | jq -r '.pr.number // empty')
PR_STATE=$(echo "$input" | jq -r '.pr.review_state // empty')

PCT=${PCT:-0}
RATE_PCT=${RATE_PCT:-0}

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; WHITE='\033[37m'; RESET='\033[0m'

make_bar() {
  local pct=$1
  local filled=$((pct / 10))
  local empty=$((10 - filled))
  printf "%${filled}s" | tr ' ' '█'
  printf "%${empty}s" | tr ' ' '░'
}

pick_color() {
  local pct=$1
  if [ "$pct" -ge 90 ]; then echo "$RED"
  elif [ "$pct" -ge 70 ]; then echo "$YELLOW"
  else echo "$GREEN"; fi
}

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=$(git branch --show-current 2>/dev/null)

TEACH=""
[ -f "$CWD/.claude/teaching_mode" ] && TEACH=" ${WHITE}[TEACHING MODE]${RESET}"

# Design-work flag: the opus-nudge UserPromptSubmit hook drops this file when it
# detects sustained multi-constraint design work. Show an amber prompt to switch
# up to Opus — but only while still on a non-Opus model (self-clears after switch).
DESIGN=""
DESIGN_FLAG="$HOME/.claude/.session-flags/claude-design-${SESSION_ID}.flag"
if [ -n "$SESSION_ID" ] && [ -f "$DESIGN_FLAG" ] && ! echo "$MODEL" | grep -qi opus; then
  DESIGN=" ${YELLOW}⚡ DESIGN · /model opus${RESET}"
fi

PR_SEGMENT=""
if [ -n "$PR_NUMBER" ]; then
  case "$PR_STATE" in
    approved)           PR_COLOR="$GREEN";  PR_ICON="✓" ;;
    changes_requested)  PR_COLOR="$RED";    PR_ICON="✗" ;;
    review_required)    PR_COLOR="$YELLOW"; PR_ICON="○" ;;
    *)                  PR_COLOR="$CYAN";   PR_ICON="…" ;;
  esac
  PR_SEGMENT=" | ${PR_COLOR}PR ${PR_ICON} ${PR_STATE}${RESET}"
fi

# Line 1: model, teaching mode, design flag, dir, PR state
echo -e "${CYAN}[$MODEL]${RESET}${TEACH}${DESIGN} 📁 ${DIR##*/}${PR_SEGMENT}"

# Line 2: branch (omitted when not in a git repo)
[ -n "$BRANCH" ] && echo -e "🌿 $BRANCH"

# Line 3: context bar + rate limit bar + cost + duration
CTX_COLOR=$(pick_color "$PCT")
CTX_BAR=$(make_bar "$PCT")
RATE_COLOR=$(pick_color "$RATE_PCT")
RATE_BAR=$(make_bar "$RATE_PCT")
COST_FMT=$(printf '$%.2f' "$COST")

echo -e "CTX ${CTX_COLOR}${CTX_BAR}${RESET} ${PCT}% | RATE LIMIT ${RATE_COLOR}${RATE_BAR}${RESET} ${RATE_PCT}% | ${YELLOW}${COST_FMT}${RESET} | ⏱️ ${MINS}m ${SECS}s"
