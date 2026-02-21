# Rocket Panel Updater for Windows
$ErrorActionPreference = "Stop"

function Write-Color($text, $color) { Write-Host $text -ForegroundColor $color }

Write-Color "==================================================" "Cyan"
Write-Color "   Rocket Panel 2026 - Windows Updater" "Green"
Write-Color "==================================================" "Cyan"

# Ensure we are in the project root (parent of scripts/)
$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath) {
    $projectRoot = Split-Path (Split-Path $scriptPath -Parent) -Parent
    Set-Location $projectRoot
}

Write-Color "[+] Working directory: $(Get-Location)" "Cyan"

# Check Admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { 
    Write-Color "[-] Please run as Administrator" "Red"
    Exit 1 
}

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Color "[-] Error: Docker is not installed or not found in PATH." "Red"
    Exit 1
}

Write-Color "[+] Pulling latest changes..." "Yellow"
git stash
git pull origin main

if (-not (Test-Path ".env")) {
    Write-Color "[+] Migrating to .env configuration..." "Yellow"
    $secret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | ForEach-Object {[char]$_})
    "SECRET_KEY=$secret" | Out-File -Encoding utf8 .env
}

Write-Color "[+] Rebuilding containers..." "Yellow"
docker compose -f docker-compose.yml down
docker compose -f docker-compose.yml up -d --build

Write-Color "==================================================" "Cyan"
Write-Color "   Update Complete!" "Green"
Write-Color "==================================================" "Cyan"
