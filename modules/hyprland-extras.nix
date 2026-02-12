{ config, pkgs, lib, inputs, ... }:

{
  # ============================================================================
  # HYPRLAND EXTRAS - Additional Hyprland ecosystem tools
  # ============================================================================

  home.packages = with pkgs; [
    # === WALLPAPER ===
    swww                     # Animated wallpapers
    mpvpaper                 # Video wallpapers
    waypaper                 # Wallpaper GUI
    
    # === SCREENSHOTS ===
    hyprshot                 # Hyprland screenshot
    satty                    # Screenshot annotation
    
    # === SCREEN RECORDING ===
    wf-recorder              # Wayland screen recorder
    wl-screenrec             # Fast screen recorder
    
    # === UTILITIES ===
    hyprpicker               # Color picker
    hyprcursor               # Cursor theming
    
    # === CLIPBOARD ===
    cliphist                 # Clipboard history
    wl-clipboard             # Wayland clipboard
    
    # === WIDGETS ===
    eww                      # Elkowwar widgets (see eww.nix)
    
    # === LAUNCHERS ===
    anyrun                   # Modern launcher
    walker                   # Application launcher
    
    # === MISC ===
    wlr-randr                # Output management
    wdisplays                # Display config GUI
    brightnessctl            # Brightness control
    
    # === EFFECTS ===
    wlsunset                 # Blue light filter
    
    # === SCREEN SHARING ===
    xdg-desktop-portal-hyprland
    xwaylandvideobridge      # For Discord screen share
  ];

  # ============================================================================
  # ANYRUN CONFIG
  # ============================================================================

  xdg.configFile."anyrun/config.ron".text = ''
    Config(
      x: Fraction(0.5),
      y: Absolute(200),
      width: Absolute(600),
      height: Absolute(0),
      hide_icons: false,
      ignore_exclusive_zones: false,
      layer: Overlay,
      hide_plugin_info: false,
      close_on_click: true,
      show_results_immediately: true,
      max_entries: Some(8),
      plugins: [
        "libapplications.so",
        "libshell.so",
        "libsymbols.so",
        "librink.so",
        "libtranslate.so",
        "libdictionary.so",
      ],
    )
  '';

  xdg.configFile."anyrun/style.css".text = ''
    /* Anyrun - Catppuccin Mocha */

    * {
      font-family: "Inter", "JetBrainsMono Nerd Font", sans-serif;
      font-size: 14px;
    }

    #window {
      background: transparent;
    }

    box#main {
      background: rgba(30, 30, 46, 0.95);
      border: 2px solid #cba6f7;
      border-radius: 16px;
      padding: 8px;
    }

    entry#entry {
      background: #313244;
      border: none;
      border-radius: 12px;
      padding: 12px 16px;
      margin: 8px;
      color: #cdd6f4;
      caret-color: #cba6f7;
      font-size: 18px;
    }

    entry#entry:focus {
      outline: none;
      box-shadow: 0 0 0 2px #cba6f7;
    }

    entry#entry placeholder {
      color: #6c7086;
    }

    list#main {
      background: transparent;
    }

    row#entry {
      background: transparent;
      padding: 8px 12px;
      margin: 2px 8px;
      border-radius: 10px;
    }

    row#entry:selected {
      background: #45475a;
    }

    row#entry:hover {
      background: #313244;
    }

    box#match {
      background: transparent;
    }

    label#match-title {
      color: #cdd6f4;
      font-weight: 500;
    }

    label#match-desc {
      color: #6c7086;
      font-size: 12px;
    }

    image#match-icon {
      margin-right: 12px;
    }

    box#plugin {
      background: #313244;
      border-radius: 8px;
      padding: 4px 8px;
      margin: 4px 8px;
    }

    label#plugin {
      color: #89b4fa;
      font-size: 11px;
    }
  '';

  # ============================================================================
  # WALKER CONFIG
  # ============================================================================

  xdg.configFile."walker/config.toml".text = ''
    # Walker config

    [ui]
    fullscreen = false
    width = 600
    anchor = "center"
    margin_top = 200
    
    [ui.theme]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    accent = "#cba6f7"
    border = "#45475a"
    border_radius = 16
    font = "Inter"
    font_size = 14

    [search]
    delay = 0
    force_keyboard_focus = true
    
    [applications]
    enable = true
    show_generic = true
    show_sub_commands = true
    
    [commands]
    enable = true
    
    [websearch]
    enable = true
    
    [calculator]
    enable = true
    
    [clipboard]
    enable = true
    max_entries = 20
  '';

  # ============================================================================
  # MPVPAPER CONFIG (Video Wallpapers)
  # ============================================================================

  home.file.".local/bin/video-wallpaper" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      VIDEO="$1"
      
      if [ -z "$VIDEO" ]; then
        echo "Usage: video-wallpaper <video-file>"
        exit 1
      fi
      
      # Kill existing mpvpaper
      pkill -x mpvpaper
      
      # Start mpvpaper on all monitors
      for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do
        mpvpaper -o "no-audio loop" "$monitor" "$VIDEO" &
      done
      
      echo "Video wallpaper set: $VIDEO"
    '';
  };

  # ============================================================================
  # WF-RECORDER HELPER
  # ============================================================================

  home.file.".local/bin/record-screen" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      OUTPUT_DIR="$HOME/videos/recordings"
      mkdir -p "$OUTPUT_DIR"
      TIMESTAMP=$(date +%Y%m%d-%H%M%S)
      OUTPUT="$OUTPUT_DIR/recording-$TIMESTAMP.mp4"
      
      case "$1" in
        "area")
          GEOMETRY=$(slurp)
          if [ -n "$GEOMETRY" ]; then
            notify-send "Recording" "Recording area... Press Ctrl+C to stop"
            wf-recorder -g "$GEOMETRY" -f "$OUTPUT"
          fi
          ;;
        "screen")
          notify-send "Recording" "Recording screen... Press Ctrl+C to stop"
          wf-recorder -f "$OUTPUT"
          ;;
        "stop")
          pkill -INT wf-recorder
          notify-send "Recording" "Recording saved!"
          ;;
        *)
          echo "Usage: record-screen [area|screen|stop]"
          ;;
      esac
    '';
  };

  # ============================================================================
  # SWWW HELPERS
  # ============================================================================

  home.file.".local/bin/wallpaper-slideshow" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      WALLPAPER_DIR="''${1:-$HOME/.local/share/wallpapers}"
      INTERVAL="''${2:-300}"  # 5 minutes default
      
      while true; do
        WALL=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" \) | shuf -n 1)
        
        if [ -n "$WALL" ]; then
          swww img "$WALL" \
            --transition-type random \
            --transition-step 90 \
            --transition-fps 60
        fi
        
        sleep "$INTERVAL"
      done
    '';
  };

  # ============================================================================
  # ADDITIONAL HYPRLAND BINDS
  # ============================================================================

  # Add these to your Hyprland config or extend hyprland.nix
  # 
  # bind = $mod, R, exec, anyrun
  # bind = $mod SHIFT, R, exec, walker
  # bind = $mod, F9, exec, record-screen area
  # bind = $mod, F10, exec, record-screen screen
  # bind = $mod, F11, exec, record-screen stop
  # bind = $mod SHIFT, W, exec, wallpaper-slideshow

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # Wallpaper
    wall = "~/.local/bin/wallpaper";
    walls = "wallpaper-slideshow";
    vwall = "video-wallpaper";
    
    # Recording
    rec = "record-screen area";
    recf = "record-screen screen";
    recs = "record-screen stop";
    
    # Color
    pick = "hyprpicker -a";
    
    # Screenshot
    shot = "hyprshot -m region";
    shotw = "hyprshot -m window";
    shotf = "hyprshot -m output";
  };
}
