#!/bin/bash

# Exit on any error
set -e

# Rocket Panel Updater
echo "=================================================="
echo "   Rocket Panel 2026 - Update Script"
echo "=================================================="

# Ensure we are in the project root (parent of scripts/)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo "[+] Working directory: $(pwd)"

# Check permissions
if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run as root"
  exit 1
fi

echo "[+] Pulling latest changes..."
# Stash local changes (like old modified docker-compose.yml) just in case
git stash
git pull origin main

# Ensure .env exists if migrating from old version
if [ ! -f ".env" ]; then
    echo "[+] Migrating to .env configuration..."
    echo "SECRET_KEY=$(openssl rand -hex 32)" > .env
fi

# Check Docker availability
if ! command -v docker &> /dev/null; then
    echo "[-] Error: Docker is not installed or not found in PATH."
    exit 1
fi

echo "[+] Rebuilding containers..."
docker compose -f docker-compose.yml down
docker compose -f docker-compose.yml up -d --build

echo "=================================================="
echo "   Update Complete!"
echo "=================================================="
