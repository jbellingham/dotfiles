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


git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

sudo chsh -s $(which zsh)

brew bundle install --file Brewfile.linux