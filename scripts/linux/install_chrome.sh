#!/bin/bash
# Install Google Chrome using APT and dpkg
echo "Downloading Google Chrome..."
wget -q -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

echo "Installing Google Chrome..."
sudo apt-get install -y /tmp/google-chrome-stable_current_amd64.deb

echo "Cleaning up..."
rm /tmp/google-chrome-stable_current_amd64.deb

echo "Google Chrome installation complete."
