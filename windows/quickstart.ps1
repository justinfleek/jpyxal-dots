# ============================================================================
# j-pyxal dots — Windows Quickstart
# Sets up NixOS-WSL + jpyxal-dots on a fresh Windows box
# Run as Administrator in PowerShell
# ============================================================================

$ErrorActionPreference = "Stop"

Write-Host @"

       ██╗      ██████╗ ██╗   ██╗██╗  ██╗ █████╗ ██╗
       ██║      ██╔══██╗╚██╗ ██╔╝╚██╗██╔╝██╔══██╗██║
       ██║█████╗██████╔╝ ╚████╔╝  ╚███╔╝ ███████║██║
  ██   ██║╚════╝██╔═══╝   ╚██╔╝   ██╔██╗ ██╔══██║██║
  ╚█████╔╝      ██║        ██║   ██╔╝ ██╗██║  ██║███████╗
   ╚════╝       ╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

  Windows Quickstart — NixOS-WSL Edition

"@ -ForegroundColor Magenta

# --- Step 1: Ensure WSL is installed and up to date ---
Write-Host "[1/5] Updating WSL..." -ForegroundColor Cyan
wsl --update
wsl --install --no-distribution

# --- Step 2: Download NixOS-WSL ---
$nixosWslUrl = "https://github.com/nix-community/NixOS-WSL/releases/download/2505.7.0/nixos.wsl"
$downloadPath = "$env:USERPROFILE\Downloads\nixos.wsl"

if (Test-Path $downloadPath) {
    Write-Host "[2/5] nixos.wsl already downloaded, skipping..." -ForegroundColor Yellow
} else {
    Write-Host "[2/5] Downloading NixOS-WSL..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $nixosWslUrl -OutFile $downloadPath -UseBasicParsing
    Write-Host "      Downloaded to $downloadPath" -ForegroundColor Green
}

# --- Step 3: Import NixOS ---
$existingDistros = wsl --list --quiet 2>$null
if ($existingDistros -match "NixOS") {
    Write-Host "[3/5] NixOS already imported, skipping..." -ForegroundColor Yellow
} else {
    Write-Host "[3/5] Importing NixOS into WSL..." -ForegroundColor Cyan
    $nixosDir = "$env:USERPROFILE\NixOS"
    if (!(Test-Path $nixosDir)) {
        New-Item -ItemType Directory -Path $nixosDir | Out-Null
    }
    wsl --import NixOS $nixosDir $downloadPath --version 2
    Write-Host "      NixOS imported successfully" -ForegroundColor Green
}

# --- Step 4: Set NixOS as default ---
Write-Host "[4/5] Setting NixOS as default WSL distro..." -ForegroundColor Cyan
wsl -s NixOS

# --- Step 5: Run NixOS-side setup ---
Write-Host "[5/5] Launching NixOS setup..." -ForegroundColor Cyan
Write-Host ""
Write-Host "  NixOS will now boot and run the setup script." -ForegroundColor Yellow
Write-Host "  This will:" -ForegroundColor Yellow
Write-Host "    - Enable flakes and nix-ld" -ForegroundColor Yellow
Write-Host "    - Configure GPU passthrough" -ForegroundColor Yellow
Write-Host "    - Clone jpyxal-dots" -ForegroundColor Yellow
Write-Host "    - Build the WSL home-manager config" -ForegroundColor Yellow
Write-Host ""

# Fetch and run the setup script directly from GitHub
wsl -d NixOS -- bash -c "curl -fsSL https://raw.githubusercontent.com/justinfleek/jpyxal-dots/main/wsl/setup.sh | bash"

Write-Host ""
Write-Host "  All done! Restart WSL to pick up all env changes:" -ForegroundColor Green
Write-Host "    wsl --shutdown" -ForegroundColor White
Write-Host "    wsl -d NixOS" -ForegroundColor White
Write-Host ""
