#!/bin/bash
# Install Redis on macOS using Homebrew
echo "Installing Redis..."

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Please install Homebrew first: https://brew.sh"
    exit 1
fi

brew install redis

# Start service
brew services start redis

# Configure environment variables
PROFILE_FILES=(~/.zshrc ~/.bash_profile ~/.bashrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export REDIS_HOST=127.0.0.1' "$PROFILE" || echo 'export REDIS_HOST=127.0.0.1' >> "$PROFILE"
        grep -qxF 'export REDIS_PORT=6379' "$PROFILE"       || echo 'export REDIS_PORT=6379'       >> "$PROFILE"
    fi
done

echo "Redis installation complete."
echo "Default host: 127.0.0.1 | Default port: 6379"
echo "Access CLI: redis-cli"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
