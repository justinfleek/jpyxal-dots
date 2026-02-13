{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # NIRI - Scrollable tiling Wayland compositor
  # A unique WM where workspaces scroll infinitely
  # ============================================================================

  home.packages = with pkgs; [
    niri                 # The compositor itself
    
    # Compatible tools
    waybar
    fuzzel               # Wayland-native launcher (works well with niri)
    swww                 # Animated wallpapers
    wl-clipboard
    grim
    slurp
    swappy
    mako                 # Notifications
    swaylock-effects     # Lock screen
  ];

  # ============================================================================
  # NIRI CONFIG
  # ============================================================================

  xdg.configFile."niri/config.kdl".text = ''
    // Niri Configuration
    // Scrollable tiling compositor
    
    // ==========================================================================
    // INPUT
    // ==========================================================================
    
    input {
      keyboard {
        xkb {
          layout "us"
        }
        repeat-delay 300
        repeat-rate 50
      }
      
      touchpad {
        tap
        natural-scroll
        accel-speed 0.2
        accel-profile "adaptive"
        scroll-method "two-finger"
      }
      
      mouse {
        accel-speed 0.0
        accel-profile "flat"
      }
      
      focus-follows-mouse
    }
    
    // ==========================================================================
    // OUTPUT
    // ==========================================================================
    
    output "eDP-1" {
      mode "1920x1080@60"
      scale 1.0
      transform "normal"
    }
    
    // ==========================================================================
    // LAYOUT
    // ==========================================================================
    
    layout {
      // Gaps
      gaps 8
      
      // Center focused column when possible
      center-focused-column "never"
      
      // Default column width
      default-column-width { proportion 0.5; }
      
      // Preset column widths (cycle through with Mod+R)
      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
        proportion 1.0
      }
      
      // Focus ring
      focus-ring {
        width 2
        active-color "#89b4fa"
        inactive-color "#45475a"
      }
      
      // Border (alternative to focus ring)
      // border {
      //   width 2
      //   active-color "#89b4fa"
      //   inactive-color "#45475a"
      // }
      
      // Struts (reserved screen space)
      struts {
        left 0
        right 0
        top 0
        bottom 0
      }
    }
    
    // ==========================================================================
    // SPAWN AT STARTUP
    // ==========================================================================
    
    spawn-at-startup "waybar"
    spawn-at-startup "swww-daemon"
    spawn-at-startup "mako"
    spawn-at-startup "wl-paste" "--watch" "cliphist" "store"
    
    // ==========================================================================
    // PREFER NO CLIENT-SIDE DECORATIONS
    // ==========================================================================
    
    prefer-no-csd
    
    // ==========================================================================
    // SCREENSHOTS
    // ==========================================================================
    
    screenshot-path "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png"
    
    // ==========================================================================
    // ANIMATIONS
    // ==========================================================================
    
    animations {
      // Slow down animations by this factor (1.0 = normal speed)
      // slowdown 1.0
      
      workspace-switch {
        spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
      }
      
      horizontal-view-movement {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
      }
      
      window-open {
        duration-ms 200
        curve "ease-out-expo"
      }
      
      window-close {
        duration-ms 150
        curve "ease-out-quad"
      }
      
      config-notification-open-close {
        spring damping-ratio=0.6 stiffness=1000 epsilon=0.001
      }
    }
    
    // ==========================================================================
    // WINDOW RULES
    // ==========================================================================
    
    window-rule {
      match app-id="pavucontrol"
      open-floating true
    }
    
    window-rule {
      match app-id="nm-connection-editor"
      open-floating true
    }
    
    window-rule {
      match app-id="blueman-manager"
      open-floating true
    }
    
    window-rule {
      match title="Picture-in-Picture"
      open-floating true
    }
    
    // Firefox PiP
    window-rule {
      match app-id="firefox" title="Picture-in-Picture"
      open-floating true
      default-floating-position x=10 y=10 relative-to="bottom-right"
    }
    
    // ==========================================================================
    // KEYBINDINGS
    // ==========================================================================
    
    binds {
      // Mod key = Super/Meta/Win
      
      // == APPLICATIONS ==
      
      Mod+Return { spawn "ghostty"; }
      Mod+D { spawn "fuzzel"; }
      Mod+E { spawn "thunar"; }
      Mod+B { spawn "firefox"; }
      
      // == WINDOW MANAGEMENT ==
      
      Mod+Q { close-window; }
      
      // Focus (vim-style)
      Mod+H { focus-column-left; }
      Mod+J { focus-window-down; }
      Mod+K { focus-window-up; }
      Mod+L { focus-column-right; }
      
      // Arrow keys
      Mod+Left { focus-column-left; }
      Mod+Down { focus-window-down; }
      Mod+Up { focus-window-up; }
      Mod+Right { focus-column-right; }
      
      // Move windows
      Mod+Shift+H { move-column-left; }
      Mod+Shift+J { move-window-down; }
      Mod+Shift+K { move-window-up; }
      Mod+Shift+L { move-column-right; }
      
      Mod+Shift+Left { move-column-left; }
      Mod+Shift+Down { move-window-down; }
      Mod+Shift+Up { move-window-up; }
      Mod+Shift+Right { move-column-right; }
      
      // First/last column
      Mod+Home { focus-column-first; }
      Mod+End { focus-column-last; }
      Mod+Shift+Home { move-column-to-first; }
      Mod+Shift+End { move-column-to-last; }
      
      // == COLUMN MANAGEMENT ==
      
      // Consume/expel windows from column
      Mod+BracketLeft { consume-window-into-column; }
      Mod+BracketRight { expel-window-from-column; }
      
      // Column width
      Mod+R { switch-preset-column-width; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+C { center-column; }
      
      // Resize
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }
      
      // == WORKSPACES ==
      
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }
      
      Mod+Shift+1 { move-column-to-workspace 1; }
      Mod+Shift+2 { move-column-to-workspace 2; }
      Mod+Shift+3 { move-column-to-workspace 3; }
      Mod+Shift+4 { move-column-to-workspace 4; }
      Mod+Shift+5 { move-column-to-workspace 5; }
      Mod+Shift+6 { move-column-to-workspace 6; }
      Mod+Shift+7 { move-column-to-workspace 7; }
      Mod+Shift+8 { move-column-to-workspace 8; }
      Mod+Shift+9 { move-column-to-workspace 9; }
      
      // Workspace navigation
      Mod+Tab { focus-workspace-down; }
      Mod+Shift+Tab { focus-workspace-up; }
      Mod+U { focus-workspace-down; }
      Mod+I { focus-workspace-up; }
      
      // Move to monitor
      Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
      Mod+Shift+Ctrl+L { move-column-to-monitor-right; }
      
      // == SCREENSHOTS ==
      
      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }
      
      // == MEDIA KEYS ==
      
      XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
      XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
      XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
      XF86AudioMicMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
      
      XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "set" "+5%"; }
      XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }
      
      // == SYSTEM ==
      
      Mod+Escape { spawn "swaylock"; }
      Mod+Shift+E { quit; }
      
      // Power menu
      Mod+Shift+P { spawn "bash" "-c" "echo -e 'Lock\nSuspend\nReboot\nShutdown' | fuzzel --dmenu | xargs -I{} bash -c 'case {} in Lock) swaylock;; Suspend) systemctl suspend;; Reboot) systemctl reboot;; Shutdown) systemctl poweroff;; esac'"; }
    }
  '';

  # ============================================================================
  # FUZZEL - Wayland launcher (works great with niri)
  # ============================================================================

  programs.fuzzel = {
    enable = true;
    
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=12";
        dpi-aware = "auto";
        prompt = "❯ ";
        icon-theme = "Papirus-Dark";
        icons-enabled = true;
        terminal = "ghostty -e";
        layer = "overlay";
        width = 50;
        horizontal-pad = 20;
        vertical-pad = 10;
        inner-pad = 5;
      };
      
      colors = {
        # Catppuccin Mocha
        background = "1e1e2eee";
        text = "cdd6f4ff";
        match = "89b4faff";
        selection = "45475aff";
        selection-text = "cdd6f4ff";
        selection-match = "89b4faff";
        border = "89b4faff";
      };
      
      border = {
        width = 2;
        radius = 8;
      };
    };
  };

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # Niri doesn't have a "reload" like sway, you restart it
    niri-restart = "niri msg action quit";
  };
}
