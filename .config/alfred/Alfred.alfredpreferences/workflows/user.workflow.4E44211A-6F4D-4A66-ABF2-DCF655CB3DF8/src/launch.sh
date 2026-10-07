#!/bin/zsh --no-rcs

readonly dev="$HOME/$x_DEV"

if [[ "${allowed}" -eq 0 ]]; then
    open -b "com.runningwithcrayons.Alfred" alfred://runtrigger/$alfred_workflow_bundleid/polite
else
    if [[ -f "$dev" ]]; then
        "$dev" "$1"
    else
        ./src/calpp "$1"
    fi
fi
