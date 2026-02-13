{ config, pkgs, lib, inputs, ... }:

{
  # ============================================================================
  # PRISM THEMES - Unified theming across all editors
  # 64 curated color themes from github.com/justinfleek/PRISM
  # ============================================================================

  home.packages = with pkgs; [
    # Dependencies for theme management
    jq
    curl
    unzip
  ];

  # ============================================================================
  # CURSOR INSTALLATION SCRIPT
  # ============================================================================
  
  # Cursor isn't in nixpkgs - this script downloads and installs the AppImage
  home.file.".local/bin/cursor-install" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      
      CURSOR_DIR="$HOME/.local/opt/cursor"
      CURSOR_BIN="$HOME/.local/bin/cursor"
      CURSOR_APPIMAGE="$CURSOR_DIR/cursor.AppImage"
      
      echo "Installing Cursor IDE..."
      
      mkdir -p "$CURSOR_DIR"
      mkdir -p "$HOME/.local/bin"
      mkdir -p "$HOME/.local/share/applications"
      
      # Download latest Cursor AppImage
      echo "Downloading Cursor..."
      curl -fSL "https://downloader.cursor.sh/linux/appImage/x64" -o "$CURSOR_APPIMAGE"
      chmod +x "$CURSOR_APPIMAGE"
      
      # Create wrapper script
      cat > "$CURSOR_BIN" << 'WRAPPER'
      #!/usr/bin/env bash
      exec "$HOME/.local/opt/cursor/cursor.AppImage" --no-sandbox "$@"
      WRAPPER
      chmod +x "$CURSOR_BIN"
      
      # Create desktop entry
      cat > "$HOME/.local/share/applications/cursor.desktop" << 'DESKTOP'
      [Desktop Entry]
      Name=Cursor
      Comment=AI-first Code Editor
      Exec=$HOME/.local/bin/cursor %F
      Icon=cursor
      Type=Application
      Categories=Development;IDE;
      MimeType=text/plain;
      StartupWMClass=Cursor
      DESKTOP
      
      echo "Cursor installed!"
      echo "Run with: cursor"
    '';
  };

  # ============================================================================
  # CLONE PRISM REPO
  # ============================================================================

  home.file.".local/bin/prism-setup" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      
      PRISM_DIR="$HOME/.local/share/prism-themes"
      
      if [ -d "$PRISM_DIR" ]; then
        echo "Updating PRISM themes..."
        cd "$PRISM_DIR"
        git pull
      else
        echo "Cloning PRISM themes..."
        git clone https://github.com/justinfleek/PRISM.git "$PRISM_DIR"
      fi
      
      echo "Installing themes..."
      
      # OpenCode
      mkdir -p ~/.config/opencode/themes
      cp "$PRISM_DIR"/opencode/*.json ~/.config/opencode/themes/ 2>/dev/null || true
      
      # Neovim (handled by plugin, but copy anyway)
      mkdir -p ~/.config/nvim/colors
      
      # VS Code / Cursor extensions dir
      VSCODE_EXT="$HOME/.vscode/extensions/prism-themes"
      CURSOR_EXT="$HOME/.cursor/extensions/prism-themes"
      
      mkdir -p "$VSCODE_EXT"
      mkdir -p "$CURSOR_EXT"
      
      # Copy VS Code extension
      cp -r "$PRISM_DIR"/vscode/* "$VSCODE_EXT/" 2>/dev/null || true
      cp -r "$PRISM_DIR"/cursor/* "$CURSOR_EXT/" 2>/dev/null || true
      
      # Terminal themes
      mkdir -p ~/.config/alacritty/themes
      mkdir -p ~/.config/kitty/themes
      mkdir -p ~/.config/wezterm/colors
      
      cp "$PRISM_DIR"/terminal/alacritty/*.toml ~/.config/alacritty/themes/ 2>/dev/null || true
      cp "$PRISM_DIR"/terminal/kitty/*.conf ~/.config/kitty/themes/ 2>/dev/null || true
      cp "$PRISM_DIR"/terminal/wezterm/*.toml ~/.config/wezterm/colors/ 2>/dev/null || true
      
      echo "PRISM themes installed!"
      echo ""
      echo "Available themes:"
      ls "$PRISM_DIR"/core/themes/*.json | xargs -I{} basename {} .json | sed 's/prism-//'
    '';
  };

  # ============================================================================
  # OPENCODE THEMES CONFIG
  # ============================================================================

  # OpenCode uses themes from ~/.config/opencode/themes/
  # The prism-setup script copies them there

  # ============================================================================
  # CURSOR SETTINGS
  # ============================================================================

  # Cursor uses same config format as VS Code
  xdg.configFile."Cursor/User/settings.json".text = builtins.toJSON {
    # Theme
    "workbench.colorTheme" = "PRISM - Nord Aurora";
    
    # Font
    "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Fira Code', monospace";
    "editor.fontSize" = 14;
    "editor.fontLigatures" = true;
    "editor.fontWeight" = "400";
    
    # Editor
    "editor.cursorStyle" = "line";
    "editor.cursorBlinking" = "smooth";
    "editor.cursorSmoothCaretAnimation" = "on";
    "editor.smoothScrolling" = true;
    "editor.minimap.enabled" = false;
    "editor.renderLineHighlight" = "all";
    "editor.bracketPairColorization.enabled" = true;
    "editor.guides.bracketPairs" = true;
    "editor.stickyScroll.enabled" = true;
    
    # Terminal
    "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
    "terminal.integrated.fontSize" = 13;
    "terminal.integrated.cursorStyle" = "line";
    "terminal.integrated.cursorBlinking" = true;
    
    # Files
    "files.autoSave" = "onFocusChange";
    "files.trimTrailingWhitespace" = true;
    "files.insertFinalNewline" = true;
    
    # Git
    "git.autofetch" = true;
    "git.confirmSync" = false;
    
    # Cursor AI specific
    "cursor.cpp.enablePartialAccepts" = true;
  };

  # ============================================================================
  # VS CODE SETTINGS (same as Cursor)
  # ============================================================================

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium; # or pkgs.vscode
    
    userSettings = {
      # Theme
      "workbench.colorTheme" = "PRISM - Nord Aurora";
      
      # Font
      "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Fira Code', monospace";
      "editor.fontSize" = 14;
      "editor.fontLigatures" = true;
      
      # Editor
      "editor.cursorStyle" = "line";
      "editor.cursorBlinking" = "smooth";
      "editor.cursorSmoothCaretAnimation" = "on";
      "editor.smoothScrolling" = true;
      "editor.minimap.enabled" = false;
      "editor.renderLineHighlight" = "all";
      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = true;
      
      # Terminal
      "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
      "terminal.integrated.fontSize" = 13;
      
      # Files
      "files.autoSave" = "onFocusChange";
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;
    };
    
    extensions = with pkgs.vscode-extensions; [
      # Basics
      vscodevim.vim
      eamodio.gitlens
      
      # Languages
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
      ms-python.python
      
      # Themes (PRISM will be installed manually)
    ];
  };

  # ============================================================================
  # HYPERMODERN EMACS INTEGRATION
  # ============================================================================

  # Clone and setup hypermodern-emacs
  home.file.".local/bin/hypermodern-emacs-setup" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      
      EMACS_DIR="$HOME/.config/hypermodern-emacs"
      
      if [ -d "$EMACS_DIR" ]; then
        echo "Updating hypermodern-emacs..."
        cd "$EMACS_DIR"
        git pull
      else
        echo "Cloning hypermodern-emacs..."
        git clone https://github.com/b7r6/hypermodern-emacs.git "$EMACS_DIR"
      fi
      
      # Link to standard emacs location
      if [ ! -L "$HOME/.emacs.d" ] && [ ! -d "$HOME/.emacs.d" ]; then
        ln -s "$EMACS_DIR" "$HOME/.emacs.d"
        echo "Linked to ~/.emacs.d"
      fi
      
      echo "hypermodern-emacs installed!"
      echo ""
      echo "Run with: nix run github:b7r6/hypermodern-emacs"
      echo "Or: emacs (after first launch package download)"
    '';
  };

  # Emacs package
  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk; # Wayland native
    
    extraPackages = epkgs: with epkgs; [
      # Core
      use-package
      general
      which-key
      
      # Completion
      vertico
      orderless
      marginalia
      consult
      corfu
      cape
      
      # Git
      magit
      diff-hl
      
      # LSP
      eglot
      
      # Languages
      nix-mode
      rust-mode
      haskell-mode
      purescript-mode
      dhall-mode
      lean4-mode
      
      # UI
      doom-themes
      doom-modeline
      all-the-icons
      
      # Terminal
      vterm
      eat
      
      # AI
      gptel
      
      # Tools
      wgrep
      deadgrep
      avy
      ace-window
    ];
  };

  # ============================================================================
  # NEOVIM PRISM PLUGIN
  # ============================================================================

  # Add PRISM to Neovim plugins (extend neovim.nix)
  xdg.configFile."nvim/lua/plugins/prism.lua".text = ''
    return {
      {
        "justinfleek/PRISM",
        lazy = false,
        priority = 1000,
        config = function()
          -- PRISM themes are in neovim/ subfolder
          local prism_path = vim.fn.stdpath("data") .. "/lazy/PRISM/neovim"
          if vim.fn.isdirectory(prism_path) == 1 then
            vim.opt.rtp:prepend(prism_path)
          end
          
          -- Try to load PRISM
          local ok, prism = pcall(require, "prism")
          if ok then
            prism.setup({
              preset = "nord_aurora",
              -- Available presets:
              -- nord_aurora, catppuccin_mocha, gruvbox_material
              -- tokyo_night_bento, one_dark_pro, night_owl
              -- holographic, neon_nexus, vaporwave_sunset
              -- nero_marquina, midnight_sapphire, aurora_glass
            })
            vim.cmd("colorscheme prism")
          end
        end,
      },
    }
  '';

  # ============================================================================
  # THEME SWITCHER
  # ============================================================================

  home.file.".local/bin/theme-switch" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      PRISM_DIR="$HOME/.local/share/prism-themes"
      
      if [ ! -d "$PRISM_DIR" ]; then
        echo "PRISM themes not installed. Run: prism-setup"
        exit 1
      fi
      
      # List available themes
      THEMES=$(ls "$PRISM_DIR"/core/themes/prism-*.json | xargs -I{} basename {} .json | sed 's/prism-//' | sort)
      
      if [ -z "$1" ]; then
        echo "Available PRISM themes:"
        echo ""
        echo "$THEMES" | column
        echo ""
        echo "Usage: theme-switch <theme-name>"
        exit 0
      fi
      
      THEME="$1"
      THEME_FILE="$PRISM_DIR/core/themes/prism-$THEME.json"
      
      if [ ! -f "$THEME_FILE" ]; then
        echo "Theme not found: $THEME"
        echo "Run 'theme-switch' to see available themes"
        exit 1
      fi
      
      echo "Switching to theme: $THEME"
      
      # Update Cursor/VS Code
      if command -v jq &> /dev/null; then
        for settings in ~/.config/Cursor/User/settings.json ~/.config/Code/User/settings.json; do
          if [ -f "$settings" ]; then
            jq ".\"workbench.colorTheme\" = \"PRISM - $(echo $THEME | sed 's/_/ /g' | sed 's/\b\(.\)/\u\1/g')\"" "$settings" > "$settings.tmp"
            mv "$settings.tmp" "$settings"
            echo "Updated: $settings"
          fi
        done
      fi
      
      # Update OpenCode
      OPENCODE_THEME="$HOME/.config/opencode/themes/prism-$THEME.json"
      if [ -f "$OPENCODE_THEME" ]; then
        # OpenCode theme config
        echo "OpenCode theme available at: $OPENCODE_THEME"
      fi
      
      echo "Theme switched to: $THEME"
      echo "Note: Restart editors to apply changes"
    '';
  };

  # ============================================================================
  # AUTO-SETUP ON ACTIVATION
  # ============================================================================

  home.activation.prismSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Only run if git is available and not already set up
    if command -v git &> /dev/null; then
      if [ ! -d "$HOME/.local/share/prism-themes" ]; then
        $DRY_RUN_CMD $HOME/.local/bin/prism-setup || true
      fi
    fi
  '';
}
