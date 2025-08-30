function ..    ; cd .. ; end
function ...   ; cd ../.. ; end
function ....  ; cd ../../.. ; end
function ..... ; cd ../../../.. ; end


abbr brwe 'brew'
abbr bewr 'brew'
abbr bwer 'brew'
abbr bwre 'brew'

# mv, rm, cp
abbr mv 'mv -v'
abbr rm 'rm -v'
abbr cp 'cp -v'
abbr omd 'overmind'

alias ls="ls --color=auto $argv"
alias ll="ls -la --color=auto $argv"

# remove file from quarantine
alias unquarantine="sudo xattr -rd com.apple.quarantine"
alias be="bundle exec"
alias cat="bat"
alias top="btop"
alias bu="brew upgrade"
alias hgrep="history 1 | grep"
alias hgrep="history | grep"
alias grep="rg -iF --color=auto"
alias formatjson="pbpaste | jq . | pbcopy"
alias aliases="alias | less"

alias assume="source (brew --prefix)/bin/assume.fish"

if type -q trash
    alias rm="trash $argv"

    # safely (moves to trash instead of immediately deleting) recursively delete all node_modules down from the call site -- uses trash cli (brew install trash)
    # -F flag asks Finder to do the trashing to allow "put back" feature
    alias killnm="command find . -name node_modules -type d -prune -exec trash -F {} +"
end