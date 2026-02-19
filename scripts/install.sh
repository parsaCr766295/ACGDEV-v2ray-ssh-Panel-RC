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

# Install Git and Docker if not exists
if ! command -v git &> /dev/null; then
    echo "[+] Installing Git..."
    apt-get install -y git
fi

if ! command -v docker &> /dev/null; then
    echo "[+] Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    echo "[+] Docker is already installed."
fi

# Install Docker Compose
echo "[+] Checking Docker Compose..."
docker compose version || apt-get install -y docker-compose-plugin

# Setup Directory & Clone Repo
INSTALL_DIR="/opt/rocket-panel"
REPO_URL="https://github.com/parsaCr766295/ACGDEV-v2ray-ssh-Panel-RC.git"

if [ -d "$INSTALL_DIR" ]; then
    echo "[+] Directory $INSTALL_DIR exists. Pulling latest changes..."
    cd $INSTALL_DIR
    git pull
else
    echo "[+] Cloning repository to $INSTALL_DIR..."
    git clone $REPO_URL $INSTALL_DIR
    cd $INSTALL_DIR
fi

# Generate Random Secret Key
echo "[+] Configuring Security..."
# Only replace if not already replaced (to avoid messing up existing configs on reinstall)
if grep -q "changeme_in_production" docker-compose.yml; then
    sed -i "s/changeme_in_production/$(openssl rand -hex 32)/g" docker-compose.yml
fi

# Start Services
echo "[+] Starting Services..."
docker compose up -d --build

echo "=================================================="
echo "   Installation Complete!"
echo "   Access your panel at: http://$(curl -s ifconfig.me):3000"
echo "=================================================="
