#!/usr/bin/env bash
#
# j-pyxal dots - One-liner installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/justinfleek/home-manager/main/install.sh | bash
#
# Or with options:
#   curl -fsSL https://raw.githubusercontent.com/justinfleek/home-manager/main/install.sh | bash -s -- --workspace
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Config
REPO_URL="https://github.com/justinfleek/home-manager.git"
INSTALL_DIR="$HOME/.config/home-manager"
WORKSPACE_DIR="$HOME/workspace"

# Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Banner
print_banner() {
    echo -e "${MAGENTA}"
    cat << 'EOF'
       ██╗      ██████╗ ██╗   ██╗██╗  ██╗ █████╗ ██╗
       ██║      ██╔══██╗╚██╗ ██╔╝╚██╗██╔╝██╔══██╗██║
       ██║█████╗██████╔╝ ╚████╔╝  ╚███╔╝ ███████║██║
  ██   ██║╚════╝██╔═══╝   ╚██╔╝   ██╔██╗ ██╔══██║██║
  ╚█████╔╝      ██║        ██║   ██╔╝ ██╗██║  ██║███████╗
   ╚════╝       ╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
EOF
    echo -e "${NC}"
    echo -e "${CYAN}The Kitchen Sink of Dotfiles${NC}"
    echo ""
}

# Check requirements
check_requirements() {
    log_info "Checking requirements..."
    
    # Check if NixOS or Nix installed
    if ! command -v nix &> /dev/null; then
        log_error "Nix is not installed!"
        echo ""
        echo "Install Nix first:"
        echo "  curl -L https://nixos.org/nix/install | sh"
        echo ""
        echo "Or install NixOS: https://nixos.org/download"
        exit 1
    fi
    
    # Check if flakes enabled
    if ! nix flake --help &> /dev/null 2>&1; then
        log_warn "Flakes not enabled. Adding to nix.conf..."
        mkdir -p ~/.config/nix
        echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
        log_success "Flakes enabled!"
    fi
    
    # Check git
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed!"
        exit 1
    fi
    
    log_success "All requirements met!"
}

# Detect username
detect_username() {
    USERNAME="${USER:-$(whoami)}"
    log_info "Detected username: $USERNAME"
}

# Clone or update repo
clone_repo() {
    log_info "Setting up home-manager config..."
    
    if [ -d "$INSTALL_DIR" ]; then
        log_warn "Config already exists at $INSTALL_DIR"
        read -p "Overwrite? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$INSTALL_DIR"
        else
            log_info "Keeping existing config. Pulling latest..."
            cd "$INSTALL_DIR"
            git pull
            return
        fi
    fi
    
    git clone "$REPO_URL" "$INSTALL_DIR"
    log_success "Config cloned to $INSTALL_DIR"
}

# Update username in flake
update_username() {
    log_info "Updating username in config..."
    
    sed -i "s/username = \".*\"/username = \"$USERNAME\"/" "$INSTALL_DIR/flake.nix"
    
    # Also update git config
    sed -i "s/userName = .*;/userName = \"$USERNAME\";/" "$INSTALL_DIR/modules/git.nix"
    
    log_success "Username set to: $USERNAME"
}

# Setup workspace with repos
setup_workspace() {
    log_info "Setting up workspace with repos..."
    
    mkdir -p "$WORKSPACE_DIR"
    cd "$WORKSPACE_DIR"
    
    REPOS=(
        "git@github.com:straylight-software/sensenet.git"
        "git@github.com:weyl-ai/nvidia-sdk.git"
        "git@github.com:straylight-software/nix-compile.git"
        "git@github.com:straylight-software/slide.git"
        "git@github.com:straylight-software/isospin-microvm.git"
        "git@github.com:omega-agentic/omega-agentic.git"
    )
    
    for repo in "${REPOS[@]}"; do
        name=$(basename "$repo" .git)
        if [ -d "$name" ]; then
            log_info "Updating $name..."
            cd "$name"
            git pull || log_warn "Failed to pull $name"
            cd ..
        else
            log_info "Cloning $name..."
            git clone "$repo" || log_warn "Failed to clone $name (check SSH keys)"
        fi
    done
    
    log_success "Workspace ready at $WORKSPACE_DIR"
}

# Build and activate
build_config() {
    log_info "Building home-manager configuration..."
    log_warn "This may take a while on first run (downloading packages)..."
    
    cd "$INSTALL_DIR"
    
    # First run - use nix run
    if ! command -v home-manager &> /dev/null; then
        nix run nixpkgs#home-manager -- switch --flake ".#$USERNAME" --impure
    else
        home-manager switch --flake ".#$USERNAME" --impure
    fi
    
    log_success "Configuration activated!"
}

# Setup opencode workspace config
setup_opencode() {
    log_info "Setting up OpenCode workspace configuration..."
    
    mkdir -p "$WORKSPACE_DIR/.opencode"
    
    cat > "$WORKSPACE_DIR/.opencode/config.json" << EOF
{
  "provider": "anthropic",
  "model": "claude-sonnet-4-20250514",
  "autosave": true,
  "context": {
    "include": [
      "sensenet/**",
      "nvidia-sdk/**",
      "nix-compile/**",
      "slide/**",
      "isospin-microvm/**",
      "omega-agentic/**"
    ]
  }
}
EOF
    
    log_success "OpenCode configured for workspace!"
}

# Setup PRISM themes and Cursor
setup_extras() {
    log_info "Setting up PRISM themes and Cursor IDE..."
    
    # Run prism-setup if available
    if [ -x "$HOME/.local/bin/prism-setup" ]; then
        "$HOME/.local/bin/prism-setup" || log_warn "PRISM setup had issues"
    fi
    
    # Run cursor-install if available
    if [ -x "$HOME/.local/bin/cursor-install" ]; then
        read -p "Install Cursor IDE? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            "$HOME/.local/bin/cursor-install" || log_warn "Cursor install had issues"
        fi
    fi
    
    # Run hypermodern-emacs-setup if available
    if [ -x "$HOME/.local/bin/hypermodern-emacs-setup" ]; then
        read -p "Setup hypermodern-emacs? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            "$HOME/.local/bin/hypermodern-emacs-setup" || log_warn "Emacs setup had issues"
        fi
    fi
    
    log_success "Extras configured!"
}

# Print next steps
print_next_steps() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Next steps:"
    echo ""
    echo -e "  ${CYAN}1.${NC} Log out and back in (or reboot)"
    echo -e "  ${CYAN}2.${NC} Select Hyprland at login screen"
    echo -e "  ${CYAN}3.${NC} Press ${MAGENTA}Super + Return${NC} to open terminal"
    echo -e "  ${CYAN}4.${NC} Run ${MAGENTA}opencode${NC} to start coding!"
    echo ""
    echo -e "Your workspace is at: ${CYAN}$WORKSPACE_DIR${NC}"
    echo ""
    echo -e "Quick commands:"
    echo -e "  ${YELLOW}hms${NC}     - Rebuild home-manager config"
    echo -e "  ${YELLOW}lg${NC}      - Lazygit"
    echo -e "  ${YELLOW}v${NC}       - Neovim"
    echo -e "  ${YELLOW}oc${NC}      - OpenCode"
    echo -e "  ${YELLOW}cursor${NC}  - Cursor IDE"
    echo -e "  ${YELLOW}prism${NC}   - Setup/update PRISM themes"
    echo -e "  ${YELLOW}themes${NC}  - Switch color themes"
    echo ""
    echo -e "Docs: ${BLUE}$INSTALL_DIR/modules/docs/${NC}"
    echo ""
}

# Main
main() {
    local setup_workspace=false
    
    # Parse args
    while [[ $# -gt 0 ]]; do
        case $1 in
            --workspace|-w)
                setup_workspace=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --workspace, -w    Also clone workspace repos"
                echo "  --help, -h         Show this help"
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
    
    print_banner
    check_requirements
    detect_username
    clone_repo
    update_username
    
    if [ "$setup_workspace" = true ]; then
        setup_workspace
        setup_opencode
    fi
    
    build_config
    setup_extras
    print_next_steps
}

main "$@"
