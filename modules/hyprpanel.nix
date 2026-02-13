{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # HYPRPANEL - Modern panel for Hyprland
  # An alternative to Waybar with more modern aesthetics
  # ============================================================================

  # Note: HyprPanel is typically installed from source or AUR
  # This module provides the configuration and install script

  home.packages = with pkgs; [
    # Dependencies
    gjs
    gtk3
    gtk4
    libadwaita
    sassc
    
    # Optional dependencies
    networkmanagerapplet
    blueman
    brightnessctl
    playerctl
    
    # Python for some widgets
    (python312.withPackages (ps: with ps; [
      requests
      pillow
    ]))
  ];

  # ============================================================================
  # HYPRPANEL INSTALL SCRIPT
  # ============================================================================

  home.file.".local/bin/hyprpanel-install" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Install HyprPanel
      
      set -euo pipefail
      
      HYPRPANEL_DIR="$HOME/.local/share/hyprpanel"
      
      echo "=== Installing HyprPanel ==="
      echo ""
      
      if [ -d "$HYPRPANEL_DIR" ]; then
        echo "Updating existing installation..."
        cd "$HYPRPANEL_DIR"
        git pull
      else
        echo "Cloning HyprPanel..."
        git clone https://github.com/Jas-SinghFSU/HyprPanel.git "$HYPRPANEL_DIR"
        cd "$HYPRPANEL_DIR"
      fi
      
      # Install dependencies via npm
      echo "Installing dependencies..."
      npm install
      
      # Build
      echo "Building..."
      npm run build
      
      # Create symlink
      mkdir -p "$HOME/.local/bin"
      ln -sf "$HYPRPANEL_DIR/hyprpanel" "$HOME/.local/bin/hyprpanel"
      
      echo ""
      echo "=== Installation Complete ==="
      echo ""
      echo "Start with: hyprpanel"
      echo "Or add to Hyprland config:"
      echo "  exec-once = hyprpanel"
    '';
  };

  # ============================================================================
  # HYPRPANEL CONFIG
  # ============================================================================

  xdg.configFile."hyprpanel/config.json".text = builtins.toJSON {
    theme = {
      name = "catppuccin-mocha";
      bar = {
        background = "rgba(30, 30, 46, 0.85)";
        border = "rgba(137, 180, 250, 0.3)";
        borderRadius = 16;
        margin = 8;
        padding = 8;
      };
      colors = {
        text = "#cdd6f4";
        textSecondary = "#a6adc8";
        accent = "#89b4fa";
        warning = "#f9e2af";
        error = "#f38ba8";
        success = "#a6e3a1";
      };
    };
    
    bar = {
      position = "top";
      height = 40;
      
      left = [
        "workspaces"
        "windowTitle"
      ];
      
      center = [
        "clock"
      ];
      
      right = [
        "media"
        "systray"
        "network"
        "bluetooth"
        "volume"
        "battery"
        "notifications"
        "power"
      ];
    };
    
    modules = {
      workspaces = {
        count = 10;
        showEmpty = false;
        indicators = {
          active = {
            background = "#89b4fa";
            width = 24;
            borderRadius = 12;
          };
          occupied = {
            background = "rgba(137, 180, 250, 0.3)";
            width = 12;
            borderRadius = 6;
          };
          empty = {
            background = "rgba(69, 71, 90, 0.5)";
            width = 8;
            borderRadius = 4;
          };
        };
      };
      
      clock = {
        format = "%H:%M";
        formatAlt = "%A, %B %d";
        tooltip = true;
        calendar = true;
      };
      
      battery = {
        showPercentage = true;
        lowThreshold = 20;
        criticalThreshold = 10;
        icons = {
          charging = "󰂄";
          full = "󰁹";
          high = "󰂀";
          medium = "󰁾";
          low = "󰁻";
          critical = "󰂃";
        };
      };
      
      volume = {
        showPercentage = true;
        icons = {
          high = "󰕾";
          medium = "󰖀";
          low = "󰕿";
          muted = "󰝟";
        };
      };
      
      network = {
        icons = {
          wifi = "󰤨";
          ethernet = "󰈀";
          disconnected = "󰤭";
        };
      };
      
      bluetooth = {
        icons = {
          connected = "󰂯";
          disconnected = "󰂲";
        };
      };
      
      media = {
        showTitle = true;
        truncateLength = 30;
        icons = {
          playing = "󰐊";
          paused = "󰏤";
        };
      };
      
      notifications = {
        icons = {
          bell = "󰂚";
          dnd = "󰂛";
        };
      };
      
      power = {
        icon = "󰐥";
        menu = [
          { label = "Lock"; icon = "󰌾"; action = "swaylock"; }
          { label = "Suspend"; icon = "󰤄"; action = "systemctl suspend"; }
          { label = "Restart"; icon = "󰜉"; action = "systemctl reboot"; }
          { label = "Shutdown"; icon = "󰐥"; action = "systemctl poweroff"; }
        ];
      };
    };
    
    animations = {
      enable = true;
      duration = 200;
      curve = "ease-out";
    };
    
    blur = {
      enable = true;
      size = 10;
      passes = 3;
    };
  };

  # ============================================================================
  # ALTERNATIVE: SIMPLE WAYBAR CONFIG FOR HYPRPANEL-LIKE LOOK
  # ============================================================================

  # This creates a Waybar config that mimics HyprPanel aesthetics
  xdg.configFile."waybar/hyprpanel-style.css".text = ''
    /* HyprPanel-inspired Waybar Style */
    
    @define-color base #1e1e2e;
    @define-color surface0 #313244;
    @define-color surface1 #45475a;
    @define-color text #cdd6f4;
    @define-color subtext #a6adc8;
    @define-color blue #89b4fa;
    @define-color green #a6e3a1;
    @define-color yellow #f9e2af;
    @define-color red #f38ba8;
    @define-color pink #f5c2e7;
    
    * {
      font-family: "JetBrainsMono Nerd Font", "Material Design Icons";
      font-size: 13px;
      font-weight: 500;
    }
    
    window#waybar {
      background: transparent;
    }
    
    .modules-left,
    .modules-center,
    .modules-right {
      background: alpha(@base, 0.85);
      border-radius: 16px;
      margin: 8px 4px;
      padding: 4px 16px;
      border: 1px solid alpha(@blue, 0.2);
    }
    
    /* Workspaces - pill style */
    #workspaces {
      padding: 0 4px;
    }
    
    #workspaces button {
      padding: 0;
      margin: 4px 2px;
      min-width: 8px;
      min-height: 8px;
      border-radius: 50%;
      background: alpha(@surface1, 0.5);
      transition: all 200ms cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    #workspaces button.active {
      min-width: 24px;
      border-radius: 12px;
      background: @blue;
    }
    
    #workspaces button.occupied {
      background: alpha(@blue, 0.3);
    }
    
    #workspaces button label {
      font-size: 0;
    }
    
    /* Clock */
    #clock {
      color: @text;
      font-weight: 600;
    }
    
    /* Modules */
    #battery,
    #network,
    #bluetooth,
    #pulseaudio,
    #custom-media,
    #tray,
    #custom-power {
      padding: 0 12px;
      margin: 0 2px;
      color: @text;
    }
    
    #battery.charging {
      color: @green;
    }
    
    #battery.warning:not(.charging) {
      color: @yellow;
    }
    
    #battery.critical:not(.charging) {
      color: @red;
      animation: blink 1s infinite;
    }
    
    #network.disconnected {
      color: @subtext;
    }
    
    #bluetooth.off {
      color: @subtext;
    }
    
    #pulseaudio.muted {
      color: @subtext;
    }
    
    #custom-power {
      color: @red;
      padding-right: 8px;
    }
    
    @keyframes blink {
      50% { opacity: 0.5; }
    }
    
    /* Hover effects */
    #battery:hover,
    #network:hover,
    #bluetooth:hover,
    #pulseaudio:hover,
    #custom-power:hover {
      background: alpha(@text, 0.1);
      border-radius: 8px;
    }
    
    /* Tray */
    #tray > .passive {
      -gtk-icon-effect: dim;
    }
    
    #tray > .needs-attention {
      -gtk-icon-effect: highlight;
    }
  '';

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    hp = "hyprpanel";
    hp-install = "hyprpanel-install";
    hp-restart = "pkill hyprpanel; hyprpanel &";
  };
}
