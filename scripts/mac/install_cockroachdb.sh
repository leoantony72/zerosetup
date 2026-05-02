#!/bin/bash
# Install CockroachDB on macOS using Homebrew
echo "Installing CockroachDB..."

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Please install Homebrew first: https://brew.sh"
    exit 1
fi

brew install cockroachdb/tap/cockroach

# Create data directory
mkdir -p "$HOME/cockroach-data"

# Configure environment variables
PROFILE_FILES=(~/.zshrc ~/.bash_profile ~/.bashrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export COCKROACHDB_HOST=localhost'           "$PROFILE" || echo 'export COCKROACHDB_HOST=localhost'           >> "$PROFILE"
        grep -qxF 'export COCKROACHDB_PORT=26257'              "$PROFILE" || echo 'export COCKROACHDB_PORT=26257'              >> "$PROFILE"
        grep -qxF 'export COCKROACHDB_HTTP_PORT=8080'          "$PROFILE" || echo 'export COCKROACHDB_HTTP_PORT=8080'          >> "$PROFILE"
        grep -qxF "export COCKROACHDB_DATA=$HOME/cockroach-data" "$PROFILE" || echo "export COCKROACHDB_DATA=$HOME/cockroach-data" >> "$PROFILE"
    fi
done

echo "CockroachDB installation complete."
echo "Default SQL port: 26257 | Admin UI port: 8080"
echo "Start dev node: cockroach start-single-node --insecure --listen-addr=localhost:26257 --http-addr=localhost:8080"
echo "Connect SQL: cockroach sql --insecure --host=localhost:26257"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
