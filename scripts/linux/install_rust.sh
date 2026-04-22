#!/bin/bash
# Install Rust using rustup
echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Configure Environment Variables
source "$HOME/.cargo/env"
echo 'source "$HOME/.cargo/env"' >> ~/.bashrc
if [ -f ~/.zshrc ]; then
    echo 'source "$HOME/.cargo/env"' >> ~/.zshrc
fi

echo "Rust installation complete."
