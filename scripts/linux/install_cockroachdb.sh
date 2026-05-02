#!/bin/bash
# Install CockroachDB on Linux
echo "Installing CockroachDB..."

CRDB_VERSION="v24.3.4"
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
fi

DOWNLOAD_URL="https://binaries.cockroachdb.com/cockroach-$CRDB_VERSION.linux-$ARCH.tgz"
echo "Downloading CockroachDB $CRDB_VERSION ($ARCH)..."
curl -L "$DOWNLOAD_URL" -o /tmp/cockroach.tgz

echo "Extracting CockroachDB..."
tar -xzf /tmp/cockroach.tgz -C /tmp/
EXTRACTED_DIR=$(find /tmp -maxdepth 1 -name "cockroach-*" -type d | head -1)

sudo cp "$EXTRACTED_DIR/cockroach" /usr/local/bin/
sudo chmod +x /usr/local/bin/cockroach

# Copy libs if present
if [ -d "$EXTRACTED_DIR/lib" ]; then
    sudo mkdir -p /usr/local/lib/cockroach
    sudo cp "$EXTRACTED_DIR/lib/"* /usr/local/lib/cockroach/
fi

rm -rf /tmp/cockroach.tgz "$EXTRACTED_DIR"

# Create data directory
sudo mkdir -p /var/lib/cockroach
sudo chown "$USER:$USER" /var/lib/cockroach

# Configure environment variables
PROFILE_FILES=(~/.bashrc ~/.zshrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export COCKROACHDB_HOST=localhost' "$PROFILE"      || echo 'export COCKROACHDB_HOST=localhost'      >> "$PROFILE"
        grep -qxF 'export COCKROACHDB_PORT=26257' "$PROFILE"          || echo 'export COCKROACHDB_PORT=26257'          >> "$PROFILE"
        grep -qxF 'export COCKROACHDB_HTTP_PORT=8080' "$PROFILE"      || echo 'export COCKROACHDB_HTTP_PORT=8080'      >> "$PROFILE"
        grep -qxF 'export COCKROACHDB_DATA=/var/lib/cockroach' "$PROFILE" || echo 'export COCKROACHDB_DATA=/var/lib/cockroach' >> "$PROFILE"
    fi
done

echo "CockroachDB installation complete."
echo "Default SQL port: 26257 | Admin UI port: 8080"
echo "Start a dev node: cockroach start-single-node --insecure --listen-addr=localhost:26257 --http-addr=localhost:8080 --store=/var/lib/cockroach"
echo "Connect SQL: cockroach sql --insecure --host=localhost:26257"
echo "Please restart your terminal or run 'source ~/.bashrc' to apply changes."
