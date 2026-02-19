#!/bin/bash

# Rocket Panel Updater
echo "[+] Pulling latest changes..."
# Stash local changes (like old modified docker-compose.yml) just in case
git stash
git pull origin main

# Ensure .env exists if migrating from old version
if [ ! -f ".env" ]; then
    echo "[+] Migrating to .env configuration..."
    echo "SECRET_KEY=$(openssl rand -hex 32)" > .env
fi

echo "[+] Rebuilding containers..."
docker compose -f docker-compose.yml down
docker compose -f docker-compose.yml up -d --build

echo "[+] Update Complete!"
