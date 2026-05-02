#!/bin/bash
# Install Apache Cassandra on Linux
echo "Installing Apache Cassandra..."

# Cassandra requires Java 11+
if ! command -v java &>/dev/null; then
    echo "Java not found. Installing OpenJDK 11..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -y && sudo apt-get install -y openjdk-11-jdk
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y java-11-openjdk
    elif command -v yum &>/dev/null; then
        sudo yum install -y java-11-openjdk
    fi
fi

if command -v apt-get &>/dev/null; then
    curl -fsSL https://downloads.apache.org/cassandra/KEYS | sudo gpg --dearmor -o /usr/share/keyrings/cassandra.gpg
    echo "deb [ signed-by=/usr/share/keyrings/cassandra.gpg ] https://debian.cassandra.apache.org 41x main" \
        | sudo tee /etc/apt/sources.list.d/cassandra.sources.list
    sudo apt-get update -y
    sudo apt-get install -y cassandra
    sudo systemctl enable cassandra
    sudo systemctl start cassandra
elif command -v dnf &>/dev/null || command -v yum &>/dev/null; then
    PKG_MGR=$(command -v dnf || command -v yum)
    cat <<EOF | sudo tee /etc/yum.repos.d/cassandra.repo
[cassandra]
name=Apache Cassandra
baseurl=https://redhat.cassandra.apache.org/41x/
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.apache.org/cassandra/KEYS
EOF
    sudo $PKG_MGR install -y cassandra
    sudo systemctl enable cassandra
    sudo systemctl start cassandra
else
    echo "Unsupported package manager. Installing Cassandra from tarball..."
    CASSANDRA_VERSION="4.1.7"
    wget "https://archive.apache.org/dist/cassandra/$CASSANDRA_VERSION/apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz" -O /tmp/cassandra.tar.gz
    sudo tar -xzf /tmp/cassandra.tar.gz -C /opt/
    sudo ln -sfn /opt/apache-cassandra-$CASSANDRA_VERSION /opt/cassandra
    rm /tmp/cassandra.tar.gz
    CASSANDRA_HOME="/opt/cassandra"
fi

# Configure environment variables
CASSANDRA_HOME=${CASSANDRA_HOME:-/usr}
PROFILE_FILES=(~/.bashrc ~/.zshrc)
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
echo "Please restart your terminal or run 'source ~/.bashrc' to apply changes."
