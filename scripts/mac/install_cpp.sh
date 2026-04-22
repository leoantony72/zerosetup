#!/bin/bash
# Install GCC using Homebrew
echo "Installing C/C++ Build Tools (GCC)..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew first."
    exit 1
fi

brew install gcc cmake

echo "C/C++ Build Tools installation complete."
