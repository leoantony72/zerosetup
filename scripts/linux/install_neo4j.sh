#!/bin/bash
# Install Neo4j on Linux
echo "Installing Neo4j..."

if command -v apt-get &>/dev/null; then
    curl -fsSL https://debian.neo4j.com/neotechnology.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/neo4j.gpg
    echo "deb [signed-by=/usr/share/keyrings/neo4j.gpg] https://debian.neo4j.com stable latest" \
        | sudo tee /etc/apt/sources.list.d/neo4j.list
    sudo apt-get update -y
    sudo apt-get install -y neo4j
    sudo systemctl enable neo4j
    sudo systemctl start neo4j
elif command -v dnf &>/dev/null || command -v yum &>/dev/null; then
    PKG_MGR=$(command -v dnf || command -v yum)
    sudo rpm --import https://debian.neo4j.com/neotechnology.gpg.key
    cat <<EOF | sudo tee /etc/yum.repos.d/neo4j.repo
[neo4j]
name=Neo4j Yum Repo
baseurl=https://yum.neo4j.com/stable/5
enabled=1
gpgcheck=1
gpgkey=https://debian.neo4j.com/neotechnology.gpg.key
EOF
    sudo $PKG_MGR install -y neo4j
    sudo systemctl enable neo4j
    sudo systemctl start neo4j
else
    echo "Unsupported package manager. Please install Neo4j manually."
    exit 1
fi

# Configure environment variables
PROFILE_FILES=(~/.bashrc ~/.zshrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export NEO4J_HOME=/var/lib/neo4j' "$PROFILE" || echo 'export NEO4J_HOME=/var/lib/neo4j' >> "$PROFILE"
        grep -qxF 'export NEO4J_HOST=localhost' "$PROFILE"       || echo 'export NEO4J_HOST=localhost'       >> "$PROFILE"
        grep -qxF 'export NEO4J_HTTP_PORT=7474' "$PROFILE"       || echo 'export NEO4J_HTTP_PORT=7474'       >> "$PROFILE"
        grep -qxF 'export NEO4J_BOLT_PORT=7687' "$PROFILE"       || echo 'export NEO4J_BOLT_PORT=7687'       >> "$PROFILE"
    fi
done

echo "Neo4j installation complete."
echo "Browser UI: http://localhost:7474 | Bolt port: 7687"
echo "Default credentials: neo4j / neo4j (change on first login)"
echo "Please restart your terminal or run 'source ~/.bashrc' to apply changes."
