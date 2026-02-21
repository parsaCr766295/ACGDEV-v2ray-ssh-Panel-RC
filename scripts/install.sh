#!/bin/bash

# Exit on any error
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
clear
echo -e "${BLUE}==================================================${NC}"
echo -e "${GREEN}   Rocket Panel 2026 - Installation Script${NC}"
echo -e "${BLUE}   Developed by ACGDEV Team${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[-] Please run as root${NC}"
  exit 1
fi

# Check System Requirements (RAM > 1GB, Disk > 5GB)
echo -e "${YELLOW}[+] Checking System Requirements...${NC}"
TOTAL_RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
if [ "$TOTAL_RAM" -lt 1000000 ]; then
    echo -e "${YELLOW}[!] Warning: Low RAM detected. Recommended: 1GB+. Proceeding anyway...${NC}"
else
    echo -e "${GREEN}[OK] RAM Check Passed.${NC}"
fi

AVAILABLE_DISK=$(df / | tail -1 | awk '{print $4}')
if [ "$AVAILABLE_DISK" -lt 5000000 ]; then
    echo -e "${RED}[!] Error: Insufficient Disk Space. Need at least 5GB free.${NC}"
    exit 1
else
    echo -e "${GREEN}[OK] Disk Check Passed.${NC}"
fi

# Update System
echo -e "${YELLOW}[+] Updating System...${NC}"
apt-get update -y && apt-get upgrade -y

# Install Basic Dependencies
echo -e "${YELLOW}[+] Installing Dependencies...${NC}"
apt-get install -y git curl wget

# Install Docker if not exists
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}[+] Installing Docker using convenience script...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    # Ensure Docker is started and enabled
    systemctl start docker
    systemctl enable docker
else
    echo -e "${GREEN}[+] Docker is already installed.${NC}"
fi

# Verify Docker Installation & Fallback
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}[-] Convenience script failed. Trying apt installation (fallback)...${NC}"
    apt-get update
    apt-get install -y docker.io docker-compose-plugin
    
    # Start service
    systemctl start docker
    systemctl enable docker
fi

# Final Check
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[-] Error: Docker installation failed completely. Please install Docker manually.${NC}"
    exit 1
fi

# Install Docker Compose Plugin if missing (for 'docker compose' command)
if ! docker compose version &> /dev/null; then
    echo -e "${YELLOW}[+] Installing Docker Compose Plugin...${NC}"
    apt-get install -y docker-compose-plugin
fi

# Setup Directory & Clone Repo
INSTALL_DIR="/opt/rocket-panel"
REPO_URL="https://github.com/parsaCr766295/ACGDEV-v2ray-ssh-Panel-RC.git"

if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}[+] Directory $INSTALL_DIR exists. Pulling latest changes...${NC}"
    cd $INSTALL_DIR
    git pull
else
    echo -e "${YELLOW}[+] Cloning repository to $INSTALL_DIR...${NC}"
    git clone $REPO_URL $INSTALL_DIR
    cd $INSTALL_DIR
fi

# Verify docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}[-] Error: docker-compose.yml not found in $(pwd)${NC}"
    echo -e "${RED}[-] Listing files:${NC}"
    ls -la
    exit 1
fi

# Generate Random Secret Key
echo -e "${YELLOW}[+] Configuring Security...${NC}"
if [ ! -f ".env" ]; then
    echo "SECRET_KEY=$(openssl rand -hex 32)" > .env
    echo -e "${GREEN}[+] .env file created with secure key.${NC}"
else
    echo -e "${GREEN}[+] .env file already exists.${NC}"
fi

# Start Services
echo -e "${YELLOW}[+] Starting Services...${NC}"
cd $INSTALL_DIR
echo -e "${BLUE}[+] Running docker compose in $(pwd)...${NC}"
docker compose -f docker-compose.yml up -d --build

# Get Public IP
PUBLIC_IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')

echo ""
echo -e "${BLUE}==================================================${NC}"
echo -e "${GREEN}   Installation Complete! 🚀${NC}"
echo -e "${BLUE}==================================================${NC}"
echo -e "   Access your panel at: ${GREEN}http://${PUBLIC_IP}:3000${NC}"
echo -e "   Default Admin:        ${YELLOW}admin${NC}"
echo -e "   Default Password:     ${YELLOW}admin${NC}"
echo -e "${RED}   [!] Please change your password immediately!${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""
