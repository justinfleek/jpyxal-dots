{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================================================
  # AI LOCAL - Ollama, Open WebUI, ComfyUI, local LLMs
  # ============================================================================

  home.packages = with pkgs; [
    # Ollama - Local LLM runtime
    ollama

    # Python env consolidated in python.nix

    # Other tools
    git-lfs # For downloading models
    aria2 # Fast downloads
  ];

  # ============================================================================
  # OLLAMA CONFIGURATION
  # ============================================================================

  # Ollama models directory
  home.sessionVariables = {
    OLLAMA_MODELS = "$HOME/.local/share/ollama/models";
    OLLAMA_HOST = "127.0.0.1:11434";
  };

  # Ollama helper scripts
  home.file.".local/bin/ollama-setup" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Setup Ollama with popular models

      set -euo pipefail

      echo "=== Ollama Model Setup ==="
      echo ""

      # Start ollama if not running
      if ! pgrep -x ollama > /dev/null; then
        echo "Starting Ollama server..."
        ollama serve &
        sleep 3
      fi

      echo "Downloading recommended models..."
      echo ""

      # Code-focused models
      echo "→ Pulling codellama:7b (code generation)..."
      ollama pull codellama:7b

      echo "→ Pulling deepseek-coder:6.7b (code generation)..."
      ollama pull deepseek-coder:6.7b

      # General chat
      echo "→ Pulling llama3.2:latest (general)..."
      ollama pull llama3.2:latest

      echo "→ Pulling mistral:latest (general)..."
      ollama pull mistral:latest

      # Smaller/faster
      echo "→ Pulling phi3:mini (fast, small)..."
      ollama pull phi3:mini

      echo ""
      echo "=== Setup Complete ==="
      echo ""
      echo "Available models:"
      ollama list
      echo ""
      echo "Usage:"
      echo "  ollama run llama3.2     # Chat with model"
      echo "  ollama run codellama    # Code generation"
      echo "  ollama serve            # Start API server"
    '';
  };

  home.file.".local/bin/ai-chat" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Quick chat with local LLM

      MODEL="''${1:-llama3.2}"

      # Start ollama if not running
      if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo "Starting Ollama server..."
        ollama serve &
        sleep 3
      fi

      echo "Chatting with $MODEL (Ctrl+D to exit)"
      echo ""

      ollama run "$MODEL"
    '';
  };

  home.file.".local/bin/ai-code" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Code generation with local LLM

      MODEL="''${1:-codellama:7b}"

      # Start ollama if not running
      if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo "Starting Ollama server..."
        ollama serve &
        sleep 3
      fi

      echo "Code assistant with $MODEL (Ctrl+D to exit)"
      echo "Tip: Paste code and ask questions about it"
      echo ""

      ollama run "$MODEL"
    '';
  };

  # ============================================================================
  # OPEN WEBUI - Web interface for Ollama
  # ============================================================================

  home.file.".local/bin/openwebui-start" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Start Open WebUI for Ollama

      set -euo pipefail

      CONTAINER_NAME="open-webui"
      DATA_DIR="$HOME/.local/share/open-webui"

      mkdir -p "$DATA_DIR"

      # Check if already running
      if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo "Open WebUI already running at http://localhost:3000"
        exit 0
      fi

      # Remove old container if exists
      docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

      echo "Starting Open WebUI..."

      docker run -d \
        --name "$CONTAINER_NAME" \
        --restart unless-stopped \
        -p 3000:8080 \
        -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
        -v "$DATA_DIR:/app/backend/data" \
        --add-host=host.docker.internal:host-gateway \
        ghcr.io/open-webui/open-webui:main

      echo ""
      echo "Open WebUI started!"
      echo "Access at: http://localhost:3000"
      echo ""
      echo "Make sure Ollama is running: ollama serve"
    '';
  };

  home.file.".local/bin/openwebui-stop" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      docker stop open-webui 2>/dev/null && echo "Open WebUI stopped" || echo "Not running"
    '';
  };

  # ============================================================================
  # COMFYUI - Stable Diffusion workflow
  # ============================================================================

  home.file.".local/bin/comfyui-install" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Install ComfyUI for Stable Diffusion

      set -euo pipefail

      COMFY_DIR="$HOME/.local/share/comfyui"

      echo "=== ComfyUI Installation ==="
      echo ""

      if [ -d "$COMFY_DIR" ]; then
        echo "ComfyUI already installed at $COMFY_DIR"
        echo "To update, run: cd $COMFY_DIR && git pull"
        exit 0
      fi

      echo "Installing ComfyUI..."

      # Clone ComfyUI
      git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFY_DIR"
      cd "$COMFY_DIR"

      # Create venv
      python -m venv venv
      source venv/bin/activate

      # Install requirements
      pip install --upgrade pip
      pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
      pip install -r requirements.txt

      # Create model directories
      mkdir -p models/checkpoints
      mkdir -p models/vae
      mkdir -p models/loras
      mkdir -p models/controlnet
      mkdir -p models/upscale_models

      echo ""
      echo "=== Installation Complete ==="
      echo ""
      echo "Download models to: $COMFY_DIR/models/checkpoints/"
      echo ""
      echo "Recommended models:"
      echo "  - SDXL: https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0"
      echo "  - SD 1.5: https://huggingface.co/runwayml/stable-diffusion-v1-5"
      echo ""
      echo "Start with: comfyui-start"
    '';
  };

  home.file.".local/bin/comfyui-start" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Start ComfyUI

      COMFY_DIR="$HOME/.local/share/comfyui"

      if [ ! -d "$COMFY_DIR" ]; then
        echo "ComfyUI not installed. Run: comfyui-install"
        exit 1
      fi

      cd "$COMFY_DIR"
      source venv/bin/activate

      echo "Starting ComfyUI..."
      echo "Access at: http://localhost:8188"
      echo ""

      python main.py --listen 0.0.0.0 --port 8188
    '';
  };

  # ============================================================================
  # JUPYTER LAB FOR AI EXPERIMENTS
  # ============================================================================

  home.file.".local/bin/ai-notebook" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Start Jupyter Lab for AI experiments

      NOTEBOOK_DIR="''${1:-$HOME/notebooks}"
      mkdir -p "$NOTEBOOK_DIR"

      echo "Starting Jupyter Lab..."
      echo "Notebook directory: $NOTEBOOK_DIR"
      echo ""

      cd "$NOTEBOOK_DIR"
      jupyter lab --no-browser --ip=0.0.0.0 --port=8888
    '';
  };

  # ============================================================================
  # AI CONFIGURATION FILES
  # ============================================================================

  # Default Ollama Modelfile for custom models
  home.file.".local/share/ollama/Modelfile.template".text = ''
    # Custom Ollama Model Template
    # Usage: ollama create mymodel -f Modelfile

    FROM llama3.2

    # Set parameters
    PARAMETER temperature 0.7
    PARAMETER top_p 0.9
    PARAMETER top_k 40
    PARAMETER num_ctx 4096

    # System prompt
    SYSTEM """
    You are a helpful AI assistant. You are knowledgeable, concise, and friendly.
    When writing code, you follow best practices and include helpful comments.
    """
  '';

  # Coding assistant Modelfile
  home.file.".local/share/ollama/Modelfile.coder".text = ''
    # Coding Assistant Model
    FROM codellama:7b

    PARAMETER temperature 0.2
    PARAMETER top_p 0.95
    PARAMETER num_ctx 8192

    SYSTEM """
    You are an expert software engineer and coding assistant.

    Guidelines:
    - Write clean, maintainable, and well-documented code
    - Follow language-specific best practices and idioms
    - Explain your reasoning when helpful
    - Consider edge cases and error handling
    - Suggest improvements when you see them
    - Be concise but thorough

    When providing code:
    - Use appropriate formatting and syntax highlighting
    - Include relevant imports and dependencies
    - Add comments for complex logic
    """
  '';

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # Ollama
    oll = "ollama";
    ollrun = "ollama run";
    olllist = "ollama list";
    ollpull = "ollama pull";
    ollserve = "ollama serve";

    # Quick chat
    chat = "ai-chat";
    code-ai = "ai-code";

    # Open WebUI
    webui = "openwebui-start";
    webui-stop = "openwebui-stop";

    # ComfyUI (alias defined in comfyui.nix)
    comfy-basic = "comfyui-start";
    comfy-install = "comfyui-install";

    # Jupyter
    notebook = "ai-notebook";
    jlab = "jupyter lab";
  };
}
