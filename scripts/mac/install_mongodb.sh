#!/bin/bash
# Install MongoDB on macOS using Homebrew
echo "Installing MongoDB..."

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Please install Homebrew first: https://brew.sh"
    exit 1
fi

brew tap mongodb/brew
brew install mongodb-community@8.0

# Start service
brew services start mongodb/brew/mongodb-community@8.0

# Configure environment variables
PROFILE_FILES=(~/.zshrc ~/.bash_profile ~/.bashrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export MONGODB_HOST=localhost' "$PROFILE"                    || echo 'export MONGODB_HOST=localhost'                    >> "$PROFILE"
        grep -qxF 'export MONGODB_PORT=27017' "$PROFILE"                        || echo 'export MONGODB_PORT=27017'                        >> "$PROFILE"
        grep -qxF 'export MONGODB_URI=mongodb://localhost:27017' "$PROFILE"     || echo 'export MONGODB_URI=mongodb://localhost:27017'     >> "$PROFILE"
    fi
done

echo "MongoDB installation complete."
echo "Default port: 27017 | Connection string: mongodb://localhost:27017"
echo "Access shell: mongosh"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
