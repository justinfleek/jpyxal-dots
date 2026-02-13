{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # API TOOLS - Posting, HTTPie, REST clients
  # ============================================================================

  home.packages = with pkgs; [
    # TUI API clients
    posting                # TUI API client (Postman alternative)
    
    # CLI HTTP clients
    httpie                 # Human-friendly HTTP client
    curlie                 # HTTPie-like with curl backend
    xh                     # Fast httpie alternative in Rust
    
    # API testing
    hurl                   # Run and test HTTP requests
    grpcurl                # gRPC CLI tool
    
    # WebSocket
    websocat               # WebSocket CLI client
    
    # GraphQL
    gq                     # GraphQL CLI
    
    # JSON tools
    jq                     # JSON processor
    jaq                    # jq clone in Rust
    fx                     # Interactive JSON viewer
    
    # API documentation
    # insomnia             # GUI API client (if needed)
  ];

  # ============================================================================
  # POSTING - TUI API Client (Postman alternative)
  # ============================================================================

  xdg.configFile."posting/config.yaml".text = ''
    # Posting Configuration
    
    theme: catppuccin-mocha
    
    editor:
      command: nvim
      
    keybindings:
      send: ctrl+enter
      save: ctrl+s
      new: ctrl+n
      open: ctrl+o
      
    defaults:
      content_type: application/json
      
    collections_dir: ~/.local/share/posting/collections
  '';

  # ============================================================================
  # HTTPIE CONFIG
  # ============================================================================

  xdg.configFile."httpie/config.json".text = builtins.toJSON {
    default_options = [
      "--style=monokai"
      "--print=hb"
    ];
  };

  # ============================================================================
  # HURL CONFIG
  # ============================================================================

  xdg.configFile."hurl/.hurl_options".text = ''
    --color
    --verbose
  '';

  # ============================================================================
  # USEFUL API SCRIPTS
  # ============================================================================

  home.file.".local/bin/api-test" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Quick API testing helper
      
      METHOD="''${1:-GET}"
      URL="$2"
      DATA="$3"
      
      if [ -z "$URL" ]; then
        echo "Usage: api-test [METHOD] URL [DATA]"
        echo ""
        echo "Examples:"
        echo "  api-test GET https://api.example.com/users"
        echo "  api-test POST https://api.example.com/users '{\"name\": \"test\"}'"
        echo "  api-test https://api.example.com/users  # defaults to GET"
        exit 1
      fi
      
      # If first arg looks like URL, shift
      if [[ "$METHOD" == http* ]]; then
        URL="$METHOD"
        METHOD="GET"
        DATA="$2"
      fi
      
      echo "→ $METHOD $URL"
      echo ""
      
      if [ -n "$DATA" ]; then
        xh "$METHOD" "$URL" --raw "$DATA"
      else
        xh "$METHOD" "$URL"
      fi
    '';
  };

  home.file.".local/bin/jwt-decode" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Decode JWT token
      
      TOKEN="$1"
      
      if [ -z "$TOKEN" ]; then
        echo "Usage: jwt-decode <token>"
        echo "Or: echo <token> | jwt-decode"
        read -r TOKEN
      fi
      
      # Remove Bearer prefix if present
      TOKEN="''${TOKEN#Bearer }"
      
      # Split and decode
      header=$(echo "$TOKEN" | cut -d'.' -f1 | base64 -d 2>/dev/null | jq -r '.')
      payload=$(echo "$TOKEN" | cut -d'.' -f2 | base64 -d 2>/dev/null | jq -r '.')
      
      echo "=== HEADER ==="
      echo "$header" | jq -C '.'
      echo ""
      echo "=== PAYLOAD ==="
      echo "$payload" | jq -C '.'
      
      # Show expiration if present
      exp=$(echo "$payload" | jq -r '.exp // empty')
      if [ -n "$exp" ]; then
        echo ""
        echo "=== EXPIRATION ==="
        date -d "@$exp" 2>/dev/null || date -r "$exp" 2>/dev/null
      fi
    '';
  };

  home.file.".local/bin/curl-time" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Detailed curl timing
      
      URL="$1"
      
      if [ -z "$URL" ]; then
        echo "Usage: curl-time <url>"
        exit 1
      fi
      
      curl -w @- -o /dev/null -s "$URL" << 'EOF'
         DNS Lookup: %{time_namelookup}s
        TCP Connect: %{time_connect}s
       TLS Handshake: %{time_appconnect}s
      Server Processing: %{time_starttransfer}s
      ----------------
          Total Time: %{time_total}s
      
          Response Code: %{http_code}
          Downloaded: %{size_download} bytes
          Speed: %{speed_download} bytes/sec
      EOF
    '';
  };

  home.file.".local/bin/json-server" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Quick mock JSON API server
      
      FILE="''${1:-db.json}"
      PORT="''${2:-3000}"
      
      if [ ! -f "$FILE" ]; then
        echo "Creating sample $FILE..."
        cat > "$FILE" << 'JSON'
      {
        "users": [
          { "id": 1, "name": "Alice", "email": "alice@example.com" },
          { "id": 2, "name": "Bob", "email": "bob@example.com" }
        ],
        "posts": [
          { "id": 1, "title": "Hello World", "userId": 1 },
          { "id": 2, "title": "Second Post", "userId": 2 }
        ]
      }
      JSON
      fi
      
      echo "Starting JSON server on http://localhost:$PORT"
      echo ""
      echo "Endpoints:"
      jq -r 'keys[]' "$FILE" | while read -r key; do
        echo "  GET    http://localhost:$PORT/$key"
        echo "  GET    http://localhost:$PORT/$key/:id"
        echo "  POST   http://localhost:$PORT/$key"
        echo "  PUT    http://localhost:$PORT/$key/:id"
        echo "  DELETE http://localhost:$PORT/$key/:id"
        echo ""
      done
      
      # Use npx json-server if available, otherwise python
      if command -v npx &> /dev/null; then
        npx json-server --watch "$FILE" --port "$PORT"
      else
        echo "Install json-server: npm install -g json-server"
        echo "Or use: python -m http.server $PORT"
      fi
    '';
  };

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # HTTPie style
    http = "xh";
    https = "xh --https";
    GET = "xh GET";
    POST = "xh POST";
    PUT = "xh PUT";
    DELETE = "xh DELETE";
    PATCH = "xh PATCH";
    
    # Quick requests
    jget = "curl -s | jq";
    
    # Tools
    api = "posting";
    ws = "websocat";
    jwt = "jwt-decode";
    
    # Testing
    timing = "curl-time";
  };
}
