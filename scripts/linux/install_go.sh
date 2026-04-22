#!/bin/bash
# Install Go (Golang) using APT
echo "Installing Go (Golang)..."
sudo apt update
sudo apt install -y golang-go

# Configure Environment Variables
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.bashrc

if [ -f ~/.zshrc ]; then
    echo 'export GOPATH=$HOME/go' >> ~/.zshrc
    echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.zshrc
fi

echo "Go installation and environment setup complete."
echo "Please restart your terminal or run 'source ~/.bashrc' to apply changes."
