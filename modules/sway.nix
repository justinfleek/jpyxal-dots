{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # SWAY - Alternative Wayland compositor (i3-compatible)
  # ============================================================================

  home.packages = with pkgs; [
    # Sway ecosystem
    swayfx               # Sway with eye candy
    swaylock-effects     # Lock screen with effects
    swayidle             # Idle management
    swaybg               # Wallpaper
    
    # Bar
    waybar               # Already in waybar.nix, shared
    
    # Utilities
    wl-clipboard
    wlr-randr
    kanshi               # Output management
    mako                 # Notifications (alternative to dunst)
    
    # Screenshot
    grim
    slurp
    swappy
  ];

  # ============================================================================
  # SWAY CONFIG
  # ============================================================================

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    
    config = rec {
      # Modifier key (Super/Meta)
      modifier = "Mod4";
      
      # Terminal
      terminal = "ghostty";
      
      # Menu
      menu = "rofi -show drun";
      
      # Startup
      startup = [
        { command = "swww-daemon"; }
        { command = "waybar"; }
        { command = "mako"; }
        { command = "wl-paste --watch cliphist store"; }
      ];
      
      # Input
      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          repeat_delay = "300";
          repeat_rate = "50";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          dwt = "enabled";
        };
      };
      
      # Output
      output = {
        "*" = {
          bg = "~/.config/wallpaper.jpg fill";
        };
      };
      
      # Appearance
      gaps = {
        inner = 8;
        outer = 4;
      };
      
      # Font
      fonts = {
        names = ["JetBrainsMono Nerd Font"];
        size = 10.0;
      };
      
      # Colors (Catppuccin Mocha)
      colors = {
        focused = {
          border = "#89b4fa";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#f5c2e7";
          childBorder = "#89b4fa";
        };
        focusedInactive = {
          border = "#45475a";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#45475a";
          childBorder = "#45475a";
        };
        unfocused = {
          border = "#313244";
          background = "#1e1e2e";
          text = "#a6adc8";
          indicator = "#313244";
          childBorder = "#313244";
        };
        urgent = {
          border = "#f38ba8";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#f38ba8";
          childBorder = "#f38ba8";
        };
      };
      
      # Window rules
      window = {
        border = 2;
        titlebar = false;
        commands = [
          { command = "floating enable"; criteria = { app_id = "pavucontrol"; }; }
          { command = "floating enable"; criteria = { app_id = "nm-connection-editor"; }; }
          { command = "floating enable"; criteria = { app_id = "blueman-manager"; }; }
          { command = "floating enable"; criteria = { title = "Picture-in-Picture"; }; }
        ];
      };
      
      # Keybindings
      keybindings = lib.mkOptionDefault {
        # Applications
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+e" = "exec thunar";
        "${modifier}+b" = "exec firefox";
        
        # Window management
        "${modifier}+q" = "kill";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+space" = "floating toggle";
        "${modifier}+Shift+space" = "focus mode_toggle";
        
        # Focus (vim-style)
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        
        # Move
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";
        
        # Split
        "${modifier}+v" = "splitv";
        "${modifier}+s" = "splith";
        
        # Layout
        "${modifier}+w" = "layout tabbed";
        "${modifier}+t" = "layout toggle split";
        
        # Resize mode
        "${modifier}+r" = "mode resize";
        
        # Workspaces
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";
        
        # Move to workspace
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";
        
        # Scratchpad
        "${modifier}+Shift+minus" = "move scratchpad";
        "${modifier}+minus" = "scratchpad show";
        
        # Screenshots
        "Print" = "exec grim - | wl-copy";
        "Shift+Print" = "exec grim -g \"$(slurp)\" - | wl-copy";
        "${modifier}+Print" = "exec grim -g \"$(slurp)\" - | swappy -f -";
        
        # Volume
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        
        # Brightness
        "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        
        # Lock
        "${modifier}+Escape" = "exec swaylock";
        
        # Reload
        "${modifier}+Shift+c" = "reload";
        
        # Exit
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'";
      };
      
      # Modes
      modes = {
        resize = {
          "h" = "resize shrink width 10 px";
          "j" = "resize grow height 10 px";
          "k" = "resize shrink height 10 px";
          "l" = "resize grow width 10 px";
          "Left" = "resize shrink width 10 px";
          "Down" = "resize grow height 10 px";
          "Up" = "resize shrink height 10 px";
          "Right" = "resize grow width 10 px";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };
      
      # Bar (using waybar instead of sway's default)
      bars = [];
    };
    
    # SwayFX extras
    extraConfig = ''
      # SwayFX effects
      corner_radius 8
      blur enable
      blur_xray disable
      blur_passes 3
      blur_radius 5
      shadows enable
      shadows_on_csd disable
      shadow_blur_radius 20
      shadow_color #00000044
      
      # Layer effects
      layer_effects "waybar" blur enable; shadows enable
      layer_effects "rofi" blur enable
      
      # Dim inactive
      default_dim_inactive 0.1
      dim_inactive_colors.unfocused #00000066
      
      # Titlebar
      titlebar_separator disable
      titlebar_border_thickness 0
    '';
  };

  # ============================================================================
  # SWAYLOCK CONFIG
  # ============================================================================

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    
    settings = {
      # Appearance
      color = "1e1e2e";
      image = "~/.config/wallpaper.jpg";
      
      # Effects
      effect-blur = "10x5";
      effect-vignette = "0.5:0.5";
      fade-in = 0.2;
      
      # Indicator
      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 7;
      
      # Colors (Catppuccin)
      inside-color = "1e1e2e";
      inside-clear-color = "1e1e2e";
      inside-ver-color = "1e1e2e";
      inside-wrong-color = "1e1e2e";
      
      key-hl-color = "89b4fa";
      bs-hl-color = "f38ba8";
      
      ring-color = "45475a";
      ring-clear-color = "f9e2af";
      ring-ver-color = "89b4fa";
      ring-wrong-color = "f38ba8";
      
      line-color = "00000000";
      line-clear-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      
      separator-color = "00000000";
      
      text-color = "cdd6f4";
      text-clear-color = "cdd6f4";
      text-ver-color = "cdd6f4";
      text-wrong-color = "cdd6f4";
      
      # Font
      font = "JetBrainsMono Nerd Font";
      font-size = 24;
      
      # Behavior
      ignore-empty-password = true;
      show-failed-attempts = true;
    };
  };

  # ============================================================================
  # MAKO (NOTIFICATION DAEMON FOR SWAY)
  # ============================================================================

  services.mako = {
    enable = true;
    
    # Appearance
    backgroundColor = "#1e1e2eee";
    textColor = "#cdd6f4";
    borderColor = "#89b4fa";
    borderRadius = 8;
    borderSize = 2;
    
    # Layout
    width = 350;
    height = 150;
    margin = "10";
    padding = "15";
    
    # Position
    anchor = "top-right";
    
    # Font
    font = "JetBrainsMono Nerd Font 11";
    
    # Behavior
    defaultTimeout = 5000;
    ignoreTimeout = false;
    
    # Icons
    icons = true;
    maxIconSize = 48;
    
    # Format
    format = "<b>%s</b>\\n%b";
    
    # Extra config for urgencies
    extraConfig = ''
      [urgency=low]
      border-color=#a6e3a1

      [urgency=normal]
      border-color=#89b4fa

      [urgency=high]
      border-color=#f38ba8
      default-timeout=0
    '';
  };

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    sway-reload = "swaymsg reload";
    sway-exit = "swaymsg exit";
  };
}
