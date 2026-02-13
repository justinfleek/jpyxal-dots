{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # EXTRA EDITORS - Helix, Neovide
  # ============================================================================

  home.packages = with pkgs; [
    neovide            # GPU Neovim GUI with animations
  ];

  # ============================================================================
  # HELIX - Post-modern modal editor (Kakoune-inspired)
  # ============================================================================

  programs.helix = {
    enable = true;
    defaultEditor = false; # Neovim is default
    
    settings = {
      theme = "catppuccin_mocha";
      
      editor = {
        # Line numbers
        line-number = "relative";
        
        # Cursor
        cursorline = true;
        cursorcolumn = false;
        
        # Gutters
        gutters = ["diagnostics" "spacer" "line-numbers" "spacer" "diff"];
        
        # Auto pairs
        auto-pairs = true;
        auto-completion = true;
        auto-format = true;
        auto-save = true;
        
        # Idle timeout
        idle-timeout = 50;
        completion-timeout = 5;
        
        # Preview
        preview-completion-insert = true;
        completion-trigger-len = 1;
        
        # Scroll
        scroll-lines = 3;
        scrolloff = 8;
        
        # Shell
        shell = ["bash" "-c"];
        
        # Mouse
        mouse = true;
        middle-click-paste = true;
        
        # Bufferline
        bufferline = "multiple";
        
        # Color modes
        color-modes = true;
        
        # True color
        true-color = true;
        
        # Rulers
        rulers = [80 120];
        
        # Whitespace rendering
        whitespace = {
          render = {
            space = "none";
            tab = "all";
            nbsp = "all";
            newline = "none";
          };
          characters = {
            space = "·";
            nbsp = "⍽";
            tab = "→";
            newline = "⏎";
          };
        };
        
        # Indent guides
        indent-guides = {
          render = true;
          character = "▏";
          skip-levels = 1;
        };
        
        # Cursor shape
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        
        # File picker
        file-picker = {
          hidden = false;
          follow-symlinks = true;
          deduplicate-links = true;
          parents = true;
          ignore = true;
          git-ignore = true;
          git-global = true;
          git-exclude = true;
          max-depth = null;
        };
        
        # LSP
        lsp = {
          enable = true;
          display-messages = true;
          auto-signature-help = true;
          display-inlay-hints = true;
          display-signature-help-docs = true;
          snippets = true;
          goto-reference-include-declaration = true;
        };
        
        # Statusline
        statusline = {
          left = ["mode" "spinner" "file-name" "file-modification-indicator"];
          center = [];
          right = ["diagnostics" "selections" "register" "position" "file-encoding" "file-line-ending" "file-type"];
          separator = "│";
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };
        
        # Inline diagnostics
        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "error";
        };
        
        # Soft wrap
        soft-wrap = {
          enable = true;
          max-wrap = 25;
          max-indent-retain = 0;
          wrap-indicator = "↪ ";
        };
      };
      
      # Keys - vim-like
      keys = {
        normal = {
          # Leader key
          space = {
            f = {
              f = "file_picker";
              g = "global_search";
              b = "buffer_picker";
              s = "symbol_picker";
              S = "workspace_symbol_picker";
              d = "diagnostics_picker";
              D = "workspace_diagnostics_picker";
              r = "file_picker_in_current_directory";
            };
            w = {
              s = "hsplit";
              v = "vsplit";
              q = "wclose";
              w = "rotate_view";
              h = "jump_view_left";
              j = "jump_view_down";
              k = "jump_view_up";
              l = "jump_view_right";
            };
            b = {
              b = "buffer_picker";
              n = "goto_next_buffer";
              p = "goto_previous_buffer";
              d = "buffer_close";
              D = "buffer_close_others";
            };
            g = {
              g = "lazygit"; # Requires shell command
              d = "goto_definition";
              D = "goto_declaration";
              r = "goto_reference";
              i = "goto_implementation";
              t = "goto_type_definition";
            };
            c = {
              a = "code_action";
              r = "rename_symbol";
              f = "format_selections";
            };
            "/" = "global_search";
            "?" = "command_palette";
          };
          
          # Quick navigation
          "C-h" = "jump_view_left";
          "C-j" = "jump_view_down";
          "C-k" = "jump_view_up";
          "C-l" = "jump_view_right";
          
          # Center after jumps
          "C-d" = ["half_page_down" "align_view_center"];
          "C-u" = ["half_page_up" "align_view_center"];
          "n" = ["search_next" "align_view_center"];
          "N" = ["search_prev" "align_view_center"];
          
          # Escape
          "esc" = ["collapse_selection" "keep_primary_selection"];
          
          # Quick save
          "C-s" = ":w";
          
          # Quick quit
          "Z" = {
            "Z" = ":wq";
            "Q" = ":q!";
          };
        };
        
        insert = {
          "C-s" = ":w";
          "C-space" = "completion";
          "j" = { "k" = "normal_mode"; };
        };
        
        select = {
          "C-h" = "jump_view_left";
          "C-j" = "jump_view_down";
          "C-k" = "jump_view_up";
          "C-l" = "jump_view_right";
        };
      };
    };
    
    # Language configurations
    languages = {
      language-server = {
        nil = {
          command = "nil";
        };
        rust-analyzer = {
          command = "rust-analyzer";
          config = {
            checkOnSave.command = "clippy";
            cargo.allFeatures = true;
            procMacro.enable = true;
          };
        };
        typescript-language-server = {
          command = "typescript-language-server";
          args = ["--stdio"];
        };
        pyright = {
          command = "pyright-langserver";
          args = ["--stdio"];
        };
      };
      
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt";
        }
        {
          name = "rust";
          auto-format = true;
        }
        {
          name = "typescript";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = ["--parser" "typescript"];
          };
        }
        {
          name = "javascript";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = ["--parser" "javascript"];
          };
        }
        {
          name = "python";
          auto-format = true;
          formatter.command = "ruff";
          formatter.args = ["format" "-"];
        }
        {
          name = "go";
          auto-format = true;
        }
        {
          name = "lua";
          auto-format = true;
          formatter.command = "stylua";
          formatter.args = ["-"];
        }
        {
          name = "markdown";
          auto-format = true;
          soft-wrap.enable = true;
        }
      ];
    };
  };

  # ============================================================================
  # NEOVIDE - GPU Neovim GUI config
  # ============================================================================

  xdg.configFile."neovide/config.toml".text = ''
    # Neovide Configuration

    # Font
    [font]
    normal = ["JetBrainsMono Nerd Font"]
    size = 14.0

    # Frame
    frame = "none"
    title-hidden = true

    # Animations
    [animations]
    cursor-animation-length = 0.06
    scroll-animation-length = 0.15
    cursor-trail-size = 0.5
    cursor-vfx-mode = "railgun"
    cursor-vfx-opacity = 200
    cursor-vfx-particle-lifetime = 0.8
    cursor-vfx-particle-density = 10.0
    cursor-vfx-particle-speed = 15.0
    cursor-vfx-particle-phase = 1.5
    cursor-vfx-particle-curl = 1.0

    # Window
    [window]
    fullscreen = false
    maximized = false
    remember-window-size = true
    remember-window-position = true
    hide-mouse-when-typing = true
    
    # Performance
    no-idle = false
    vsync = true
    
    # Input
    [input]
    use-logo = false
    ime = true
  '';

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    hx = "helix";
    nv = "neovide";
    nvf = "neovide --frame none";
  };
}
