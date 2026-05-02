#!/bin/bash
# Install MySQL on Linux
echo "Installing MySQL..."

if command -v apt-get &>/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y mysql-server
    sudo systemctl enable mysql
    sudo systemctl start mysql
elif command -v dnf &>/dev/null; then
    sudo dnf install -y mysql-server
    sudo systemctl enable mysqld
    sudo systemctl start mysqld
elif command -v yum &>/dev/null; then
    sudo yum install -y mysql-server
    sudo systemctl enable mysqld
    sudo systemctl start mysqld
elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm mysql
    sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    sudo systemctl enable mysqld
    sudo systemctl start mysqld
else
    echo "Unsupported package manager. Please install MySQL manually."
    exit 1
fi

# Configure environment variables
PROFILE_FILES=(~/.bashrc ~/.zshrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export MYSQL_HOST=localhost' "$PROFILE" || echo 'export MYSQL_HOST=localhost' >> "$PROFILE"
        grep -qxF 'export MYSQL_PORT=3306' "$PROFILE"       || echo 'export MYSQL_PORT=3306'       >> "$PROFILE"
        grep -qxF 'export MYSQL_USER=root' "$PROFILE"       || echo 'export MYSQL_USER=root'       >> "$PROFILE"
    fi
done

echo "MySQL installation complete."
echo "Default port: 3306 | Default user: root"
echo "Secure installation: sudo mysql_secure_installation"
echo "Access shell: sudo mysql -u root"
echo "Please restart your terminal or run 'source ~/.bashrc' to apply changes."
