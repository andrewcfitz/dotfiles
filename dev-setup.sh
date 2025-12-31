#!/bin/bash
# Development container setup script
# Edit this file and restart the container to apply changes

set -e

echo "Installing packages..."
sudo apt-get update
sudo apt-get install -y zsh tmux screen

# Install Oh My Zsh (if not already installed)
if [ ! -d ~/.oh-my-zsh ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k theme (if not already installed)
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  # Set Powerlevel10k as the theme in .zshrc
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
fi

# Change default shell to zsh
sudo chsh -s /bin/zsh developer

ln -s /Users/andrew/workspace/dotfiles/.zshrc ~/.zshrc
ln -s /Users/andrew/workspace/dotfiles/.gitconfig ~/.gitconfig
ln -s /Users/andrew/workspace/dotfiles/.p10k.zsh ~/.p10k.zsh

echo "Setup complete!"
