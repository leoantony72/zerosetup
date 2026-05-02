#!/bin/bash
# Install MariaDB on macOS using Homebrew
echo "Installing MariaDB..."

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Please install Homebrew first: https://brew.sh"
    exit 1
fi

brew install mariadb

# Start service
brew services start mariadb

# Configure environment variables
PROFILE_FILES=(~/.zshrc ~/.bash_profile ~/.bashrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export MARIADB_HOST=localhost' "$PROFILE" || echo 'export MARIADB_HOST=localhost' >> "$PROFILE"
        grep -qxF 'export MARIADB_PORT=3306' "$PROFILE"      || echo 'export MARIADB_PORT=3306'      >> "$PROFILE"
        grep -qxF 'export MARIADB_USER=root' "$PROFILE"      || echo 'export MARIADB_USER=root'      >> "$PROFILE"
    fi
done

echo "MariaDB installation complete."
echo "Default port: 3306 | Default user: root (no password)"
echo "Secure installation: mysql_secure_installation"
echo "Access shell: mariadb -u root"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
