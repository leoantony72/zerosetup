#!/bin/bash
# Install Python using Homebrew
echo "Installing Python..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew first."
    exit 1
fi

brew install python

echo "Python installation complete."
