zmodload zsh/zprof
source ${HOME}/.zprofile

# Path to your oh-my-zsh installation.
export ZSH=${HOME}/.oh-my-zsh
command_exists oh-my-posh
if [ $? -eq 0 ]; then
    eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
fi

arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
    eval "$(jump shell zsh)"
else
    . /usr/share/autojump/autojump.sh
fi

# Oh My Zsh Configuration
DISABLE_UPDATE_PROMPT="true"
export UPDATE_ZSH_DAYS=10
ENABLE_CORRECTION="true"
HIST_STAMPS="yyyy-mm-dd"

# Plugins
plugins=(evalcache asdf brew sudo zsh-autosuggestions macos direnv zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# User configuration
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Editor setup
command_exists code
[[ "${EDITOR}" == "" && $? -eq 0 ]] && export EDITOR="code --goto"
[[ "${EDITOR}" == "" ]] && export EDITOR="vi"

# Architecture-specific compilation flags
[[ $arch =~ "x86" ]] && export ARCHFLAGS="-arch x86_64"

load_file_if_exists "${HOME}/.zshrc.custom"

# Tool-specific setup
if [ -f ~/.asdf/plugins/golang/set-env.zsh ]; then
    . ~/.asdf/plugins/golang/set-env.zsh
fi

# Additional PATH entries
export PATH="$PATH:$HOMEBREW_PREFIX/opt/postgresql@16/bin"

# Tool initialization
command_exists direnv && _evalcache direnv hook zsh
eval "$(mcfly init zsh)"
