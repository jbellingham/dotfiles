zmodload zsh/zprof
source ${HOME}/.zprofile


# If you come from bash you might have to change your $PATH.
# export PATH=${HOME}/bin:${HOMEBREW_PREFIX}/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=${HOME}/.oh-my-zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# load_file_if_exists "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# load_file_if_exists "${HOME}/.p10k.zsh"
# load_file_if_exists "${HOMEBREW_PREFIX}/opt/powerlevel10k/powerlevel10k.zsh-theme"  # To be used if installing using brew
# load_file_if_exists "${ZSH_CUSTOM}/themes/powerlevel10k/powerlevel10k.zsh-theme"  # To be used if installing using 'git clone'
command_exists oh-my-posh
if [ $? -eq 0 ]; then
    eval "$(oh-my-posh --init --shell zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
fi

arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
    eval "$(jump shell zsh)"
else
    . /usr/share/autojump/autojump.sh
fi
eval "$(mcfly init zsh)"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=10

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Which plugins would you like to load?
# Standard plugins can be found in ${ZSH}/plugins/
# Custom plugins may be added to ${ZSH_CUSTOM}/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(evalcache asdf brew sudo zsh-autosuggestions zsh-syntax-highlighting macos direnv)
source $ZSH/oh-my-zsh.sh

command_exists direnv && _evalcache direnv hook zsh

# User configuration

# export MANPATH="/usr/local/man:${MANPATH}"

# You may need to manually set your language environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# [[ -n ${SSH_CONNECTION} ]] && export EDITOR="vim"

# Use code if its installed (both Mac OSX and Linux)
command_exists code
[[ "${EDITOR}" == "" && $? -eq 0 ]] && export EDITOR="code --goto"
# If neither of the above works, then fall back to vi
[[ "${EDITOR}" == "" ]] && export EDITOR="vi"

# Compilation flags
[[ $arch =~ "x86" ]] && export ARCHFLAGS="-arch x86_64"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh-plugins/fzf-tab/fzf-tab.plugin.zsh

load_file_if_exists "${HOME}/.zshrc.custom"

if [ -f ~/.asdf/plugins/golang/set-env.zsh ]; then
    . ~/.asdf/plugins/golang/set-env.zsh
fi

eval "$(mcfly init zsh)"
eval "$(direnv hook zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export PATH="/home/jesse/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="/home/jesse/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
