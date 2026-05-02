#!/bin/bash
# Install Redis on Linux
echo "Installing Redis..."

if command -v apt-get &>/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y redis-server
    sudo systemctl enable redis-server
    sudo systemctl start redis-server
elif command -v dnf &>/dev/null; then
    sudo dnf install -y redis
    sudo systemctl enable redis
    sudo systemctl start redis
elif command -v yum &>/dev/null; then
    sudo yum install -y redis
    sudo systemctl enable redis
    sudo systemctl start redis
elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm redis
    sudo systemctl enable redis
    sudo systemctl start redis
else
    echo "Unsupported package manager. Please install Redis manually."
    exit 1
fi

# Configure environment variables
PROFILE_FILES=(~/.bashrc ~/.zshrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export REDIS_HOST=127.0.0.1' "$PROFILE" || echo 'export REDIS_HOST=127.0.0.1' >> "$PROFILE"
        grep -qxF 'export REDIS_PORT=6379' "$PROFILE"       || echo 'export REDIS_PORT=6379'       >> "$PROFILE"
    fi
done

echo "Redis installation complete."
echo "Default host: 127.0.0.1 | Default port: 6379"
echo "Access CLI: redis-cli"
echo "Please restart your terminal or run 'source ~/.bashrc' to apply changes."
