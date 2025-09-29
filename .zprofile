
# file location: ~/.zprofile
# Login shell - only env vars and functions that don't load anything should go here

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

# Additional PATH entries
export PATH="$PATH:/home/jesse/.local/bin:/home/linuxbrew/.linuxbrew/bin:/Users/jessebellingham/Library/Application Support/JetBrains/Toolbox/scripts:/usr/local/bin"

# OrbStack integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
