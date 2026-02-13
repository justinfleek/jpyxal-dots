{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # COMFYUI - Full Stable Diffusion workflow with fxy custom nodes
  # Integrates with weyl-ai/nixified-ai-flake for Nix-native GPU support
  # ============================================================================

  # NOTE: For NixOS systems, you can enable the full nixified-ai module:
  #   services.comfyui.enable = true;
  #   services.comfyui.acceleration = "cuda";
  #   services.comfyui.customNodes = [ ... ];
  #
  # This home-manager module provides:
  # 1. Scripts to install/manage ComfyUI
  # 2. Pre-configured custom nodes list
  # 3. Integration with fxy infrastructure

  home.packages = with pkgs; [
    # Python for ComfyUI
    (python312.withPackages (ps: with ps; [
      # Core
      torch
      torchvision
      torchaudio
      
      # Diffusion
      diffusers
      transformers
      accelerate
      safetensors
      
      # Image processing
      pillow
      opencv4
      
      # ComfyUI deps
      aiohttp
      einops
      kornia
      
      # Additional ML
      scipy
      scikit-image
      
      # Utils
      tqdm
      pyyaml
      requests
    ]))
    
    # System deps
    git
    git-lfs
    aria2
    ffmpeg
  ];

  # ============================================================================
  # COMFYUI CUSTOM NODES LIST
  # All nodes from ~/.config/comfy-ui/custom_nodes/
  # ============================================================================

  home.file.".config/comfyui/custom-nodes.txt".text = ''
    # ComfyUI Custom Nodes - j-pyxal collection
    # These are the custom nodes from the fxy infrastructure
    
    # === CORE NODES (from nixified-ai) ===
    comfyui-manager
    comfyui-impact-pack
    comfyui-impact-subpack
    comfyui-kjnodes
    comfyui-essentials
    comfyui-controlnet-aux
    comfyui-advanced-controlnet
    comfyui-video-helper-suite
    comfyui-frame-interpolation
    comfyui-rgthree
    comfyui-was-node-suite
    comfyui-layer-style
    
    # === VIDEO/ANIMATION ===
    ComfyUI-WanVideoWrapper
    ComfyUI-WanAnimatePreprocess
    steerable-motion
    ComfyUI-GIMM-VFI
    wan22fmlf
    
    # === IMAGE PROCESSING ===
    ComfyUI-Florence2
    ComfyUI-DepthAnythingV2
    ComfyUI-SAM3
    ComfyUI-RMBG
    ComfyUI-Inpaint-CropAndStitch
    comfyui-inpaint-nodes
    ComfyUI-SeedVR2_VideoUpscaler
    comfyui_ultimatesdupscale
    ComfyUI-TiledDiffusion
    
    # === PERFORMANCE ===
    ComfyUI-GGUF
    ComfyUI_bitsandbytes_NF4
    ComfyUI_TensorRT
    
    # === AUDIO ===
    ComfyUI-MMAudio
    audio-separation-nodes-comfyui
    
    # === UTILITIES ===
    ComfyUI-Crystools
    ComfyUI-Detail-Daemon
    ComfyUI-Inspire-Pack
    ComfyUI_tinyterraNodes
    ComfyUI_Fill-Nodes
    ComfyUI-DyPE
    Derfuu_ComfyUI_ModdedNodes
    ComfyUI_Yvann-Nodes
    comfyui-art-venture
    comfyui-logicutils
    comfyui-tooling-nodes
    comfyui-utils-nodes
    comfyui-post-processing-nodes
    comfyui-openpose-editor
    comfyui-styles_csv_loader
    controlaltai-nodes
    
    # === MODEL MANAGEMENT ===
    model_downloader
    x-flux-comfyui
    ComfyUI-LTXVideo
    PuLID_ComfyUI
    RES4LYF
    ComfyUI-TRELLIS2
  '';

  # ============================================================================
  # NIXIFIED-AI INTEGRATION
  # ============================================================================

  home.file.".local/bin/comfyui-nix-setup" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Setup ComfyUI using nixified-ai flake
      # This provides Nix-native GPU support and reproducible builds
      
      set -euo pipefail
      
      COMFY_DIR="$HOME/.local/share/comfyui-nix"
      FXY_DIR="$HOME/src/fxy"
      
      echo "=== ComfyUI Nix Setup ==="
      echo ""
      
      # Check if fxy repo exists (has the full nixified-ai setup)
      if [ -d "$FXY_DIR" ]; then
        echo "Found fxy infrastructure at $FXY_DIR"
        echo "Using nixified-ai from fxy..."
        echo ""
        
        cd "$FXY_DIR"
        
        # The ComfyUI is symlinked to fxy/ComfyUI with custom_nodes pointing to ~/.config/comfy-ui/custom_nodes
        if [ -d "ComfyUI" ]; then
          echo "ComfyUI already set up in fxy"
          echo ""
          echo "To run ComfyUI:"
          echo "  cd $FXY_DIR"
          echo "  nix develop"
          echo "  python ComfyUI/main.py --listen 0.0.0.0"
          exit 0
        fi
      fi
      
      # Alternative: use standalone comfyui-nix
      echo "Setting up standalone ComfyUI with nixified-ai..."
      
      mkdir -p "$COMFY_DIR"
      cd "$COMFY_DIR"
      
      # Create flake.nix
      cat > flake.nix << 'FLAKE'
      {
        description = "ComfyUI with nixified-ai";
        
        inputs = {
          nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          nixified-ai.url = "git+ssh://git@github.com/weyl-ai/nixified-ai-flake.git?ref=b7r6/jpyxal-mvp-usable";
        };
        
        outputs = { self, nixpkgs, nixified-ai }:
          let
            system = "x86_64-linux";
            pkgs = import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                cudaSupport = true;
              };
              overlays = [
                nixified-ai.overlays.comfyui
                nixified-ai.overlays.models
                nixified-ai.overlays.fetchers
              ];
            };
          in {
            packages.${system}.default = pkgs.comfyuiPackages.comfyui.override {
              withCustomNodes = with pkgs.comfyuiCustomNodes; [
                comfyui-impact-pack
                comfyui-kjnodes
                comfyui-essentials
                comfyui-advanced-controlnet
                comfyui-video-helper-suite
                comfyui-frame-interpolation
                comfyui-rgthree
                comfyui-layer-style
                comfyui-gguf
                # Add more as needed from pkgs.comfyuiCustomNodes
              ];
            };
            
            devShells.${system}.default = pkgs.mkShell {
              packages = [ self.packages.${system}.default ];
              
              shellHook = '''
                echo "ComfyUI ready!"
                echo "Run with: comfyui --listen 0.0.0.0"
              ''';
            };
          };
      }
      FLAKE
      
      echo ""
      echo "Created flake at $COMFY_DIR/flake.nix"
      echo ""
      echo "To use:"
      echo "  cd $COMFY_DIR"
      echo "  nix develop"
      echo "  comfyui --listen 0.0.0.0"
      echo ""
      echo "Note: First run will download ~50GB+ of dependencies"
    '';
  };

  # ============================================================================
  # COMFYUI RUNNER SCRIPTS
  # ============================================================================

  home.file.".local/bin/comfyui-fxy" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Run ComfyUI from fxy infrastructure
      
      FXY_DIR="$HOME/src/fxy"
      
      if [ ! -d "$FXY_DIR/ComfyUI" ]; then
        echo "fxy ComfyUI not found at $FXY_DIR/ComfyUI"
        echo "Run: comfyui-nix-setup"
        exit 1
      fi
      
      cd "$FXY_DIR"
      
      # Enter nix environment and run
      nix develop --command python ComfyUI/main.py \
        --listen 0.0.0.0 \
        --port 8188 \
        "$@"
    '';
  };

  home.file.".local/bin/comfyui-nodes-sync" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Sync custom nodes from nix store to config dir
      
      NODES_DIR="$HOME/.config/comfy-ui/custom_nodes"
      
      echo "=== Custom Nodes Sync ==="
      echo ""
      echo "Current nodes in $NODES_DIR:"
      ls -la "$NODES_DIR" | grep -E "^[ld]" | awk '{print $NF}'
      echo ""
      
      # Count symlinks vs directories
      SYMLINKS=$(find "$NODES_DIR" -maxdepth 1 -type l | wc -l)
      DIRS=$(find "$NODES_DIR" -maxdepth 1 -type d | wc -l)
      
      echo "Nix-managed (symlinks): $SYMLINKS"
      echo "Local (directories): $((DIRS - 1))"
      echo ""
      
      # Show broken symlinks
      BROKEN=$(find "$NODES_DIR" -maxdepth 1 -type l ! -exec test -e {} \; -print | wc -l)
      if [ "$BROKEN" -gt 0 ]; then
        echo "⚠️  Broken symlinks: $BROKEN"
        echo "Run 'nix-collect-garbage' may have removed some nodes"
        echo "Rebuild with: cd ~/src/fxy && nix develop"
      fi
    '';
  };

  home.file.".local/bin/comfyui-models-dl" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Download common ComfyUI models
      
      MODELS_DIR="$HOME/.config/comfy-ui/models"
      
      echo "=== ComfyUI Model Downloader ==="
      echo ""
      
      mkdir -p "$MODELS_DIR/checkpoints"
      mkdir -p "$MODELS_DIR/vae"
      mkdir -p "$MODELS_DIR/loras"
      mkdir -p "$MODELS_DIR/controlnet"
      mkdir -p "$MODELS_DIR/upscale_models"
      mkdir -p "$MODELS_DIR/clip"
      mkdir -p "$MODELS_DIR/embeddings"
      
      cat << 'MENU'
      Select models to download:
      
      1) SDXL Base + Refiner
      2) SD 1.5
      3) FLUX.1-dev (requires HF token)
      4) ControlNet (SD 1.5)
      5) ControlNet (SDXL)
      6) VAE (SD + SDXL)
      7) Upscalers (4x-UltraSharp, RealESRGAN)
      8) All of the above
      
      q) Quit
      
      MENU
      
      read -p "Choice: " choice
      
      case "$choice" in
        1)
          echo "Downloading SDXL..."
          aria2c -d "$MODELS_DIR/checkpoints" -o "sd_xl_base_1.0.safetensors" \
            "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors"
          ;;
        2)
          echo "Downloading SD 1.5..."
          aria2c -d "$MODELS_DIR/checkpoints" -o "v1-5-pruned-emaonly.safetensors" \
            "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors"
          ;;
        3)
          echo "FLUX requires HuggingFace token"
          echo "Set HF_TOKEN environment variable first"
          ;;
        6)
          echo "Downloading VAEs..."
          aria2c -d "$MODELS_DIR/vae" -o "sdxl_vae.safetensors" \
            "https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors"
          ;;
        7)
          echo "Downloading upscalers..."
          aria2c -d "$MODELS_DIR/upscale_models" -o "4x-UltraSharp.pth" \
            "https://huggingface.co/Kim2091/UltraSharp/resolve/main/4x-UltraSharp.pth"
          ;;
        q|Q)
          exit 0
          ;;
        *)
          echo "Invalid choice"
          ;;
      esac
      
      echo ""
      echo "Done! Models saved to: $MODELS_DIR"
    '';
  };

  # ============================================================================
  # EXTRA MODEL PATHS CONFIG
  # ============================================================================

  xdg.configFile."comfyui/extra_model_paths.yaml".text = ''
    # Extra model paths for ComfyUI
    # This allows sharing models between different ComfyUI installs
    
    jpyxal:
      base_path: ~/.config/comfy-ui/
      checkpoints: models/checkpoints/
      vae: models/vae/
      loras: models/loras/
      upscale_models: models/upscale_models/
      controlnet: models/controlnet/
      clip: models/clip/
      embeddings: models/embeddings/
      clip_vision: models/clip_vision/
      ipadapter: models/ipadapter/
    
    # HuggingFace cache (for models downloaded via diffusers)
    huggingface:
      base_path: ~/.cache/huggingface/hub/
      
    # fxy shared models (if available)
    fxy:
      base_path: /fxy/data/models/
      checkpoints: checkpoints/
      loras: loras/
      controlnet: controlnet/
  '';

  # ============================================================================
  # NIXOS MODULE EXAMPLE
  # ============================================================================

  # For NixOS users, add this to your configuration.nix:
  home.file.".config/comfyui/nixos-example.nix".text = ''
    # NixOS ComfyUI Configuration Example
    # Add to your flake inputs:
    #   nixified-ai.url = "git+ssh://git@github.com/weyl-ai/nixified-ai-flake.git?ref=b7r6/jpyxal-mvp-usable";
    #
    # Add to your configuration:
    
    { pkgs, inputs, ... }: {
      imports = [ inputs.nixified-ai.nixosModules.comfyui ];
      
      services.comfyui = {
        enable = true;
        acceleration = "cuda";  # or "rocm" for AMD
        host = "0.0.0.0";
        port = 8188;
        
        # Custom nodes from nixified-ai
        customNodes = with pkgs.comfyuiCustomNodes; [
          comfyui-impact-pack
          comfyui-impact-subpack
          comfyui-kjnodes
          comfyui-essentials
          comfyui-advanced-controlnet
          comfyui-video-helper-suite
          comfyui-frame-interpolation
          comfyui-rgthree
          comfyui-was-node-suite
          comfyui-layer-style
          comfyui-gguf
          comfyui-inpaint
          comfyui-ip-adapter
          comfyui-kijai-wan-video-wrapper
          comfyui-tiled-diffusion
        ];
        
        # Models can be specified too
        # models = [ ... ];
      };
      
      # Open firewall if needed
      # services.comfyui.openFirewall = true;
    }
  '';

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    comfy = "comfyui-fxy";
    comfy-setup = "comfyui-nix-setup";
    comfy-nodes = "comfyui-nodes-sync";
    comfy-dl = "comfyui-models-dl";
  };
}
