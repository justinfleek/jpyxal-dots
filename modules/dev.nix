{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # DEVELOPMENT - Extra development tools and languages
  # ============================================================================

  home.packages = with pkgs; [
    # === LANGUAGES ===
    # Rust
    rustup
    cargo-watch
    cargo-edit
    cargo-audit
    cargo-outdated
    
    # Go
    go
    gopls
    golangci-lint
    delve
    
    # Python
    python312
    python312Packages.pip
    python312Packages.virtualenv
    poetry
    ruff
    pyright
    
    # Node.js
    nodejs_22
    bun
    deno
    pnpm
    yarn
    
    # C/C++
    gcc
    clang
    cmake
    gnumake
    ninja
    
    # Zig
    zig
    zls
    
    # Haskell
    ghc
    cabal-install
    stack
    haskell-language-server
    
    # Elixir
    elixir
    elixir-ls
    
    # Java/Kotlin
    jdk21
    gradle
    kotlin
    kotlin-language-server
    
    # === DATABASES ===
    postgresql
    sqlite
    redis
    mysql
    dbeaver
    
    # Database CLIs
    pgcli
    litecli
    mycli
    
    # === API TOOLS ===
    httpie
    xh                       # Rust httpie
    curlie                   # Curl + httpie
    grpcurl                  # gRPC CLI
    postman                  # API testing GUI
    insomnia                 # API testing GUI
    
    # === JSON/YAML ===
    jq
    yq
    fx                       # JSON viewer
    jless                    # JSON pager
    
    # === DEBUGGING ===
    gdb
    lldb
    valgrind
    strace
    ltrace
    
    # === PROFILING ===
    heaptrack
    perf-tools
    hyperfine                # Benchmarking
    
    # === BUILD TOOLS ===
    just                     # Task runner
    task                     # Task runner (Taskfile)
    meson
    
    # === VERSION CONTROL ===
    git-lfs
    git-crypt
    pre-commit
    commitizen
    
    # === SECURITY ===
    trivy                    # Container scanning
    semgrep                  # Code analysis
    gitleaks                 # Secret scanning
    
    # === DOCUMENTATION ===
    mdbook                   # Markdown books
    
    # === CLOUD CLIs ===
    awscli2
    google-cloud-sdk
    azure-cli
    doctl                    # DigitalOcean
    flyctl                   # Fly.io
    netlify-cli
    vercel
    
    # === MISC ===
    watchexec                # File watcher
    entr                     # Run command on change
    tokei                    # Code stats
    scc                      # Code counter
    cloc                     # Lines of code
    grex                     # Regex generator
    sd                       # sed alternative
    choose                   # cut alternative
    tealdeer                 # tldr client
    navi                     # Cheatsheet
  ];

  # ============================================================================
  # JUST CONFIG
  # ============================================================================

  xdg.configFile."just/justfile".text = ''
    # Default justfile template
    
    default:
      @just --list
    
    # Run development server
    dev:
      @echo "Override this in your project"
    
    # Run tests
    test:
      @echo "Override this in your project"
    
    # Build project
    build:
      @echo "Override this in your project"
    
    # Format code
    fmt:
      @echo "Override this in your project"
    
    # Lint code
    lint:
      @echo "Override this in your project"
  '';

  # ============================================================================
  # PRE-COMMIT CONFIG
  # ============================================================================

  xdg.configFile."pre-commit/default-config.yaml".text = ''
    # Default pre-commit config
    repos:
      - repo: https://github.com/pre-commit/pre-commit-hooks
        rev: v4.5.0
        hooks:
          - id: trailing-whitespace
          - id: end-of-file-fixer
          - id: check-yaml
          - id: check-json
          - id: check-added-large-files
          - id: check-merge-conflict
          - id: detect-private-key
    
      - repo: https://github.com/commitizen-tools/commitizen
        rev: v3.13.0
        hooks:
          - id: commitizen
          - id: commitizen-branch
            stages: [push]
  '';

  # ============================================================================
  # EDITORCONFIG
  # ============================================================================

  home.file.".editorconfig".text = ''
    # EditorConfig
    root = true

    [*]
    indent_style = space
    indent_size = 2
    end_of_line = lf
    charset = utf-8
    trim_trailing_whitespace = true
    insert_final_newline = true

    [*.md]
    trim_trailing_whitespace = false

    [*.py]
    indent_size = 4

    [*.go]
    indent_style = tab
    indent_size = 4

    [Makefile]
    indent_style = tab

    [*.{rs,toml}]
    indent_size = 4
  '';

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # Just
    j = "just";
    jl = "just --list";
    
    # Python
    py = "python3";
    pip = "pip3";
    venv = "python3 -m venv";
    activate = "source .venv/bin/activate";
    
    # Node
    pn = "pnpm";
    ni = "npm install";
    nr = "npm run";
    
    # Cargo
    cb = "cargo build";
    cr = "cargo run";
    ct = "cargo test";
    cw = "cargo watch -x run";
    
    # Go
    gr = "go run .";
    gb = "go build";
    gt = "go test ./...";
    
    # Database
    pg = "pgcli";
    sql = "litecli";
    
    # HTTP
    http = "xh";
    
    # JSON
    jqp = "jless";
    
    # Benchmarking
    bench = "hyperfine";
    
    # Code stats
    stats = "tokei";
    
    # Watch files
    watch = "watchexec";
  };

  # ============================================================================
  # DEVELOPMENT FUNCTIONS
  # ============================================================================

  programs.bash.initExtra = lib.mkAfter ''
    # Quick project setup
    mkproject() {
      local name="''${1:-project}"
      local lang="''${2:-node}"
      
      mkdir -p "$name"
      cd "$name"
      git init
      
      case "$lang" in
        node)
          npm init -y
          echo "node_modules/" > .gitignore
          ;;
        rust)
          cargo init
          ;;
        python)
          python3 -m venv .venv
          echo ".venv/" > .gitignore
          touch requirements.txt
          ;;
        go)
          go mod init "$name"
          ;;
      esac
      
      echo "# $name" > README.md
      git add -A
      git commit -m "Initial commit"
      
      echo "Project '$name' created with $lang template"
    }
    
    # Quick HTTP server
    serve() {
      local port="''${1:-8000}"
      echo "Serving on http://localhost:$port"
      python3 -m http.server "$port"
    }
    
    # Run command on file change
    onchange() {
      watchexec -e "''${2:-*}" -- "$1"
    }
    
    # Quick benchmark
    benchmark() {
      hyperfine --warmup 3 "$@"
    }
  '';
}
