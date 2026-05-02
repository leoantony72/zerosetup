#!/bin/bash
# Install ClickHouse on macOS using Homebrew
echo "Installing ClickHouse..."

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Please install Homebrew first: https://brew.sh"
    exit 1
fi

brew install clickhouse

# Start service
brew services start clickhouse

# Configure environment variables
CLICKHOUSE_HOME="$(brew --prefix)/opt/clickhouse"
PROFILE_FILES=(~/.zshrc ~/.bash_profile ~/.bashrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF "export CLICKHOUSE_HOME=$CLICKHOUSE_HOME" "$PROFILE" || echo "export CLICKHOUSE_HOME=$CLICKHOUSE_HOME" >> "$PROFILE"
        grep -qxF 'export CLICKHOUSE_HOST=localhost' "$PROFILE"         || echo 'export CLICKHOUSE_HOST=localhost'         >> "$PROFILE"
        grep -qxF 'export CLICKHOUSE_PORT=9000' "$PROFILE"              || echo 'export CLICKHOUSE_PORT=9000'              >> "$PROFILE"
        grep -qxF 'export CLICKHOUSE_HTTP_PORT=8123' "$PROFILE"         || echo 'export CLICKHOUSE_HTTP_PORT=8123'         >> "$PROFILE"
        grep -qxF 'export CLICKHOUSE_USER=default' "$PROFILE"           || echo 'export CLICKHOUSE_USER=default'           >> "$PROFILE"
    fi
done

echo "ClickHouse installation complete."
echo "Default HTTP port: 8123 | Native port: 9000"
echo "Access CLI: clickhouse client --host=localhost"
echo "HTTP API: curl http://localhost:8123/?query=SELECT+version()"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
