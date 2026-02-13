{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # NVIDIA GPU - CUDA, tools, ML/AI support
  # ============================================================================

  home.packages = with pkgs; [
    # CUDA toolkit
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    cudaPackages.cutensor
    cudaPackages.nccl
    
    # GPU monitoring
    nvtopPackages.full     # GPU monitoring TUI
    nvitop                 # Rich GPU monitoring
    gpustat                # Simple GPU stats
    
    # NVIDIA tools
    nvidia-container-toolkit  # Docker GPU support
    
    # OpenCL
    ocl-icd
    opencl-headers
    clinfo                  # OpenCL info
    
    # Vulkan
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    vulkan-extension-layer
    
    # Video encoding
    ffmpeg-full            # With NVENC support
    
    # ML/AI frameworks (with GPU)
    (python312.withPackages (ps: with ps; [
      # PyTorch with CUDA
      torch
      torchvision
      torchaudio
      
      # TensorFlow (if needed)
      # tensorflow
      
      # GPU utilities
      pynvml
      gputil
      
      # CUDA Python
      cupy
    ]))
  ];

  # ============================================================================
  # ENVIRONMENT VARIABLES
  # ============================================================================

  home.sessionVariables = {
    # CUDA
    CUDA_HOME = "${pkgs.cudaPackages.cudatoolkit}";
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    
    # cuDNN
    CUDNN_HOME = "${pkgs.cudaPackages.cudnn}";
    
    # For PyTorch/TensorFlow
    XLA_FLAGS = "--xla_gpu_cuda_data_dir=${pkgs.cudaPackages.cudatoolkit}";
    
    # Vulkan
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    
    # Hardware acceleration for video
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
    
    # Fix for some CUDA applications
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    
    # For Ollama GPU support
    OLLAMA_GPU_DRIVER = "nvidia";
  };

  # Add CUDA to library path
  home.sessionPath = [
    "${pkgs.cudaPackages.cudatoolkit}/bin"
    "${pkgs.cudaPackages.cudatoolkit}/nvvm/bin"
  ];

  # ============================================================================
  # GPU MONITORING SCRIPTS
  # ============================================================================

  home.file.".local/bin/gpu-status" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Quick GPU status
      
      echo "=== NVIDIA GPU Status ==="
      echo ""
      
      nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,utilization.memory,memory.used,memory.total,power.draw --format=csv,noheader,nounits | \
      while IFS=',' read -r name temp util mem_util mem_used mem_total power; do
        echo "GPU: $name"
        echo "  Temperature: ''${temp}°C"
        echo "  GPU Usage: ''${util}%"
        echo "  Memory: ''${mem_used}MB / ''${mem_total}MB (''${mem_util}%)"
        echo "  Power: ''${power}W"
      done
    '';
  };

  home.file.".local/bin/gpu-watch" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Watch GPU status continuously
      
      watch -n 1 nvidia-smi
    '';
  };

  home.file.".local/bin/gpu-processes" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Show processes using GPU
      
      echo "=== GPU Processes ==="
      echo ""
      nvidia-smi --query-compute-apps=pid,name,used_memory --format=csv
    '';
  };

  home.file.".local/bin/gpu-kill" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Kill GPU processes (careful!)
      
      echo "Current GPU processes:"
      nvidia-smi --query-compute-apps=pid,name,used_memory --format=csv
      echo ""
      
      read -p "Kill all GPU processes? (y/N): " confirm
      
      if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        nvidia-smi --query-compute-apps=pid --format=csv,noheader | xargs -r kill -9
        echo "GPU processes killed"
      else
        echo "Cancelled"
      fi
    '';
  };

  # ============================================================================
  # CUDA TESTING
  # ============================================================================

  home.file.".local/bin/cuda-test" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Test CUDA installation
      
      echo "=== CUDA Test ==="
      echo ""
      
      echo "CUDA Version:"
      nvcc --version 2>/dev/null || echo "nvcc not found in PATH"
      echo ""
      
      echo "NVIDIA Driver:"
      nvidia-smi --query-gpu=driver_version --format=csv,noheader
      echo ""
      
      echo "CUDA Compute Capability:"
      nvidia-smi --query-gpu=compute_cap --format=csv,noheader
      echo ""
      
      echo "Testing PyTorch CUDA..."
      python3 << 'PYTHON'
      import torch
      print(f"PyTorch version: {torch.__version__}")
      print(f"CUDA available: {torch.cuda.is_available()}")
      if torch.cuda.is_available():
          print(f"CUDA version: {torch.version.cuda}")
          print(f"cuDNN version: {torch.backends.cudnn.version()}")
          print(f"GPU count: {torch.cuda.device_count()}")
          for i in range(torch.cuda.device_count()):
              print(f"  GPU {i}: {torch.cuda.get_device_name(i)}")
              print(f"    Memory: {torch.cuda.get_device_properties(i).total_memory / 1e9:.1f} GB")
      
      # Quick compute test
      if torch.cuda.is_available():
          print("\nRunning quick GPU compute test...")
          x = torch.randn(1000, 1000, device='cuda')
          y = torch.randn(1000, 1000, device='cuda')
          z = torch.mm(x, y)
          torch.cuda.synchronize()
          print("GPU compute test: PASSED")
      PYTHON
    '';
  };

  home.file.".local/bin/cuda-benchmark" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Simple CUDA benchmark
      
      echo "=== CUDA Benchmark ==="
      echo ""
      
      python3 << 'PYTHON'
      import torch
      import time
      
      if not torch.cuda.is_available():
          print("CUDA not available!")
          exit(1)
      
      device = torch.device('cuda')
      
      # Matrix sizes to test
      sizes = [1024, 2048, 4096, 8192]
      
      print("Matrix Multiplication Benchmark")
      print("-" * 50)
      
      for size in sizes:
          # Create random matrices
          a = torch.randn(size, size, device=device)
          b = torch.randn(size, size, device=device)
          
          # Warmup
          c = torch.mm(a, b)
          torch.cuda.synchronize()
          
          # Benchmark
          start = time.time()
          iterations = 10
          for _ in range(iterations):
              c = torch.mm(a, b)
          torch.cuda.synchronize()
          elapsed = time.time() - start
          
          # Calculate FLOPS
          flops = (2 * size ** 3 * iterations) / elapsed
          tflops = flops / 1e12
          
          print(f"{size}x{size}: {elapsed/iterations*1000:.2f}ms per iteration, {tflops:.2f} TFLOPS")
      
      print("-" * 50)
      print(f"GPU: {torch.cuda.get_device_name(0)}")
      PYTHON
    '';
  };

  # ============================================================================
  # DOCKER GPU SETUP
  # ============================================================================

  home.file.".local/bin/docker-gpu-test" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Test Docker GPU access
      
      echo "=== Docker GPU Test ==="
      echo ""
      
      # Check nvidia-container-toolkit
      if ! command -v nvidia-container-toolkit &> /dev/null; then
        echo "nvidia-container-toolkit not found!"
        echo "Install with: nix-env -iA nixpkgs.nvidia-container-toolkit"
        exit 1
      fi
      
      echo "Running nvidia-smi in Docker container..."
      docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
    '';
  };

  # ============================================================================
  # WAYLAND + NVIDIA
  # ============================================================================

  # Additional environment for Wayland on NVIDIA
  home.file.".config/environment.d/nvidia-wayland.conf".text = ''
    # NVIDIA Wayland environment variables
    
    # Use GBM backend for Wayland
    GBM_BACKEND=nvidia-drm
    __GLX_VENDOR_LIBRARY_NAME=nvidia
    
    # Hardware cursors can cause issues
    WLR_NO_HARDWARE_CURSORS=1
    
    # Enable Wayland for Electron apps
    ELECTRON_OZONE_PLATFORM_HINT=auto
    
    # Firefox/Thunderbird
    MOZ_ENABLE_WAYLAND=1
    
    # Qt
    QT_QPA_PLATFORM=wayland
    
    # SDL
    SDL_VIDEODRIVER=wayland
  '';

  # ============================================================================
  # OLLAMA GPU CONFIG
  # ============================================================================

  home.file.".local/bin/ollama-gpu-setup" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Setup Ollama for GPU acceleration
      
      echo "=== Ollama GPU Setup ==="
      echo ""
      
      # Check GPU
      if ! nvidia-smi &> /dev/null; then
        echo "NVIDIA GPU not detected!"
        exit 1
      fi
      
      echo "GPU detected:"
      nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
      echo ""
      
      # Set environment
      export OLLAMA_GPU_DRIVER=nvidia
      
      echo "Starting Ollama with GPU support..."
      echo "Pulling a model to test..."
      
      ollama serve &
      sleep 3
      
      # Test with a small model
      echo "Testing GPU inference..."
      ollama run phi3:mini "Hello, are you running on GPU?" --verbose
      
      echo ""
      echo "Check GPU usage:"
      nvidia-smi --query-compute-apps=pid,name,used_memory --format=csv
    '';
  };

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # GPU monitoring
    gpu = "nvtop";
    gpus = "gpu-status";
    gpuw = "nvitop";
    gpustat = "gpustat";
    
    # NVIDIA
    nv = "nvidia-smi";
    nvw = "watch -n 1 nvidia-smi";
    nvp = "gpu-processes";
    
    # CUDA
    cuda-check = "cuda-test";
    cuda-bench = "cuda-benchmark";
    
    # Vulkan
    vulkan-check = "vulkaninfo --summary";
  };
}
