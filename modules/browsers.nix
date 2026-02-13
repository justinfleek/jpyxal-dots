{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # BROWSERS - Zen, Vivaldi, Brave, and more
  # ============================================================================

  home.packages = with pkgs; [
    # Privacy-focused
    brave                  # Chromium-based privacy browser
    
    # Feature-rich
    vivaldi                # Customizable Chromium browser
    
    # Minimal
    qutebrowser           # Vim-like browser
    nyxt                   # Lisp-powered browser
    
    # CLI/TUI
    w3m                    # Terminal browser
    lynx                   # Classic terminal browser
    
    # Dev tools
    chromium               # For testing
  ];

  # ============================================================================
  # ZEN BROWSER - Firefox-based privacy browser
  # ============================================================================

  # Zen isn't in nixpkgs yet, so we create an install script
  home.file.".local/bin/zen-install" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      
      ZEN_DIR="$HOME/.local/opt/zen"
      ZEN_BIN="$HOME/.local/bin/zen"
      
      echo "Installing Zen Browser..."
      
      mkdir -p "$ZEN_DIR"
      mkdir -p "$HOME/.local/bin"
      mkdir -p "$HOME/.local/share/applications"
      
      # Get latest release
      LATEST=$(curl -sL https://api.github.com/repos/zen-browser/desktop/releases/latest | jq -r '.tag_name')
      
      echo "Downloading Zen Browser $LATEST..."
      
      # Download and extract
      curl -fSL "https://github.com/zen-browser/desktop/releases/download/$LATEST/zen.linux-specific.tar.bz2" \
        -o /tmp/zen.tar.bz2
      
      tar xjf /tmp/zen.tar.bz2 -C "$ZEN_DIR" --strip-components=1
      rm /tmp/zen.tar.bz2
      
      # Create wrapper
      cat > "$ZEN_BIN" << 'EOF'
      #!/usr/bin/env bash
      exec "$HOME/.local/opt/zen/zen" "$@"
      EOF
      chmod +x "$ZEN_BIN"
      
      # Desktop entry
      cat > "$HOME/.local/share/applications/zen.desktop" << 'EOF'
      [Desktop Entry]
      Name=Zen Browser
      Comment=Privacy-focused Firefox-based browser
      Exec=zen %u
      Icon=zen
      Type=Application
      Categories=Network;WebBrowser;
      MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
      StartupWMClass=zen
      EOF
      
      echo "Zen Browser installed!"
      echo "Run with: zen"
    '';
  };

  # ============================================================================
  # QUTEBROWSER - Vim-like browser
  # ============================================================================

  programs.qutebrowser = {
    enable = true;
    
    settings = {
      # Theme (Catppuccin Mocha)
      colors = {
        completion = {
          fg = "#cdd6f4";
          odd.bg = "#313244";
          even.bg = "#1e1e2e";
          category = {
            fg = "#89b4fa";
            bg = "#1e1e2e";
            border.top = "#1e1e2e";
            border.bottom = "#1e1e2e";
          };
          item.selected = {
            fg = "#cdd6f4";
            bg = "#45475a";
            border.top = "#89b4fa";
            border.bottom = "#89b4fa";
            match.fg = "#f9e2af";
          };
          match.fg = "#a6e3a1";
          scrollbar = {
            fg = "#89b4fa";
            bg = "#1e1e2e";
          };
        };
        
        contextmenu = {
          disabled.bg = "#313244";
          disabled.fg = "#6c7086";
          menu.bg = "#1e1e2e";
          menu.fg = "#cdd6f4";
          selected.bg = "#45475a";
          selected.fg = "#cdd6f4";
        };
        
        downloads = {
          bar.bg = "#1e1e2e";
          start.fg = "#1e1e2e";
          start.bg = "#89b4fa";
          stop.fg = "#1e1e2e";
          stop.bg = "#a6e3a1";
          error.fg = "#f38ba8";
        };
        
        hints = {
          fg = "#1e1e2e";
          bg = "#f9e2af";
          match.fg = "#45475a";
        };
        
        keyhint = {
          fg = "#cdd6f4";
          suffix.fg = "#a6e3a1";
          bg = "#1e1e2e";
        };
        
        messages = {
          error = {
            fg = "#1e1e2e";
            bg = "#f38ba8";
            border = "#f38ba8";
          };
          warning = {
            fg = "#1e1e2e";
            bg = "#f9e2af";
            border = "#f9e2af";
          };
          info = {
            fg = "#cdd6f4";
            bg = "#1e1e2e";
            border = "#1e1e2e";
          };
        };
        
        prompts = {
          fg = "#cdd6f4";
          border = "#1e1e2e";
          bg = "#1e1e2e";
          selected.bg = "#45475a";
          selected.fg = "#cdd6f4";
        };
        
        statusbar = {
          normal.fg = "#cdd6f4";
          normal.bg = "#1e1e2e";
          insert.fg = "#1e1e2e";
          insert.bg = "#a6e3a1";
          passthrough.fg = "#1e1e2e";
          passthrough.bg = "#89b4fa";
          private.fg = "#cdd6f4";
          private.bg = "#45475a";
          command.fg = "#cdd6f4";
          command.bg = "#1e1e2e";
          command.private.fg = "#cdd6f4";
          command.private.bg = "#1e1e2e";
          caret.fg = "#1e1e2e";
          caret.bg = "#cba6f7";
          caret.selection.fg = "#1e1e2e";
          caret.selection.bg = "#cba6f7";
          progress.bg = "#89b4fa";
          url.fg = "#cdd6f4";
          url.error.fg = "#f38ba8";
          url.hover.fg = "#94e2d5";
          url.success.http.fg = "#a6e3a1";
          url.success.https.fg = "#a6e3a1";
          url.warn.fg = "#f9e2af";
        };
        
        tabs = {
          bar.bg = "#181825";
          indicator.start = "#89b4fa";
          indicator.stop = "#a6e3a1";
          indicator.error = "#f38ba8";
          odd.fg = "#cdd6f4";
          odd.bg = "#313244";
          even.fg = "#cdd6f4";
          even.bg = "#1e1e2e";
          pinned.even.bg = "#a6e3a1";
          pinned.even.fg = "#1e1e2e";
          pinned.odd.bg = "#a6e3a1";
          pinned.odd.fg = "#1e1e2e";
          pinned.selected.even.bg = "#45475a";
          pinned.selected.even.fg = "#cdd6f4";
          pinned.selected.odd.bg = "#45475a";
          pinned.selected.odd.fg = "#cdd6f4";
          selected.odd.fg = "#cdd6f4";
          selected.odd.bg = "#45475a";
          selected.even.fg = "#cdd6f4";
          selected.even.bg = "#45475a";
        };
        
        webpage = {
          preferred_color_scheme = "dark";
        };
      };
      
      # Font
      fonts = {
        default_family = "JetBrainsMono Nerd Font";
        default_size = "12pt";
        web.family.standard = "Inter";
        web.family.sans_serif = "Inter";
        web.family.serif = "Noto Serif";
        web.family.fixed = "JetBrainsMono Nerd Font";
      };
      
      # Scrolling
      scrolling.smooth = true;
      
      # Tabs
      tabs.position = "top";
      tabs.show = "multiple";
      tabs.last_close = "close";
      
      # Privacy
      content.cookies.accept = "no-3rdparty";
      content.geolocation = false;
      content.headers.do_not_track = true;
      
      # Ad blocking
      content.blocking.enabled = true;
      content.blocking.method = "both";
      content.blocking.adblock.lists = [
        "https://easylist.to/easylist/easylist.txt"
        "https://easylist.to/easylist/easyprivacy.txt"
        "https://easylist.to/easylist/fanboy-annoyance.txt"
      ];
      
      # Downloads
      downloads.location.directory = "~/Downloads";
      downloads.location.prompt = false;
      
      # URL
      url.default_page = "about:blank";
      url.start_pages = ["about:blank"];
      url.searchengines = {
        DEFAULT = "https://duckduckgo.com/?q={}";
        g = "https://google.com/search?q={}";
        gh = "https://github.com/search?q={}";
        nix = "https://search.nixos.org/packages?query={}";
        yt = "https://youtube.com/results?search_query={}";
        wiki = "https://en.wikipedia.org/wiki/{}";
      };
      
      # Hints
      hints.chars = "asdfghjkl";
      hints.uppercase = true;
    };
    
    keyBindings = {
      normal = {
        # Vim-style tab navigation
        "J" = "tab-prev";
        "K" = "tab-next";
        "d" = "tab-close";
        "u" = "undo";
        
        # Scrolling
        "j" = "scroll-px 0 100";
        "k" = "scroll-px 0 -100";
        "h" = "scroll-px -100 0";
        "l" = "scroll-px 100 0";
        
        # Page navigation
        "<Ctrl-d>" = "scroll-page 0 0.5";
        "<Ctrl-u>" = "scroll-page 0 -0.5";
        "gg" = "scroll-to-perc 0";
        "G" = "scroll-to-perc 100";
        
        # Quick bookmarks
        "M" = "quickmark-save";
        "b" = "quickmark-load";
        "B" = "bookmark-add";
        
        # Open
        "O" = "set-cmd-text -s :open -t";
        "t" = "set-cmd-text -s :open -t";
        
        # Yank
        "yy" = "yank";
        "yt" = "yank title";
        
        # Zoom
        "zi" = "zoom-in";
        "zo" = "zoom-out";
        "zz" = "zoom 100";
        
        # Toggle
        "xx" = "config-cycle content.javascript.enabled";
        "xb" = "config-cycle content.blocking.enabled";
      };
    };
    
    extraConfig = ''
      # Extra qutebrowser config
      config.load_autoconfig(False)
    '';
  };

  # ============================================================================
  # VIVALDI FLAGS
  # ============================================================================

  xdg.configFile."vivaldi-stable.conf".text = ''
    # Vivaldi command-line flags
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
    --enable-gpu-rasterization
    --enable-zero-copy
    --ignore-gpu-blocklist
  '';

  # ============================================================================
  # BRAVE FLAGS  
  # ============================================================================

  xdg.configFile."brave-flags.conf".text = ''
    # Brave command-line flags
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
    --enable-gpu-rasterization
    --enable-zero-copy
    --ignore-gpu-blocklist
  '';

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    ff = "firefox";
    brave = "brave";
    viv = "vivaldi";
    qb = "qutebrowser";
    zen-update = "zen-install";
  };
}
