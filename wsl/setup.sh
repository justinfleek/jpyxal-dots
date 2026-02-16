#!/usr/bin/env bash
# ============================================================================
# j-pyxal dots — NixOS-WSL Setup
# Run this INSIDE NixOS-WSL after importing nixos.wsl
# Usage: curl -fsSL https://raw.githubusercontent.com/justinfleek/jpyxal-dots/main/wsl/setup.sh | bash
# ============================================================================

set -euo pipefail

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║  j-pyxal dots — NixOS-WSL Setup             ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""

# --- Configure NixOS ---
echo "[1/5] Configuring NixOS (flakes, GPU, nix-ld)..."

sudo tee /etc/nixos/configuration.nix > /dev/null << 'NIXCONF'
{ config, lib, pkgs, ... }:
{
  imports = [
    <nixos-wsl/modules>
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";
  wsl.useWindowsDriver = true;

  programs.nix-ld.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.sessionVariables = {
    LD_LIBRARY_PATH = "/usr/lib/wsl/lib";
    # Set to "1" to reserve GPU 0 for Windows workloads (e.g. ComfyUI)
    # Set to "0,1" to use both GPUs in WSL
    CUDA_VISIBLE_DEVICES = "1";
  };

  system.stateVersion = "25.05";
}
NIXCONF

echo "    configuration.nix written"

# --- Rebuild NixOS ---
echo "[2/5] Rebuilding NixOS (this may take a minute)..."
sudo nix-channel --update
sudo nixos-rebuild switch

# --- Ensure PATH ---
echo "[3/5] Setting up environment..."
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

# --- Clone jpyxal-dots ---
echo "[4/5] Cloning jpyxal-dots..."
if [ -d "$HOME/.config/jpyxal-dots" ]; then
    echo "    Already cloned, pulling latest..."
    cd "$HOME/.config/jpyxal-dots"
    nix-shell -p git --run "git pull || true"
else
    nix-shell -p git --run "git clone https://github.com/justinfleek/jpyxal-dots.git $HOME/.config/jpyxal-dots"
fi

cd "$HOME/.config/jpyxal-dots"

# --- Build home-manager config ---
echo "[5/5] Building home-manager config (this will take a while on first run)..."
nix-shell -p home-manager --run "home-manager switch --flake .#nixos-wsl -b backup"

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║  Setup complete!                             ║"
echo "  ║                                              ║"
echo "  ║  From PowerShell, run:                       ║"
echo "  ║    wsl --shutdown                            ║"
echo "  ║    wsl -d NixOS                              ║"
echo "  ║                                              ║"
echo "  ║  nvidia-smi should show your GPUs.           ║"
echo "  ║  CUDA_VISIBLE_DEVICES=1 (GPU 1 for WSL)     ║"
echo "  ║                                              ║"
echo "  ║  Dots: ~/.config/jpyxal-dots                 ║"
echo "  ║  Update:                                     ║"
echo "  ║    cd ~/.config/jpyxal-dots                  ║"
echo "  ║    home-manager switch \                     ║"
echo "  ║      --flake .#nixos-wsl -b backup           ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""
