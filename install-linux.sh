#! /usr/bin/env bash

set -euo pipefail
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

sudo apt-get update
sudo apt-get install zsh direnv fzf build-essential procps curl file git
sudo ln -s ~/dotfiles/.zshrc ~/.zshrc
sudo ln -s ~/dotfiles/.zprofile ~/.zprofile
sudo ln -s ~/dotfiles/.zshrc.custom ~/.zshrc.custom
sudo ln -s ~/dotfiles/completion.zsh ~/completion.zsh

sudo ln -s ~/dotfiles/.gitconfig ~/.gitconfig

sudo chsh -s $(which zsh)

git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
brew bundle install --file Brewfile.linux