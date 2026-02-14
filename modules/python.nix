{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================================================
  # PYTHON - Unified Python environment for all AI/ML/Dev needs
  # Consolidates: nvidia.nix, ai-local.nix, ai-coding.nix, speech.nix
  # ============================================================================

  home.packages = with pkgs; [
    # Single unified Python environment
    (python312.withPackages (
      ps: with ps; [
        # === CORE ML (from nvidia.nix) ===
        torch
        torchvision
        torchaudio
        pynvml
        gputil
        cupy

        # === AI/LLM (from ai-local.nix) ===
        # Transformers & LLMs
        transformers
        accelerate
        bitsandbytes
        sentencepiece
        tokenizers
        safetensors

        # Image generation
        diffusers

        # Jupyter
        jupyterlab
        ipywidgets
        notebook

        # API clients
        openai
        anthropic

        # Local inference
        llama-cpp-python

        # === CODING TOOLS (from ai-coding.nix) ===
        tiktoken
        gitpython
        prompt-toolkit
        rich
        pygments

        # === SPEECH (from speech.nix) ===
        openai-whisper
        sounddevice
        soundfile
        pyaudio
        pyttsx3
        speechrecognition

        # === COMFYUI (from comfyui.nix) ===
        opencv4
        einops
        kornia
        scikit-image

        # === CORE UTILITIES ===
        numpy
        pillow
        requests
        tqdm
        pyyaml
        httpx
        aiohttp
        aiofiles

        # === DATA SCIENCE ===
        pandas
        scipy
        matplotlib
        seaborn
        scikit-learn

        # === DEV TOOLS ===
        pip
        virtualenv
        black
        ruff
        mypy
        pytest
        ipython

        # === WEB/API ===
        fastapi
        uvicorn
        pydantic

        # === EXTRA UTILITIES ===
        python-dotenv
        click
        typer
        websockets
        watchdog
      ]
    ))
  ];

  # ============================================================================
  # PYTHON ENVIRONMENT VARIABLES
  # ============================================================================

  home.sessionVariables = {
    # Prevent Python from writing bytecode
    PYTHONDONTWRITEBYTECODE = "1";

    # Unbuffered output
    PYTHONUNBUFFERED = "1";

    # User site packages
    PYTHONUSERBASE = "$HOME/.local";

    # For better torch performance
    PYTORCH_CUDA_ALLOC_CONF = "expandable_segments:True";
  };

  # ============================================================================
  # PYTHON HELPER SCRIPTS
  # ============================================================================

  home.file.".local/bin/py-info" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Show Python environment info

      echo "=== Python Environment ==="
      echo ""
      echo "Python: $(python3 --version)"
      echo "Location: $(which python3)"
      echo ""
      echo "Key packages:"
      python3 -c "
      import sys
      packages = ['torch', 'transformers', 'openai', 'anthropic', 'whisper', 'jupyterlab']
      for pkg in packages:
          try:
              mod = __import__(pkg)
              ver = getattr(mod, '__version__', 'installed')
              print(f'  {pkg}: {ver}')
          except ImportError:
              print(f'  {pkg}: NOT INSTALLED')
      "
      echo ""
      echo "CUDA available:"
      python3 -c "import torch; print(f'  {torch.cuda.is_available()} (devices: {torch.cuda.device_count()})')" 2>/dev/null || echo "  torch not available"
    '';
  };

  home.file.".local/bin/py-venv" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Create a Python venv with access to system packages

      VENV_NAME="''${1:-.venv}"

      echo "Creating venv: $VENV_NAME (with system packages)"
      python3 -m venv --system-site-packages "$VENV_NAME"

      echo ""
      echo "Activate with: source $VENV_NAME/bin/activate"
    '';
  };

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    py = "python3";
    ipy = "ipython";
    jlab = "jupyter lab";
    jnb = "jupyter notebook";
    pyinfo = "py-info";
    pyvenv = "py-venv";
  };
}
