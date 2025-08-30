if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting

export HOMEBREW_PREFIX="/opt/homebrew"

source ~/.config/fish/aliases.fish
source ~/.config/fish/path.fish

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

### Plugins
mcfly init fish | source
mcfly-fzf init fish | source
jump shell fish | source
oh-my-posh init fish --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json' | source
direnv hook fish | source
asdf completion fish > ~/.config/fish/completions/asdf.fish