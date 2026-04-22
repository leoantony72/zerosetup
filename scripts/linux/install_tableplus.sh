#!/bin/bash
# Install TablePlus using official apt repository
echo "Installing TablePlus..."
wget -qO - https://deb.tableplus.com/apt.tableplus.com.gpg.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/tableplus-archive.gpg > /dev/null
# Detect Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs | cut -d. -f1)
sudo add-apt-repository "deb [arch=amd64] https://deb.tableplus.com/debian/$UBUNTU_VERSION tableplus main" -y
sudo apt update
sudo apt install tableplus -y
echo "TablePlus installation complete."
