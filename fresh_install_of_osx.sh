#!/usr/bin/env bash

# file location: <anywhere>

# NOTE:
# 1) THOUGH THIS FILE WAS STARTED AS AN AUTOMATABLE SCRIPT, AT A CERTAIN POINT, IT WILL STOP/EXIT. IF YOU WISH TO CONTINUE BEYOND THAT STAGE, YOU WILL HAVE TO RUN THE REMAINING STEPS MANUALLY. YMMV
# 2) THERE ARE SOME PLACES WHERE IT REFERS TO MY PERSONAL GITHUB/GITLAB REPOS - YOU WILL HAVE TO CREATE YOUR OWN FOR THOSE STAGES

##################################
# Install command line dev tools #
##################################
# Note: Commenting this out - since it will take a long time to download and install xcode if this is triggered accidentally more than once
# xcode-select -p > /dev/null 2>&1
# if [ $# != 0 ]; then
#   # Uninstall if already present (or) if an older version is installed
#   sudo rm -rf $(xcode-select -p)
#   xcode-select --install
#   sudo xcodebuild -license accept
# fi


#####################
# Turn on FileVault #
#####################
FILEVAULT_STATUS=$(fdesetup status)
if [[ ${FILEVAULT_STATUS} != "FileVault is On." ]]; then
  echo "FileVault is not turned on. Please encrypt your hard disk!"
fi

#################################
# Setup ssh scripts/directories #
#################################
mkdir -p ${HOME}/.ssh
sudo chmod -R 600 ${HOME}/.ssh/*


#####################
# Install oh-my-zsh #
#####################
curl -L http://install.ohmyz.sh | sh

curl -L https://gist.githubusercontent.com/jbellingham/88961767677615562467243fc95a9fec/raw -o ${HOME}/.zprofile
curl -L https://gist.githubusercontent.com/jbellingham/43fef5a31125ee444ea68915875a37d7/raw -o ${HOME}/.zshrc
curl -L https://gist.githubusercontent.com/jbellingham/40721d9c020586fa7b34d04dcb030f39/raw -o ${HOME}/.zshrc.custom
# curl -L TODO -o ${HOME}/.aliases
curl -L https://gist.githubusercontent.com/jbellingham/512ef536e2fee8d641a88556b9f80897/raw -o ${HOME}/.p10k.zsh

curl -L https://gist.githubusercontent.com/jbellingham/71a6a4ba989d15da95598805ebfca774/raw -o ${HOME}/.gitignore
curl -L https://gist.githubusercontent.com/jbellingham/4ef43bc00593ab02d62f135e2a260e4f/raw -o ${HOME}/.gitconfig

##################################
# Install custom plugins for zsh #
##################################
git clone --depth=1 https://github.com/mroth/evalcache ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/evalcache
# Note: Do not move these into 'Brewfile' - since that breaks the linking for omz plugins location
# git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

################################
# Prep for installing homebrew #
################################
source ${HOME}/.zprofile

echo ${HOMEBREW_PREFIX}
export PATH=${PATH}:${HOMEBREW_PREFIX}/bin
sudo mkdir -p ${HOMEBREW_PREFIX}/tmp ${HOMEBREW_PREFIX}/repository ${HOMEBREW_PREFIX}/plugins ${HOMEBREW_PREFIX}/bin
sudo chown -fR "$(whoami)":admin ${HOMEBREW_PREFIX}

#######################################
# Install homebrew (on empty machine) #
#######################################
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Note: This list is the 'first-set' of installations from brew, followed by the others inside the Brewfile. Done as an extra bootstrap step - so as to avoid installation issues when running the full bundle
# brew install direnv git gnupg zsh

curl -L https://gist.githubusercontent.com/jbellingham/07bc1468f8de98b7eecf91bce3e28387/raw -o ${HOME}/Brewfile
brew bundle   # You can run this here - but be prepared to have errors reported due to missing java

#######################################
# Install font for better readability #
#######################################
# <Go to iTerm2 > Preferences > Profiles > Default > Text > Change Font to 'MesloLGS Nerd Font'>
# <Go to Terminal > Preferences > Profiles > Basic > Text > Change Font to 'MesloLGS Nerd Font'>

# Set shortcut key bindings on iTerm2
# <Go to iTerm2 > Preferences > Profiles > Default > Keys > Presets (and choose 'Natural Text Editing')>
# <QUIT AND RESTART iTerm2> since `exec zsh` will not reload fonts


echo "********** QUIT AND RESTART iTerm2/Terminal since `exec zsh` will not reload fonts **********"
echo "********** Finished auto installation process - please continue beyond this in a manual manner **********"
exit 0   # Putting this line here so that anyone executing this file will still be forced to stop here


######################################################################################
# Setup any sudo access password from cmd-line to also invoke the gui touchId prompt #
######################################################################################
# approve_fingerprint_sudo.sh

################################################
# Reapply permissions for ssh files #
################################################
sudo chmod -R 600 ${HOME}/.ssh/*


##################################################################################
# Install ASDF package manager - requires changes already present in my `.zshrc` #
##################################################################################
# Note: Immediately after you install asdf, you will also have to echo certain lines into `~/.bash_profile` or `~/.zshrc` - please see here: https://github.com/asdf-vm/asdf (since i have that incorporated already, i dont have it in this script)

exec zsh

asdf plugin-add dotnet-core
# asdf plugin-add java
# asdf plugin-add ruby
# asdf plugin-add dart
# asdf plugin-add elixir
# asdf plugin-add erlang
# asdf plugin-add golang
# asdf plugin-add graalvm
# asdf plugin-add kotlin
# asdf plugin-add perl
# asdf plugin-add python
# asdf plugin-add rust

# Imports Node.js release team's OpenPGP keys to main keyring
asdf plugin-add nodejs
bash "${HOME}/.asdf/plugins/nodejs/bin/import-release-team-keyring"

# Note: Since I have already configured the `.tool-versions` file, we don't need to install each language separately
asdf install

# Note: Useful commands
# asdf plugin list --all --urls
# asdf plugin update --all

# To list all versions of a plugin
# asdf list-all erlang

# To reshim the plugin
# asdf reshim erlang

# To set the global version
# asdf global erlang 20.3.8

exec zsh

#################################
# Rerun after java is installed #
#################################
brew bundle  # This will use the Brewfile to install/upgrade all the libraries and apps and their dependencies

exec zsh

# <FOLLOW instructions on https://github.com/vic/asdf-link to install for jdk>
#
# For eg:
# ls /Library/Java/JavaVirtualMachines/
# asdf install jdk 1.8.0
# ls /Library/Java/JavaVirtualMachines/jdk1.8.0_152.jdk/Contents/Home/bin/*
# ln -vs /Library/Java/JavaVirtualMachines/jdk1.8.0_152.jdk/Contents/Home/bin/* ${HOME}/.asdf/installs/jdk/1.8.0/bin
# asdf reshim jdk


# Setup rider for use from the cmd-line
# rm -rf ${HOMEBREW_PREFIX}/bin/rider && ln -sf /Applications/Rider.app/Contents/MacOS/rider ${HOMEBREW_PREFIX}/bin/rider
# Setup idea for use from the cmd-line
# rm -rf ${HOMEBREW_PREFIX}/bin/idea && ln -sf /Applications/IntelliJ\ IDEA\ CE.app/Contents/MacOS/idea ${HOMEBREW_PREFIX}/bin/idea


###################################################################
# Restore the preferences from the older machine into the new one #
###################################################################
osx_defaults.sh -y
capture_defaults.sh i

# dotnet tool install -g dotnet-sonarscanner
dotnet tool install -g dotnet-format