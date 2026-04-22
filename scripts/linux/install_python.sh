#!/bin/bash
# Install Python using APT
echo "Installing Python..."
sudo apt update
sudo apt install -y python3 python3-pip python3-venv

# Profile updates are usually not needed for standard apt python, but let's ensure ~/.local/bin is in PATH
LOCAL_BIN='export PATH=$PATH:$HOME/.local/bin'
grep -qF "$LOCAL_BIN" ~/.bashrc || echo "$LOCAL_BIN" >> ~/.bashrc
if [ -f ~/.zshrc ]; then
    grep -qF "$LOCAL_BIN" ~/.zshrc || echo "$LOCAL_BIN" >> ~/.zshrc
fi

echo "Python installation complete."
