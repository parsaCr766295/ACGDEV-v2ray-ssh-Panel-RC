#!/bin/bash

# Rocket Panel Updater
echo "[+] Pulling latest changes..."
git pull origin main

echo "[+] Rebuilding containers..."
docker compose down
docker compose up -d --build

echo "[+] Update Complete!"
