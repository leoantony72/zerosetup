#!/bin/bash
# Install .NET SDK using APT
echo "Installing .NET SDK 8..."
sudo apt update
sudo apt install -y dotnet-sdk-8.0

# Add .NET tools to PATH
DOTNET_TOOLS='export PATH=$PATH:$HOME/.dotnet/tools'
grep -qF "$DOTNET_TOOLS" ~/.bashrc || echo "$DOTNET_TOOLS" >> ~/.bashrc
if [ -f ~/.zshrc ]; then
    grep -qF "$DOTNET_TOOLS" ~/.zshrc || echo "$DOTNET_TOOLS" >> ~/.zshrc
fi

echo ".NET SDK installation complete."
