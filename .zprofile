
# file location: ~/.zprofile

# login shell - only env vars and other functions that don't load anything should go in here
# This is a companion script for the `~/.zshrc` file

arch=`uname -m`
if [[ $arch =~ "arm" ]]
then
  export HOMEBREW_PREFIX="/opt/homebrew"
else
  export HOMEBREW_PREFIX="/usr/local"
fi
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

load_file_if_exists() {
  test -e "$1" && source "$1" || true
}

command_exists() {
  type $1 &> /dev/null 2>&1
}

export PATH=$PATH:/home/jesse/.local/bin
export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin


# Added by Toolbox App
export PATH="$PATH:/Users/jessebellingham/Library/Application Support/JetBrains/Toolbox/scripts"
export PATH="$PATH:/usr/local/bin"
