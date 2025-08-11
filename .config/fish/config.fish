if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting

export HOMEBREW_PREFIX="/opt/homebrew"
export GEM_HOME=$HOME/.gem

# Homebrew
export PATH="$PATH:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.bin:$HOME/.bin/git:$HOME/.bin/linux:$HOME/.bin/macos:$HOME/.dotnet:$HOME/.dotnet/tools:$HOME/dev/flutter/bin:$HOME/.pub-cache/bin:$GEM_HOME/bin:$HOME/bin"


source ~/.config/fish/aliases.fish

# BEGIN -- ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims
# END -- ASDF configuration code

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

### Plugins
mcfly init fish | source
mcfly-fzf init fish | source
jump shell fish | source
oh-my-posh init fish --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json' | source
direnv hook fish | source