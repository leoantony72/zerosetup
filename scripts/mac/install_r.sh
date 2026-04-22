#!/bin/bash
# Install R using Homebrew
echo "Installing R..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew first."
    exit 1
fi

brew install r

echo "R installation complete."
