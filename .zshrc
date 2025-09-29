zmodload zsh/zprof
source ${HOME}/.zprofile

# INTERACTIVE SHELL SETUP - UI, behavior, and user interface

# Oh My Zsh setup
export ZSH=${HOME}/.oh-my-zsh

# Oh My Zsh Configuration
DISABLE_UPDATE_PROMPT="true"
export UPDATE_ZSH_DAYS=10
ENABLE_CORRECTION="true"
HIST_STAMPS="yyyy-mm-dd"

# Plugins (fzf-tab should be last for proper integration)
plugins=(evalcache brew sudo zsh-autosuggestions macos direnv zsh-syntax-highlighting fzf-tab)
source $ZSH/oh-my-zsh.sh

# Configure fzf-tab for better integration
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept

# Prompt configuration
command_exists oh-my-posh
if [ $? -eq 0 ]; then
    eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
fi

# Navigation tools (interactive)
arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
    eval "$(jump shell zsh)"
else
    . /usr/share/autojump/autojump.sh
fi

# macOS-specific shell options (moved from .zshrc.custom)
if [[ "$OSTYPE" = darwin* ]] ; then
  # History options
  setopt append_history
  setopt share_history
  setopt inc_append_history
  setopt hist_ignore_all_dups
  setopt hist_ignore_dups
  setopt hist_allow_clobber
  setopt hist_reduce_blanks
  setopt hist_save_no_dups

  # Directory navigation
  setopt auto_cd
  setopt auto_pushd
  setopt pushd_silent
  setopt pushd_ignore_dups

  # Completion and display
  setopt beep
  setopt extended_glob
  setopt auto_list
  setopt list_ambiguous
  setopt list_types

  # Console colors
  autoload -U colors && colors
fi

# Fix slowness of pastes with zsh-syntax-highlighting (moved from .zshrc.custom)
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}
pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# Interactive tool initialization (mcfly after fzf-tab setup)
eval "$(mcfly init zsh)"
eval "$(mcfly-fzf init zsh)"

# Load personal customizations
load_file_if_exists "${HOME}/.zshrc.custom"
