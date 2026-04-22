#!/bin/bash
# Install ProtonVPN using official apt repository
echo "Installing ProtonVPN..."
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb
sudo apt update
sudo apt install proton-vpn-cli -y
rm ./protonvpn-stable-release_1.0.8_all.deb
echo "ProtonVPN installation complete."
