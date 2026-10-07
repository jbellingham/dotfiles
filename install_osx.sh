#!/usr/bin/env bash
# Sets up a fresh Mac from this repo. Safe to re-run: each step skips work already done.
#   bash <(curl -fsSL https://raw.githubusercontent.com/jbellingham/dotfiles/trunk/install_osx.sh) [--antidote]
# --antidote installs antidote instead of oh-my-zsh. Your .zshrc must already load it (see README).
set -euo pipefail

plugin_manager="omz"
for arg in "$@"; do
  case "$arg" in
    --antidote) plugin_manager="antidote" ;;
    -h|--help) sed -n '2,4p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

REPO_HTTPS="https://github.com/jbellingham/dotfiles.git"
REPO_SSH="git@github.com:jbellingham/dotfiles.git"
BREW_PREFIX="/opt/homebrew"
warnings=()

step() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!! %s\033[0m\n' "$*"; warnings+=("$*"); }
have() { command -v "$1" >/dev/null 2>&1; }

[[ "$(uname -s)" == "Darwin" ]] || { echo "This script is for macOS."; exit 1; }
[[ "$(uname -m)" == "arm64" ]] || warn "Intel Mac: BREW_PREFIX should be /usr/local. Edit this script."
[[ $EUID -ne 0 ]] || { echo "Run as your own user, not root."; exit 1; }

step "Ask for sudo once"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

step "Xcode command line tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  echo "Finish the installer dialog. Waiting..."
  until xcode-select -p >/dev/null 2>&1; do sleep 10; done
fi

step "Homebrew"
if ! have brew && [[ ! -x "$BREW_PREFIX/bin/brew" ]]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$("$BREW_PREFIX/bin/brew" shellenv)"

step "yadm and git"
brew install yadm git

step "Clone dotfiles into your home folder"
if [[ -d "$HOME/.local/share/yadm/repo.git" ]]; then
  echo "yadm repo already exists. Skipping clone."
else
  # HTTPS because the repo is public and no SSH key exists yet.
  yadm clone --no-bootstrap "$REPO_HTTPS"
  # Fresh machine: replace any stock dotfiles (such as .zshrc) with the repo versions.
  yadm reset --hard origin/trunk
fi
yadm remote set-url origin "$REPO_SSH"

step "Install apps and tools from the Brewfile"
brew bundle --file "$HOME/Brewfile" || warn "Some Brewfile items failed. Re-run 'brew bundle --file ~/Brewfile'. Mac App Store items need you signed in to the App Store."

if [[ "$plugin_manager" == "antidote" ]]; then
  step "antidote"
  brew install antidote
  if grep -q 'oh-my-zsh\.sh' "$HOME/.zshrc" 2>/dev/null; then
    warn ".zshrc still sources oh-my-zsh. Follow 'Move from oh-my-zsh to antidote' in the README."
  fi
else
  step "oh-my-zsh and plugins"
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
  clone_plugin() { [[ -d "$plugins_dir/$2" ]] || git clone --depth=1 "https://github.com/$1" "$plugins_dir/$2"; }
  clone_plugin mroth/evalcache evalcache
  clone_plugin zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting
  clone_plugin zsh-users/zsh-autosuggestions zsh-autosuggestions
  clone_plugin Aloxaf/fzf-tab fzf-tab
fi

step "tmux plugin manager"
[[ -d "$HOME/.tmux/plugins/tpm" ]] || git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

step "mise and languages"
# Official installer, not brew. It puts mise at ~/.local/bin, where .zshrc expects it.
[[ -x "$HOME/.local/bin/mise" ]] || curl -fsSL https://mise.run | sh
"$HOME/.local/bin/mise" install || warn "mise install failed. Run it again in a new terminal."

step "macOS settings"
bash "$HOME/osx_defaults.sh"

step "FileVault"
if [[ "$(fdesetup status)" != "FileVault is On." ]]; then
  warn "FileVault is off. Turn it on in System Settings > Privacy & Security."
fi

step "Done"
if ((${#warnings[@]})); then
  printf 'Warnings:\n'
  printf '  - %s\n' "${warnings[@]}"
fi
cat <<'EOF'

Still manual:
  - Put your SSH key in place (1Password SSH agent, or copy ~/.ssh). Then: ssh -T git@github.com
  - Sign in: 1Password, App Store, GitHub (gh auth login), Claude Code.
  - Set the terminal font to "MesloLGS Nerd Font".
  - Alfred: Preferences > Advanced > Syncing > Set preferences folder > ~/.config/alfred
  - Clone ~/dev/work/chargefox-tools. ~/.zshrc sources files from it.
  - Quit and reopen the terminal. exec zsh does not reload fonts.
EOF
