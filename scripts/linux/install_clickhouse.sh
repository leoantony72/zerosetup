#!/bin/bash
# Install ClickHouse on Linux
echo "Installing ClickHouse..."

if command -v apt-get &>/dev/null; then
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
    curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | sudo gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg arch=amd64,arm64] https://packages.clickhouse.com/deb stable main" \
        | sudo tee /etc/apt/sources.list.d/clickhouse.list
    sudo apt-get update -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y clickhouse-server clickhouse-client
    sudo systemctl enable clickhouse-server
    sudo systemctl start clickhouse-server
elif command -v dnf &>/dev/null || command -v yum &>/dev/null; then
    PKG_MGR=$(command -v dnf || command -v yum)
    sudo $PKG_MGR install -y yum-utils
    sudo $PKG_MGR config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo
    sudo $PKG_MGR install -y clickhouse-server clickhouse-client
    sudo systemctl enable clickhouse-server
    sudo systemctl start clickhouse-server
else
    echo "Installing ClickHouse from tarball..."
    CH_VERSION="24.12.3.47"
    ARCH=$(uname -m)
    wget "https://github.com/ClickHouse/ClickHouse/releases/download/v$CH_VERSION-stable/clickhouse-common-static-$CH_VERSION-$ARCH.tgz" -O /tmp/clickhouse.tgz
    tar -xzf /tmp/clickhouse.tgz -C /tmp/
    sudo bash /tmp/clickhouse-common-static-$CH_VERSION/install/doinst.sh
    rm /tmp/clickhouse.tgz
fi

# Configure environment variables
PROFILE_FILES=(~/.bashrc ~/.zshrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export CLICKHOUSE_HOST=localhost' "$PROFILE"      || echo 'export CLICKHOUSE_HOST=localhost'      >> "$PROFILE"
        grep -qxF 'export CLICKHOUSE_PORT=9000' "$PROFILE"           || echo 'export CLICKHOUSE_PORT=9000'           >> "$PROFILE"
        grep -qxF 'export CLICKHOUSE_HTTP_PORT=8123' "$PROFILE"      || echo 'export CLICKHOUSE_HTTP_PORT=8123'      >> "$PROFILE"
        grep -qxF 'export CLICKHOUSE_USER=default' "$PROFILE"        || echo 'export CLICKHOUSE_USER=default'        >> "$PROFILE"
    fi
done

echo "ClickHouse installation complete."
echo "Default HTTP port: 8123 | Native port: 9000"
echo "Access CLI: clickhouse-client --host=localhost"
echo "HTTP API: curl http://localhost:8123/?query=SELECT+version()"
echo "Please restart your terminal or run 'source ~/.bashrc' to apply changes."
