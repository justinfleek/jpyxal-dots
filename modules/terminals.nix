{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # ALTERNATIVE TERMINALS - Zellij, Wezterm, Rio
  # ============================================================================

  home.packages = with pkgs; [
    rio        # Rust terminal with WebGPU
  ];

  # ============================================================================
  # ZELLIJ - Modern terminal multiplexer
  # ============================================================================

  programs.zellij = {
    enable = true;
    enableBashIntegration = false; # Don't auto-attach, use manually
    
    settings = {
      theme = "catppuccin-mocha";
      default_layout = "compact";
      default_mode = "normal";
      pane_frames = false;
      simplified_ui = false;
      
      # Mouse support
      mouse_mode = true;
      scroll_buffer_size = 50000;
      
      # Copy behavior
      copy_on_select = true;
      copy_command = "wl-copy";
      
      # Session
      session_serialization = true;
      serialize_pane_viewport = true;
      
      # UI
      ui = {
        pane_frames = {
          rounded_corners = true;
          hide_session_name = false;
        };
      };
      
      # Keybindings - vim-style
      keybinds = {
        normal = {
          "bind \"Ctrl g\"" = { SwitchToMode = "locked"; };
          "bind \"Ctrl p\"" = { SwitchToMode = "pane"; };
          "bind \"Ctrl t\"" = { SwitchToMode = "tab"; };
          "bind \"Ctrl n\"" = { SwitchToMode = "resize"; };
          "bind \"Ctrl s\"" = { SwitchToMode = "scroll"; };
          "bind \"Ctrl o\"" = { SwitchToMode = "session"; };
          "bind \"Ctrl h\"" = { MoveFocus = "Left"; };
          "bind \"Ctrl j\"" = { MoveFocus = "Down"; };
          "bind \"Ctrl k\"" = { MoveFocus = "Up"; };
          "bind \"Ctrl l\"" = { MoveFocus = "Right"; };
        };
      };
    };
  };

  # Zellij layouts
  xdg.configFile."zellij/layouts/dev.kdl".text = ''
    layout {
      default_tab_template {
        pane size=1 borderless=true {
          plugin location="tab-bar"
        }
        children
        pane size=2 borderless=true {
          plugin location="status-bar"
        }
      }
      
      tab name="code" focus=true {
        pane split_direction="vertical" {
          pane size="70%" command="nvim"
          pane size="30%" split_direction="horizontal" {
            pane command="lazygit"
            pane
          }
        }
      }
      
      tab name="term" {
        pane
      }
      
      tab name="logs" {
        pane command="btop"
      }
    }
  '';

  xdg.configFile."zellij/layouts/ide.kdl".text = ''
    layout {
      default_tab_template {
        pane size=1 borderless=true {
          plugin location="tab-bar"
        }
        children
        pane size=2 borderless=true {
          plugin location="status-bar"
        }
      }
      
      tab name="editor" focus=true {
        pane split_direction="vertical" {
          pane size="25%" command="yazi"
          pane size="75%" command="nvim"
        }
      }
      
      tab name="terminal" {
        pane split_direction="horizontal" {
          pane size="70%"
          pane size="30%"
        }
      }
      
      tab name="git" {
        pane command="lazygit"
      }
    }
  '';

  # ============================================================================
  # WEZTERM - GPU-accelerated terminal with Lua config
  # ============================================================================

  programs.wezterm = {
    enable = true;
    
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()
      
      -- =======================================================================
      -- APPEARANCE
      -- =======================================================================
      
      -- Catppuccin Mocha
      config.color_scheme = 'Catppuccin Mocha'
      
      -- Font
      config.font = wezterm.font_with_fallback {
        { family = 'JetBrainsMono Nerd Font', weight = 'Medium' },
        { family = 'Symbols Nerd Font Mono', scale = 0.9 },
      }
      config.font_size = 13.0
      
      -- Window
      config.window_background_opacity = 0.92
      config.macos_window_background_blur = 20
      config.window_decorations = "RESIZE"
      config.window_padding = {
        left = 10,
        right = 10,
        top = 10,
        bottom = 10,
      }
      
      -- Tab bar
      config.enable_tab_bar = true
      config.use_fancy_tab_bar = false
      config.tab_bar_at_bottom = true
      config.hide_tab_bar_if_only_one_tab = true
      
      -- Cursor
      config.default_cursor_style = 'SteadyBar'
      config.cursor_blink_rate = 500
      config.cursor_blink_ease_in = 'Constant'
      config.cursor_blink_ease_out = 'Constant'
      
      -- =======================================================================
      -- PERFORMANCE
      -- =======================================================================
      
      config.front_end = "WebGpu"
      config.webgpu_power_preference = "HighPerformance"
      config.animation_fps = 60
      config.max_fps = 120
      
      -- =======================================================================
      -- KEYBINDINGS
      -- =======================================================================
      
      config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
      
      config.keys = {
        -- Split panes
        { key = '|', mods = 'LEADER|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
        { key = '-', mods = 'LEADER', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
        
        -- Navigate panes (vim-style)
        { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
        { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
        { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
        { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },
        
        -- Resize panes
        { key = 'H', mods = 'LEADER|SHIFT', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
        { key = 'J', mods = 'LEADER|SHIFT', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },
        { key = 'K', mods = 'LEADER|SHIFT', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
        { key = 'L', mods = 'LEADER|SHIFT', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
        
        -- Tabs
        { key = 'c', mods = 'LEADER', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
        { key = 'n', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(1) },
        { key = 'p', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(-1) },
        
        -- Close
        { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = true } },
        
        -- Zoom
        { key = 'z', mods = 'LEADER', action = wezterm.action.TogglePaneZoomState },
        
        -- Copy mode (vim-style)
        { key = '[', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },
      }
      
      -- Tab numbers
      for i = 1, 9 do
        table.insert(config.keys, {
          key = tostring(i),
          mods = 'LEADER',
          action = wezterm.action.ActivateTab(i - 1),
        })
      end
      
      -- =======================================================================
      -- MISC
      -- =======================================================================
      
      config.scrollback_lines = 50000
      config.enable_scroll_bar = false
      config.audible_bell = 'Disabled'
      config.check_for_updates = false
      
      return config
    '';
  };

  # ============================================================================
  # RIO - Rust terminal with WebGPU (config)
  # ============================================================================

  xdg.configFile."rio/config.toml".text = ''
    # Rio Terminal Configuration
    
    [renderer]
    performance = "High"
    backend = "Automatic"
    
    [fonts]
    family = "JetBrainsMono Nerd Font"
    size = 14
    
    [fonts.regular]
    family = "JetBrainsMono Nerd Font"
    style = "Regular"
    weight = 400
    
    [fonts.bold]
    family = "JetBrainsMono Nerd Font"
    style = "Bold"
    weight = 700
    
    [window]
    opacity = 0.92
    blur = true
    decorations = "Disabled"
    
    [cursor]
    shape = "beam"
    blinking = true
    blinking-interval = 500
    
    [scroll]
    multiplier = 3.0
    divider = 1.0
    
    # Catppuccin Mocha colors
    [colors]
    background = "#1E1E2E"
    foreground = "#CDD6F4"
    cursor = "#F5E0DC"
    selection-background = "#45475A"
    selection-foreground = "#CDD6F4"
    
    [colors.normal]
    black = "#45475A"
    red = "#F38BA8"
    green = "#A6E3A1"
    yellow = "#F9E2AF"
    blue = "#89B4FA"
    magenta = "#F5C2E7"
    cyan = "#94E2D5"
    white = "#BAC2DE"
    
    [colors.bright]
    black = "#585B70"
    red = "#F38BA8"
    green = "#A6E3A1"
    yellow = "#F9E2AF"
    blue = "#89B4FA"
    magenta = "#F5C2E7"
    cyan = "#94E2D5"
    white = "#A6ADC8"
    
    [keyboard]
    use-kitty-keyboard-protocol = true
    
    [developer]
    log-level = "OFF"
  '';

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    zj = "zellij";
    zja = "zellij attach";
    zjl = "zellij list-sessions";
    zjd = "zellij --layout dev";
    zji = "zellij --layout ide";
    wez = "wezterm";
  };
}
