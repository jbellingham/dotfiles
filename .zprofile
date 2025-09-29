
# file location: ~/.zprofile
# LOGIN SHELL SETUP - Environment variables and heavy one-time operations

# Architecture detection and Homebrew setup
arch=`uname -m`
if [[ $arch =~ "arm" ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
else
  export HOMEBREW_PREFIX="/usr/local"
fi

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Homebrew environment
if [[ -d "/home/linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -d "/opt/homebrew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Utility functions
load_file_if_exists() {
  test -e "$1" && source "$1" || true
}

command_exists() {
  type $1 &> /dev/null 2>&1
}

# Locale and editor environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Editor setup
command_exists code
[[ "${EDITOR}" == "" && $? -eq 0 ]] && export EDITOR="code --goto"
[[ "${EDITOR}" == "" ]] && export EDITOR="vi"

# Architecture-specific compilation flags
[[ $arch =~ "x86" ]] && export ARCHFLAGS="-arch x86_64"

# Tool homes and roots
export TALISMAN_HOME=$HOME/.talisman/bin
export GEM_HOME=$HOME/.gem
export DOTNET_ROOT="${HOME}/.dotnet"
export RIPGREP_CONFIG_PATH=~/.ripgreprc

# Homebrew configuration
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=3
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=3
export HOMEBREW_BAT=1
export HOMEBREW_UPDATE_REPORT_ONLY_INSTALLED=1
export HOMEBREW_VERBOSE_USING_DOTS=1
export HOMEBREW_BUNDLE_FILE=$HOME/Brewfile

# Consolidated PATH (all modifications in one place)
export PATH="$PATH:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.bin:$HOME/.bin/git:$HOME/.bin/linux:$HOME/.bin/macos:$HOME/.dotnet:$HOME/.dotnet/tools:$HOME/dev/flutter/bin:$HOME/.pub-cache/bin:$GEM_HOME/bin:$HOME/.local/bin:/home/jesse/.local/bin:/home/linuxbrew/.linuxbrew/bin:/Users/jessebellingham/Library/Application Support/JetBrains/Toolbox/scripts:/usr/local/bin:$HOMEBREW_PREFIX/opt/postgresql@16/bin:/home/jesse/.config/herd-lite/bin"

# Development tool environment setup
ASDF_DIR=$HOME/.asdf
if [ -d $ASDF_DIR ]; then
  load_file_if_exists "$ASDF_DIR/asdf.sh"
fi

# Tool-specific setup
if [ -f ~/.asdf/plugins/golang/set-env.zsh ]; then
    . ~/.asdf/plugins/golang/set-env.zsh
fi

# Homebrew-dependent development setup
command_exists brew && {
  # zlib - required for installing python via asdf
  ZLIB_DIR=$HOMEBREW_PREFIX/opt/zlib
  if [ -d $ZLIB_DIR ]; then
    export LDFLAGS="-L$ZLIB_DIR/lib $LDFLAGS"
    export CPPFLAGS="-I$ZLIB_DIR/include $CPPFLAGS"
  fi
}

# OrbStack integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
