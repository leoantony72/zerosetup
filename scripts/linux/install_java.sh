#!/bin/bash
# Install Default JDK using APT
echo "Installing Java (Default JDK)..."
sudo apt update
sudo apt install -y default-jdk

# Find JAVA_HOME
JAVA_PATH=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "export JAVA_HOME=$JAVA_PATH" >> ~/.bashrc
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc

if [ -f ~/.zshrc ]; then
    echo "export JAVA_HOME=$JAVA_PATH" >> ~/.zshrc
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.zshrc
fi

echo "Java installation and environment setup complete."
