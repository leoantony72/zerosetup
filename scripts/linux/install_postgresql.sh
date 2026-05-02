#!/bin/bash
# Install PostgreSQL on Linux
echo "Installing PostgreSQL..."

# Detect distro
if command -v apt-get &>/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y postgresql postgresql-contrib
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
elif command -v dnf &>/dev/null; then
    sudo dnf install -y postgresql-server postgresql-contrib
    sudo postgresql-setup --initdb
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
elif command -v yum &>/dev/null; then
    sudo yum install -y postgresql-server postgresql-contrib
    sudo postgresql-setup initdb
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm postgresql
    sudo -u postgres initdb -D /var/lib/postgres/data
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
else
    echo "Unsupported package manager. Please install PostgreSQL manually."
    exit 1
fi

# Configure environment variables
PROFILE_FILES=(~/.bashrc ~/.zshrc)
for PROFILE in "${PROFILE_FILES[@]}"; do
    if [ -f "$PROFILE" ]; then
        grep -qxF 'export PGHOST=localhost' "$PROFILE" || echo 'export PGHOST=localhost' >> "$PROFILE"
        grep -qxF 'export PGPORT=5432' "$PROFILE"       || echo 'export PGPORT=5432'       >> "$PROFILE"
        grep -qxF 'export PGUSER=postgres' "$PROFILE"   || echo 'export PGUSER=postgres'   >> "$PROFILE"
    fi
done

echo "PostgreSQL installation complete."
echo "Default port: 5432 | Default user: postgres"
echo "Access shell: sudo -u postgres psql"
echo "Please restart your terminal or run 'source ~/.bashrc' to apply changes."
