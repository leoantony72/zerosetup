#!/bin/bash
# Install PostgreSQL on macOS using Homebrew
echo "Installing PostgreSQL..."

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Please install Homebrew first: https://brew.sh"
    exit 1
fi

brew install postgresql@17
brew link postgresql@17 --force

# Start service
brew services start postgresql@17

# Configure environment variables
PROFILE_FILES=(~/.zshrc ~/.bash_profile ~/.bashrc)
PG_BIN="$(brew --prefix)/opt/postgresql@17/bin"
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF "export PATH=\"$PG_BIN:\$PATH\"" "$PROFILE" || echo "export PATH=\"$PG_BIN:\$PATH\"" >> "$PROFILE"
        grep -qxF 'export PGHOST=localhost'  "$PROFILE" || echo 'export PGHOST=localhost'  >> "$PROFILE"
        grep -qxF 'export PGPORT=5432'       "$PROFILE" || echo 'export PGPORT=5432'       >> "$PROFILE"
        grep -qxF "export PGUSER=$USER"      "$PROFILE" || echo "export PGUSER=$USER"      >> "$PROFILE"
    fi
done

echo "PostgreSQL installation complete."
echo "Default port: 5432 | Default user: $USER"
echo "Access shell: psql postgres"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
