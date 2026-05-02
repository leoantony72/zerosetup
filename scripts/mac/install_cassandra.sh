#!/bin/bash
# Install Apache Cassandra on macOS using Homebrew
echo "Installing Apache Cassandra..."

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Please install Homebrew first: https://brew.sh"
    exit 1
fi

brew install cassandra

# Start service
brew services start cassandra

# Configure environment variables
CASSANDRA_HOME="$(brew --prefix)/opt/cassandra"
PROFILE_FILES=(~/.zshrc ~/.bash_profile ~/.bashrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF "export CASSANDRA_HOME=$CASSANDRA_HOME" "$PROFILE" || echo "export CASSANDRA_HOME=$CASSANDRA_HOME" >> "$PROFILE"
        grep -qxF 'export CASSANDRA_HOST=127.0.0.1' "$PROFILE"       || echo 'export CASSANDRA_HOST=127.0.0.1'       >> "$PROFILE"
        grep -qxF 'export CASSANDRA_PORT=9042' "$PROFILE"            || echo 'export CASSANDRA_PORT=9042'            >> "$PROFILE"
        grep -qxF 'export PATH=$PATH:$CASSANDRA_HOME/bin' "$PROFILE" || echo 'export PATH=$PATH:$CASSANDRA_HOME/bin' >> "$PROFILE"
    fi
done

echo "Apache Cassandra installation complete."
echo "Default port: 9042 | Default host: 127.0.0.1"
echo "Access shell: cqlsh"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
