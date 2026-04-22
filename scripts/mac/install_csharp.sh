#!/bin/bash
# Install .NET SDK using Homebrew
echo "Installing .NET SDK..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew first."
    exit 1
fi

brew install dotnet-sdk

echo ".NET SDK installation complete."
