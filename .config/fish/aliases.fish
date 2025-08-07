function ..    ; cd .. ; end
function ...   ; cd ../.. ; end
function ....  ; cd ../../.. ; end
function ..... ; cd ../../../.. ; end

# mv, rm, cp
abbr mv 'mv -v'
abbr rm 'rm -v'
abbr cp 'cp -v'

alias ls="ls --color=auto $argv"
alias ll="ls -la --color=auto $argv"

# remove file from quarantine
alias unquarantine="sudo xattr -rd com.apple.quarantine"

alias cat="bat"
alias top="btop"
alias bu="brew upgrade"
alias hgrep="history 1 | grep"
alias grep="rg -iF --color=auto"
alias formatjson="pbpaste | jq . | pbcopy"
alias aliases="alias | less"

if type -q trash
    alias rm="trash $argv"

    # safely (moves to trash instead of immediately deleting) recursively delete all node_modules down from the call site -- uses trash cli (brew install trash)
    # -F flag asks Finder to do the trashing to allow "put back" feature
    alias killnm="command find . -name node_modules -type d -prune -exec trash -F {} +"
end