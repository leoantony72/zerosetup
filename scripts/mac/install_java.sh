#!/bin/bash
# Install OpenJDK using Homebrew
echo "Installing OpenJDK..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew first."
    exit 1
fi

brew install openjdk

# Homebrew openjdk requires a symlink for the system to find it
sudo ln -sfn $(brew --prefix)/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

echo 'export PATH="/usr/local/opt/openjdk/bin:$PATH"' >> ~/.zshrc
export CPPFLAGS="-I/usr/local/opt/openjdk/include" >> ~/.zshrc

echo "Java installation and environment setup complete."
