#!/bin/bash
# Install Node.js using Homebrew
echo "Installing Node.js..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew first."
    exit 1
fi

brew install node

echo "Node.js installation complete."
