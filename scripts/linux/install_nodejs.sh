#!/bin/bash
# Install Node.js using APT
echo "Installing Node.js..."
sudo apt update
sudo apt install -y nodejs npm

# Node on Ubuntu often has naming conflicts or old versions, but for "zerosetup" we follow standard apt.
# Ensure npm global bin is in PATH
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
NPM_EXPORT='export PATH=$PATH:~/.npm-global/bin'

grep -qF "$NPM_EXPORT" ~/.bashrc || echo "$NPM_EXPORT" >> ~/.bashrc
if [ -f ~/.zshrc ]; then
    grep -qF "$NPM_EXPORT" ~/.zshrc || echo "$NPM_EXPORT" >> ~/.zshrc
fi

echo "Node.js installation and environment setup complete."
