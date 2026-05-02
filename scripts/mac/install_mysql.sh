#!/bin/bash
# Install MySQL on macOS using Homebrew
echo "Installing MySQL..."

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Please install Homebrew first: https://brew.sh"
    exit 1
fi

brew install mysql

# Start service
brew services start mysql

# Configure environment variables
PROFILE_FILES=(~/.zshrc ~/.bash_profile ~/.bashrc)
MYSQL_BIN="$(brew --prefix)/opt/mysql/bin"
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF "export PATH=\"$MYSQL_BIN:\$PATH\"" "$PROFILE" || echo "export PATH=\"$MYSQL_BIN:\$PATH\"" >> "$PROFILE"
        grep -qxF 'export MYSQL_HOST=localhost' "$PROFILE" || echo 'export MYSQL_HOST=localhost' >> "$PROFILE"
        grep -qxF 'export MYSQL_PORT=3306' "$PROFILE"      || echo 'export MYSQL_PORT=3306'      >> "$PROFILE"
        grep -qxF 'export MYSQL_USER=root' "$PROFILE"      || echo 'export MYSQL_USER=root'      >> "$PROFILE"
    fi
done

echo "MySQL installation complete."
echo "Default port: 3306 | Default user: root (no password)"
echo "Secure installation: mysql_secure_installation"
echo "Access shell: mysql -u root"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
