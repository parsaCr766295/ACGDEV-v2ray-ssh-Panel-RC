# Rocket Panel 2026 Installer for Windows
# ACGDEV Team

$ErrorActionPreference = "Stop"

# Colors function
function Write-Color($text, $color) {
    Write-Host $text -ForegroundColor $color
}

# Banner
Clear-Host
Write-Color "==================================================" "Cyan"
Write-Color "   Rocket Panel 2026 - Windows Installer" "Green"
Write-Color "   Developed by ACGDEV Team" "Cyan"
Write-Color "==================================================" "Cyan"
Write-Host ""

# Check Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Color "[-] Please run as Administrator (Right-click PowerShell > Run as Administrator)" "Red"
    Exit 1
}

# Check System Requirements
Write-Color "[+] Checking System Requirements..." "Yellow"
$mem = Get-CimInstance Win32_ComputerSystem
$totalRam = $mem.TotalPhysicalMemory / 1MB
if ($totalRam -lt 1000) {
    Write-Color "[!] Warning: Low RAM detected ($([math]::Round($totalRam))MB). Recommended: 1024MB+. Proceeding anyway..." "Yellow"
} else {
    Write-Color "[OK] RAM Check Passed ($([math]::Round($totalRam))MB)." "Green"
}

$drive = Get-PSDrive C
$freeSpace = $drive.Free / 1GB
if ($freeSpace -lt 5) {
    Write-Color "[!] Error: Insufficient Disk Space on C:. Need at least 5GB free." "Red"
    Exit 1
} else {
    Write-Color "[OK] Disk Check Passed ($([math]::Round($freeSpace, 2))GB Free)." "Green"
}

# Check Dependencies (Git & Docker)
Write-Color "[+] Checking Dependencies..." "Yellow"

$hasWinget = Get-Command winget -ErrorAction SilentlyContinue

# 1. Git Check & Auto-Install
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Color "[-] Git is not installed." "Red"
    if ($hasWinget) {
        Write-Color "[+] Attempting to install Git via Winget..." "Yellow"
        try {
            winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements --silent
            Write-Color "[+] Git installed. Refreshing PATH..." "Green"
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        } catch {
            Write-Color "[-] Failed to install Git automatically." "Red"
        }
    }
    
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Color "[-] Git is required. Please install it manually: https://git-scm.com/download/win" "Red"
        Exit 1
    }
} else {
    Write-Color "[OK] Git is installed." "Green"
}

# 2. Docker Check
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Color "[-] Docker is not installed." "Red"
    if ($hasWinget) {
         Write-Color "[!] Install Docker Desktop? (This will require a restart) [Y/N]" "Yellow"
         $response = Read-Host
         if ($response -eq 'Y' -or $response -eq 'y') {
             winget install --id Docker.DockerDesktop -e --source winget --accept-source-agreements --accept-package-agreements
             Write-Color "[!] Docker installed. Please RESTART your server/PC and run this script again." "Red"
             Exit 0
         }
    }
    Write-Color "[-] Please install Docker Desktop manually: https://www.docker.com/products/docker-desktop/" "White"
    Exit 1
} else {
    Write-Color "[OK] Docker is installed." "Green"
}

# 3. WSL Check (Recommended for Windows Server/10/11)
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Color "[!] Warning: WSL (Windows Subsystem for Linux) not found." "Yellow"
    Write-Color "    Rocket Panel runs best on WSL2 backend." "Yellow"
}

# Installation Directory
$installDir = "C:\RocketPanel"
$repoUrl = "https://github.com/parsaCr766295/ACGDEV-v2ray-ssh-Panel-RC.git"

if (Test-Path $installDir) {
    Write-Color "[+] Directory $installDir exists. Pulling latest changes..." "Yellow"
    Set-Location $installDir
    git pull
} else {
    Write-Color "[+] Cloning repository to $installDir..." "Yellow"
    git clone $repoUrl $installDir
    Set-Location $installDir
}

# Verify docker-compose.yml
if (-not (Test-Path "docker-compose.yml")) {
    Write-Color "[-] Error: docker-compose.yml not found in $(Get-Location)" "Red"
    Get-ChildItem
    Exit 1
}

# Generate Secret Key
Write-Color "[+] Configuring Security..." "Yellow"
if (-not (Test-Path ".env")) {
    $secret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | ForEach-Object {[char]$_})
    "SECRET_KEY=$secret" | Out-File -Encoding utf8 .env
    Write-Color "[+] .env file created with secure key." "Green"
} else {
    Write-Color "[+] .env file already exists." "Green"
}

# Start Services
Write-Color "[+] Starting Services..." "Yellow"
Write-Color "[+] Running docker compose in $(Get-Location)..." "Cyan"
docker compose -f docker-compose.yml up -d --build

# Get Public IP
try {
    $publicIp = (Invoke-RestMethod "https://api.ipify.org").Trim()
} catch {
    $publicIp = "127.0.0.1"
}

Write-Host ""
Write-Color "==================================================" "Cyan"
Write-Color "   Installation Complete! 🚀" "Green"
Write-Color "==================================================" "Cyan"
Write-Color "   Access your panel at: http://$publicIp`:3000" "Green"
Write-Color "   Default Admin:        admin" "Yellow"
Write-Color "   Default Password:     admin" "Yellow"
Write-Color "   [!] Please change your password immediately!" "Red"
Write-Color "==================================================" "Cyan"
Write-Host ""
