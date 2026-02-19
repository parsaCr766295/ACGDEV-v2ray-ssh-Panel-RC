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

# Install Basic Dependencies
echo "[+] Installing Dependencies..."
apt-get install -y git curl wget

# Install Docker if not exists
if ! command -v docker &> /dev/null; then
    echo "[+] Installing Docker using convenience script..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    # Ensure Docker is started and enabled
    systemctl start docker
    systemctl enable docker
else
    echo "[+] Docker is already installed."
fi

# Verify Docker Installation & Fallback
if ! command -v docker &> /dev/null; then
    echo "[-] Convenience script failed. Trying apt installation (fallback)..."
    apt-get update
    apt-get install -y docker.io docker-compose-plugin
    
    # Start service
    systemctl start docker
    systemctl enable docker
fi

# Final Check
if ! command -v docker &> /dev/null; then
    echo "[-] Error: Docker installation failed completely. Please install Docker manually."
    exit 1
fi

# Install Docker Compose Plugin if missing (for 'docker compose' command)
if ! docker compose version &> /dev/null; then
    echo "[+] Installing Docker Compose Plugin..."
    apt-get install -y docker-compose-plugin
fi

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

# Verify docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "[-] Error: docker-compose.yml not found in $(pwd)"
    echo "[-] Listing files:"
    ls -la
    exit 1
fi

# Generate Random Secret Key
echo "[+] Configuring Security..."
if [ ! -f ".env" ]; then
    echo "SECRET_KEY=$(openssl rand -hex 32)" > .env
    echo "[+] .env file created with secure key."
else
    echo "[+] .env file already exists."
fi

# Start Services
echo "[+] Starting Services..."
cd $INSTALL_DIR
echo "[+] Running docker compose in $(pwd)..."
docker compose -f docker-compose.yml up -d --build

echo "=================================================="
echo "   Installation Complete!"
echo "   Access your panel at: http://$(curl -s ifconfig.me):3000"
echo "=================================================="
