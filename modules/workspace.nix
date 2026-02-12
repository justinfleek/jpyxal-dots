{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # WORKSPACE - Your development workspace setup
  # Clones repos, sets up environment, configures opencode
  # ============================================================================

  home.packages = with pkgs; [
    # === FUNCTIONAL LANGUAGES ===
    # Dhall
    dhall
    dhall-json
    dhall-yaml
    dhall-bash
    dhall-lsp-server
    
    # PureScript
    purescript
    spago
    purs-tidy
    purescript-language-server
    
    # Haskell (for Halogen/PureScript tooling)
    ghc
    cabal-install
    stack
    haskell-language-server
    
    # Lean 4
    lean4
    elan                     # Lean version manager
    
    # Nix
    nil
    nixfmt-rfc-style
    nix-tree
    nix-diff
    nvd                      # Nix version diff
    
    # === NETWORKING ===
    tailscale                # Mesh VPN
    
    # === AI/ML ===
    # (nvidia-sdk deps will come from the flake)
    
    # === BUILD TOOLS ===
    just
    watchexec
    
    # === OPENCODE ===
    opencode
  ];

  # ============================================================================
  # WORKSPACE SETUP SCRIPT
  # ============================================================================

  home.file.".local/bin/workspace-setup" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      
      WORKSPACE="$HOME/workspace"
      
      echo "Setting up workspace at $WORKSPACE..."
      mkdir -p "$WORKSPACE"
      cd "$WORKSPACE"
      
      # Your repos
      REPOS=(
        "git@github.com:straylight-software/sensenet.git"
        "git@github.com:weyl-ai/nvidia-sdk.git"
        "git@github.com:straylight-software/nix-compile.git"
        "git@github.com:straylight-software/slide.git"
        "git@github.com:straylight-software/isospin-microvm.git"
        "git@github.com:omega-agentic/omega-agentic.git"
      )
      
      for repo in "''${REPOS[@]}"; do
        name=$(basename "$repo" .git)
        if [ -d "$name" ]; then
          echo "Updating $name..."
          (cd "$name" && git pull) || echo "Failed to pull $name"
        else
          echo "Cloning $name..."
          git clone "$repo" || echo "Failed to clone $name"
        fi
      done
      
      echo ""
      echo "Workspace ready!"
      echo "Repos:"
      ls -la "$WORKSPACE"
    '';
  };

  # ============================================================================
  # WORKSPACE SYNC SCRIPT
  # ============================================================================

  home.file.".local/bin/workspace-sync" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      
      WORKSPACE="$HOME/workspace"
      
      echo "Syncing all repos in $WORKSPACE..."
      
      for dir in "$WORKSPACE"/*/; do
        if [ -d "$dir/.git" ]; then
          name=$(basename "$dir")
          echo "Syncing $name..."
          (cd "$dir" && git fetch --all && git pull --rebase) || echo "Failed to sync $name"
        fi
      done
      
      echo "Done!"
    '';
  };

  # ============================================================================
  # OPENCODE CONFIGURATION
  # ============================================================================

  # Global opencode config
  xdg.configFile."opencode/config.json".text = builtins.toJSON {
    provider = "anthropic";
    model = "claude-sonnet-4-20250514";
    autosave = true;
  };

  # Workspace-specific opencode config (created by script)
  home.file.".local/bin/workspace-opencode" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      WORKSPACE="$HOME/workspace"
      
      # Create workspace .opencode config if not exists
      if [ ! -f "$WORKSPACE/.opencode/config.json" ]; then
        mkdir -p "$WORKSPACE/.opencode"
        cat > "$WORKSPACE/.opencode/config.json" << 'EOF'
      {
        "provider": "anthropic",
        "model": "claude-sonnet-4-20250514",
        "autosave": true
      }
      EOF
      fi
      
      # Open opencode in workspace
      cd "$WORKSPACE"
      exec opencode "$@"
    '';
  };

  # ============================================================================
  # DIRENV CONFIGS FOR EACH REPO TYPE
  # ============================================================================

  # PureScript/Halogen project template
  home.file.".local/share/templates/purescript/.envrc".text = ''
    use flake
    
    # PureScript paths
    export PATH="$PWD/node_modules/.bin:$PATH"
    export PATH="$PWD/.spago/bin:$PATH"
  '';

  home.file.".local/share/templates/purescript/flake.nix".text = ''
    {
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
        purescript-overlay.url = "github:thomashoneyman/purescript-overlay";
      };

      outputs = { self, nixpkgs, flake-utils, purescript-overlay }:
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ purescript-overlay.overlays.default ];
            };
          in {
            devShells.default = pkgs.mkShell {
              packages = with pkgs; [
                # PureScript
                purs
                spago-unstable
                purs-tidy-bin.purs-tidy-0_10_0
                purescript-language-server
                
                # Node
                nodejs_20
                
                # Build
                esbuild
              ];
            };
          }
        );
    }
  '';

  # Dhall project template
  home.file.".local/share/templates/dhall/.envrc".text = ''
    use flake
  '';

  home.file.".local/share/templates/dhall/flake.nix".text = ''
    {
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

      outputs = { self, nixpkgs }:
        let
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.''${system};
        in {
          devShells.''${system}.default = pkgs.mkShell {
            packages = with pkgs; [
              dhall
              dhall-json
              dhall-yaml
              dhall-bash
              dhall-lsp-server
            ];
          };
        };
    }
  '';

  # Lean 4 project template
  home.file.".local/share/templates/lean4/.envrc".text = ''
    use flake
  '';

  home.file.".local/share/templates/lean4/flake.nix".text = ''
    {
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        lean4.url = "github:leanprover/lean4";
      };

      outputs = { self, nixpkgs, lean4 }:
        let
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.''${system};
        in {
          devShells.''${system}.default = pkgs.mkShell {
            packages = [
              lean4.packages.''${system}.default
              pkgs.elan
            ];
          };
        };
    }
  '';

  # Nix project template
  home.file.".local/share/templates/nix/.envrc".text = ''
    use flake
  '';

  home.file.".local/share/templates/nix/flake.nix".text = ''
    {
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

      outputs = { self, nixpkgs }:
        let
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.''${system};
        in {
          devShells.''${system}.default = pkgs.mkShell {
            packages = with pkgs; [
              nil
              nixfmt-rfc-style
              nix-tree
            ];
          };
        };
    }
  '';

  # ============================================================================
  # SHELL INTEGRATION
  # ============================================================================

  programs.bash.shellAliases = {
    # Workspace
    ws = "cd ~/workspace";
    wss = "workspace-setup";
    wsy = "workspace-sync";
    wso = "workspace-opencode";
    
    # Quick cd to repos
    sensenet = "cd ~/workspace/sensenet";
    nvidia = "cd ~/workspace/nvidia-sdk";
    nxc = "cd ~/workspace/nix-compile";
    slide = "cd ~/workspace/slide";
    isospin = "cd ~/workspace/isospin-microvm";
    omega = "cd ~/workspace/omega-agentic";
    
    # Tailscale
    ts = "tailscale";
    tss = "tailscale status";
    tsu = "sudo tailscale up";
    tsd = "sudo tailscale down";
    
    # Dhall
    dh = "dhall";
    dhj = "dhall-to-json";
    dhy = "dhall-to-yaml";
    
    # PureScript
    ps = "purs";
    sp = "spago";
    spb = "spago build";
    spt = "spago test";
    spr = "spago run";
    
    # Lean
    lk = "lake";
    lkb = "lake build";
    lkt = "lake test";
  };

  programs.bash.initExtra = lib.mkAfter ''
    # Auto-cd to workspace on terminal open (optional)
    # [ -d "$HOME/workspace" ] && cd "$HOME/workspace"
    
    # Quick project creation
    mkpurs() {
      local name="''${1:-my-purs-project}"
      mkdir -p "$name"
      cp -r ~/.local/share/templates/purescript/* "$name/"
      cd "$name"
      direnv allow
      echo "PureScript project '$name' created!"
    }
    
    mkdhall() {
      local name="''${1:-my-dhall-project}"
      mkdir -p "$name"
      cp -r ~/.local/share/templates/dhall/* "$name/"
      cd "$name"
      direnv allow
      echo "Dhall project '$name' created!"
    }
    
    mklean() {
      local name="''${1:-my-lean-project}"
      mkdir -p "$name"
      cp -r ~/.local/share/templates/lean4/* "$name/"
      cd "$name"
      direnv allow
      echo "Lean 4 project '$name' created!"
    }
    
    # Open all repos in tmux
    workspace-tmux() {
      tmux new-session -d -s workspace -c ~/workspace
      tmux rename-window -t workspace:0 'main'
      
      tmux new-window -t workspace -n 'sensenet' -c ~/workspace/sensenet
      tmux new-window -t workspace -n 'nvidia' -c ~/workspace/nvidia-sdk
      tmux new-window -t workspace -n 'nix-compile' -c ~/workspace/nix-compile
      tmux new-window -t workspace -n 'slide' -c ~/workspace/slide
      tmux new-window -t workspace -n 'isospin' -c ~/workspace/isospin-microvm
      tmux new-window -t workspace -n 'omega' -c ~/workspace/omega-agentic
      
      tmux select-window -t workspace:0
      tmux attach -t workspace
    }
  '';

  # ============================================================================
  # TAILSCALE SERVICE
  # ============================================================================

  # Note: Tailscale daemon needs to be enabled at system level
  # Add to your NixOS config:
  # services.tailscale.enable = true;
}
