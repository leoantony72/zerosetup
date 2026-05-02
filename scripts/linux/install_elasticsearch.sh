#!/bin/bash
# Install Elasticsearch on Linux
echo "Installing Elasticsearch..."

if command -v apt-get &>/dev/null; then
    curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" \
        | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
    sudo apt-get update -y
    sudo apt-get install -y elasticsearch
elif command -v dnf &>/dev/null || command -v yum &>/dev/null; then
    PKG_MGR=$(command -v dnf || command -v yum)
    sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
    cat <<EOF | sudo tee /etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
    sudo $PKG_MGR install -y elasticsearch
else
    echo "Unsupported package manager. Installing Elasticsearch from tarball..."
    ES_VERSION="8.17.0"
    wget "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION-linux-x86_64.tar.gz" -O /tmp/elasticsearch.tar.gz
    sudo tar -xzf /tmp/elasticsearch.tar.gz -C /opt/
    sudo ln -sfn /opt/elasticsearch-$ES_VERSION /opt/elasticsearch
    rm /tmp/elasticsearch.tar.gz
fi

# Disable security for dev mode
ES_CONFIG="/etc/elasticsearch/elasticsearch.yml"
if [ -f "$ES_CONFIG" ]; then
    sudo bash -c "echo 'xpack.security.enabled: false' >> $ES_CONFIG"
    sudo bash -c "echo 'xpack.security.http.ssl.enabled: false' >> $ES_CONFIG"
fi

# Enable and start service
if command -v systemctl &>/dev/null; then
    sudo systemctl daemon-reload
    sudo systemctl enable elasticsearch
    sudo systemctl start elasticsearch
fi

# Configure environment variables
ES_HOME=${ES_HOME:-/usr/share/elasticsearch}
PROFILE_FILES=(~/.bashrc ~/.zshrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export ES_HOST=localhost' "$PROFILE"  || echo 'export ES_HOST=localhost'  >> "$PROFILE"
        grep -qxF 'export ES_PORT=9200' "$PROFILE"       || echo 'export ES_PORT=9200'       >> "$PROFILE"
        grep -qxF "export ES_HOME=$ES_HOME" "$PROFILE"   || echo "export ES_HOME=$ES_HOME"   >> "$PROFILE"
    fi
done

echo "Elasticsearch installation complete."
echo "Default HTTP port: 9200 | Transport port: 9300"
echo "Health check: curl http://localhost:9200/_cluster/health"
echo "Please restart your terminal or run 'source ~/.bashrc' to apply changes."
