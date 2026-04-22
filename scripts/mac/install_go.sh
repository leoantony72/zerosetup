#!/bin/bash
# Install Go (Golang) using Homebrew
echo "Installing Go (Golang)..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew first."
    exit 1
fi

brew install go

# Configure Environment Variables
echo 'export GOPATH=$HOME/go' >> ~/.zshrc
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.zshrc

echo "Go installation and environment setup complete."
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
