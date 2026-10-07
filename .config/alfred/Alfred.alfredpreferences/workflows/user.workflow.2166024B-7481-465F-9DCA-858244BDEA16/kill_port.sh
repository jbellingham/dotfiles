#!/bin/zsh
pid="$1"

notify() {
    osascript -e "display notification \"$1\" with title \"Kill Port\""
}

if [[ -z "$pid" ]]; then
    notify "No process selected"
    exit 0
fi

if kill -9 "$pid" 2>/dev/null; then
    notify "Killed $process_name on port $port"
else
    notify "Could not kill PID $pid — try: sudo kill -9 $pid"
fi
