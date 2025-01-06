#!/bin/bash

echo "Starting the complete uninstallation of Node.js and related dependencies..."

# Step 1: Uninstall Node.js and npm
echo "Removing Node.js and npm..."
sudo apt-get purge --auto-remove nodejs npm -y

# Step 2: Remove NodeSource repository and GPG key
echo "Removing NodeSource repository and GPG key..."
sudo rm -f /etc/apt/sources.list.d/nodesource.list
sudo rm -f /usr/share/keyrings/nodesource.gpg
sudo rm -f /etc/apt/keyrings/nodesource.gpg

# Step 3: Remove global npm modules
echo "Removing globally installed npm modules..."
sudo rm -rf /usr/local/lib/node_modules
sudo rm -rf ~/.npm
sudo rm -rf ~/.node-gyp

# Step 4: Remove Node.js binaries and config files
echo "Removing Node.js binaries and configuration files..."
sudo rm -rf /usr/local/bin/node
sudo rm -rf /usr/local/bin/npm
sudo rm -rf /usr/local/bin/npx
sudo rm -rf /usr/lib/node_modules

# Step 5: Clean up APT cache
echo "Cleaning up APT cache and unnecessary packages..."
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo apt-get clean

# Step 6: Verify Node.js removal
if ! command -v node >/dev/null 2>&1 && ! command -v npm >/dev/null 2>&1; then
  echo "Node.js and npm successfully uninstalled!"
else
  echo "Node.js or npm is still installed. Please check manually."
fi

# Step 7: (Optional) Remove nvm if installed
if [ -d "$HOME/.nvm" ]; then
  echo "Removing nvm (Node Version Manager)..."
  rm -rf ~/.nvm
fi

# Step 8: (Optional) Remove manually installed Node.js binaries
echo "Checking for custom Node.js installations..."
sudo rm -rf /usr/local/include/node
sudo rm -rf /usr/local/lib/node
sudo rm -rf /usr/local/bin/node
sudo rm -rf /usr/local/share/man/man1/node*

echo "Node.js uninstallation completed."
