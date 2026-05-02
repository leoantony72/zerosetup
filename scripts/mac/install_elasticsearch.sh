#!/bin/bash
# Install Elasticsearch on macOS using Homebrew
echo "Installing Elasticsearch..."

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Please install Homebrew first: https://brew.sh"
    exit 1
fi

brew tap elastic/tap
brew install elastic/tap/elasticsearch-full

# Disable security for dev mode
ES_CONFIG="$(brew --prefix)/etc/elasticsearch/elasticsearch.yml"
if [ -f "$ES_CONFIG" ]; then
    grep -qxF 'xpack.security.enabled: false' "$ES_CONFIG" || echo 'xpack.security.enabled: false' >> "$ES_CONFIG"
    grep -qxF 'xpack.security.http.ssl.enabled: false' "$ES_CONFIG" || echo 'xpack.security.http.ssl.enabled: false' >> "$ES_CONFIG"
fi

# Start service
brew services start elastic/tap/elasticsearch-full

# Configure environment variables
ES_HOME="$(brew --prefix)/opt/elasticsearch-full"
PROFILE_FILES=(~/.zshrc ~/.bash_profile ~/.bashrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF "export ES_HOME=$ES_HOME" "$PROFILE" || echo "export ES_HOME=$ES_HOME" >> "$PROFILE"
        grep -qxF 'export ES_HOST=localhost' "$PROFILE" || echo 'export ES_HOST=localhost' >> "$PROFILE"
        grep -qxF 'export ES_PORT=9200' "$PROFILE"      || echo 'export ES_PORT=9200'      >> "$PROFILE"
    fi
done

echo "Elasticsearch installation complete."
echo "Default HTTP port: 9200 | Transport port: 9300"
echo "Health check: curl http://localhost:9200/_cluster/health"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
