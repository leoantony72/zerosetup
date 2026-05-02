#!/bin/bash
# Install MongoDB on Linux
echo "Installing MongoDB..."

if command -v apt-get &>/dev/null; then
    # Import MongoDB public key and add repo (Ubuntu/Debian)
    curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/8.0 multiverse" \
        | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
    sudo apt-get update -y
    sudo apt-get install -y mongodb-org
    sudo systemctl enable mongod
    sudo systemctl start mongod
elif command -v dnf &>/dev/null; then
    cat <<EOF | sudo tee /etc/yum.repos.d/mongodb-org-8.0.repo
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-8.0.asc
EOF
    sudo dnf install -y mongodb-org
    sudo systemctl enable mongod
    sudo systemctl start mongod
elif command -v pacman &>/dev/null; then
    # AUR based - use yay if available
    if command -v yay &>/dev/null; then
        yay -S --noconfirm mongodb-bin
    else
        echo "Install yay (AUR helper) and re-run, or install MongoDB manually."
        exit 1
    fi
else
    echo "Unsupported package manager. Please install MongoDB manually."
    exit 1
fi

# Configure environment variables
PROFILE_FILES=(~/.bashrc ~/.zshrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export MONGODB_HOST=localhost' "$PROFILE" || echo 'export MONGODB_HOST=localhost'          >> "$PROFILE"
        grep -qxF 'export MONGODB_PORT=27017' "$PROFILE"     || echo 'export MONGODB_PORT=27017'              >> "$PROFILE"
        grep -qxF 'export MONGODB_URI=mongodb://localhost:27017' "$PROFILE" || echo 'export MONGODB_URI=mongodb://localhost:27017' >> "$PROFILE"
    fi
done

echo "MongoDB installation complete."
echo "Default port: 27017 | Connection string: mongodb://localhost:27017"
echo "Access shell: mongosh"
echo "Please restart your terminal or run 'source ~/.bashrc' to apply changes."
