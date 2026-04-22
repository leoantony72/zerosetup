#!/bin/bash
# Install Build Essential using APT
echo "Installing C/C++ Build Tools..."
sudo apt update
sudo apt install -y build-essential gdb cmake

echo "C/C++ Build Tools installation complete."
