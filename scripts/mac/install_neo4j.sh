#!/bin/bash
# Install Neo4j on macOS using Homebrew
echo "Installing Neo4j..."

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Please install Homebrew first: https://brew.sh"
    exit 1
fi

brew install neo4j

# Start service
brew services start neo4j

# Configure environment variables
NEO4J_HOME="$(brew --prefix)/opt/neo4j"
PROFILE_FILES=(~/.zshrc ~/.bash_profile ~/.bashrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF "export NEO4J_HOME=$NEO4J_HOME" "$PROFILE" || echo "export NEO4J_HOME=$NEO4J_HOME" >> "$PROFILE"
        grep -qxF 'export NEO4J_HOST=localhost' "$PROFILE"    || echo 'export NEO4J_HOST=localhost'    >> "$PROFILE"
        grep -qxF 'export NEO4J_HTTP_PORT=7474' "$PROFILE"    || echo 'export NEO4J_HTTP_PORT=7474'    >> "$PROFILE"
        grep -qxF 'export NEO4J_BOLT_PORT=7687' "$PROFILE"    || echo 'export NEO4J_BOLT_PORT=7687'    >> "$PROFILE"
    fi
done

echo "Neo4j installation complete."
echo "Browser UI: http://localhost:7474 | Bolt port: 7687"
echo "Default credentials: neo4j / neo4j (change on first login)"
echo "Access console: neo4j console"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
