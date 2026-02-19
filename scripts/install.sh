#!/bin/bash

# Rocket Panel 2026 Installer
# ACGDEV Team

echo "=================================================="
echo "   Rocket Panel 2026 - Installation Script"
echo "=================================================="

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Update System
echo "[+] Updating System..."
apt-get update -y && apt-get upgrade -y

# Install Docker if not exists
if ! command -v docker &> /dev/null
then
    echo "[+] Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    echo "[+] Docker is already installed."
fi

# Install Docker Compose (V2 plugin is usually included now, checking for compose)
echo "[+] Checking Docker Compose..."
docker compose version || apt-get install -y docker-compose-plugin

# Setup Directory
INSTALL_DIR="/opt/rocket-panel"
if [ "$PWD" != "$INSTALL_DIR" ]; then
    echo "[+] Setting up directory at $INSTALL_DIR..."
    mkdir -p $INSTALL_DIR
    cp -r . $INSTALL_DIR
    cd $INSTALL_DIR
fi

# Generate Random Secret Key
echo "[+] Configuring Security..."
sed -i "s/changeme_in_production/$(openssl rand -hex 32)/g" docker-compose.yml

# Start Services
echo "[+] Starting Services..."
docker compose up -d --build

echo "=================================================="
echo "   Installation Complete!"
echo "   Access your panel at: http://YOUR_SERVER_IP:3000"
echo "=================================================="
