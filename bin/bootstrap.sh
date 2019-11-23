#!/bin/bash

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew cask install iterm2 intellij-idea karabiner-elements firefox hammerspoon menumeters little-snitch micro-snitch steam docker vlc spotify nordvpn slack oath-toolkit
brew install macvim vlc awscli htop oath-toolkit

# Oh my zsh!
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# SdkMan
curl -s "https://get.sdkman.io" | bash

# Disable resize animations
defaults write -g NSWindowResizeTime -float 0.003

# Local zsh configuration
touch ~/.zshrc.local
echo "source ~/.zshrc.local" >> ~/.zshrc
