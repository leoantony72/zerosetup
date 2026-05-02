#!/bin/bash
# Install MariaDB on Linux
echo "Installing MariaDB..."

if command -v apt-get &>/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y mariadb-server mariadb-client
    sudo systemctl enable mariadb
    sudo systemctl start mariadb
elif command -v dnf &>/dev/null; then
    sudo dnf install -y mariadb-server mariadb
    sudo systemctl enable mariadb
    sudo systemctl start mariadb
elif command -v yum &>/dev/null; then
    sudo yum install -y mariadb-server mariadb
    sudo systemctl enable mariadb
    sudo systemctl start mariadb
elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm mariadb
    sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    sudo systemctl enable mariadb
    sudo systemctl start mariadb
else
    echo "Unsupported package manager. Please install MariaDB manually."
    exit 1
fi

# Configure environment variables
PROFILE_FILES=(~/.bashrc ~/.zshrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export MARIADB_HOST=localhost' "$PROFILE" || echo 'export MARIADB_HOST=localhost' >> "$PROFILE"
        grep -qxF 'export MARIADB_PORT=3306' "$PROFILE"      || echo 'export MARIADB_PORT=3306'      >> "$PROFILE"
        grep -qxF 'export MARIADB_USER=root' "$PROFILE"      || echo 'export MARIADB_USER=root'      >> "$PROFILE"
    fi
done

echo "MariaDB installation complete."
echo "Default port: 3306 | Default user: root"
echo "Secure installation: sudo mysql_secure_installation"
echo "Access shell: sudo mariadb -u root"
echo "Please restart your terminal or run 'source ~/.bashrc' to apply changes."
