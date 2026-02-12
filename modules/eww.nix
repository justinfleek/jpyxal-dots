{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # EWW - Elkowwar's Wacky Widgets
  # Desktop widgets and custom bars
  # ============================================================================

  home.packages = with pkgs; [
    eww
    jq
    socat
    playerctl
    pamixer
  ];

  # ============================================================================
  # EWW CONFIG
  # ============================================================================

  xdg.configFile = {
    # Main EWW config
    "eww/eww.yuck".text = ''
      ; ==========================================================================
      ; EWW WIDGETS - Catppuccin Mocha
      ; ==========================================================================

      ; === VARIABLES ===
      
      (defpoll time :interval "1s"
        `date +"%H:%M"`)
      
      (defpoll date :interval "60s"
        `date +"%a, %b %d"`)
      
      (defpoll volume :interval "0.5s"
        `pamixer --get-volume`)
      
      (defpoll volume_icon :interval "0.5s"
        `pamixer --get-mute && echo "󰖁" || ([ $(pamixer --get-volume) -gt 50 ] && echo "󰕾" || echo "󰖀")`)
      
      (defpoll brightness :interval "0.5s"
        `brightnessctl -m | cut -d',' -f4 | tr -d '%'`)
      
      (defpoll battery :interval "10s"
        `cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100`)
      
      (defpoll battery_status :interval "10s"
        `cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "AC"`)
      
      (defpoll cpu :interval "2s"
        `top -bn1 | grep "Cpu(s)" | awk '{print int($2)}'`)
      
      (defpoll memory :interval "2s"
        `free -m | grep Mem | awk '{print int($3/$2 * 100)}'`)
      
      (defpoll disk :interval "60s"
        `df -h / | awk 'NR==2 {print int($5)}'`)
      
      (defpoll music_title :interval "1s"
        `playerctl metadata title 2>/dev/null || echo "No music"`)
      
      (defpoll music_artist :interval "1s"
        `playerctl metadata artist 2>/dev/null || echo ""`)
      
      (defpoll music_status :interval "1s"
        `playerctl status 2>/dev/null || echo "Stopped"`)
      
      (defvar show_system false)
      (defvar show_music false)
      
      ; === WIDGETS ===
      
      ; Clock widget
      (defwidget clock []
        (box :class "clock-box" :orientation "v" :space-evenly false
          (label :class "clock-time" :text time)
          (label :class "clock-date" :text date)))
      
      ; System stats widget
      (defwidget system []
        (box :class "system-box" :orientation "v" :space-evenly false
          (box :class "stat" :orientation "h" :space-evenly false
            (label :class "stat-icon" :text "󰍛")
            (label :class "stat-label" :text "CPU")
            (progress :class "stat-bar" :value cpu :orientation "h")
            (label :class "stat-value" :text "${cpu}%"))
          (box :class "stat" :orientation "h" :space-evenly false
            (label :class "stat-icon" :text "󰘚")
            (label :class "stat-label" :text "RAM")
            (progress :class "stat-bar" :value memory :orientation "h")
            (label :class "stat-value" :text "${memory}%"))
          (box :class "stat" :orientation "h" :space-evenly false
            (label :class "stat-icon" :text "󰋊")
            (label :class "stat-label" :text "DISK")
            (progress :class "stat-bar" :value disk :orientation "h")
            (label :class "stat-value" :text "${disk}%"))))
      
      ; Battery widget
      (defwidget battery []
        (box :class "battery-box" :orientation "h" :space-evenly false
          (label :class "battery-icon" 
            :text {battery_status == "Charging" ? "󰂄" :
                   battery < 10 ? "󰂃" :
                   battery < 20 ? "󰁺" :
                   battery < 30 ? "󰁻" :
                   battery < 40 ? "󰁼" :
                   battery < 50 ? "󰁽" :
                   battery < 60 ? "󰁾" :
                   battery < 70 ? "󰁿" :
                   battery < 80 ? "󰂀" :
                   battery < 90 ? "󰂁" : "󰂂"})
          (label :class "battery-value" :text "${battery}%")))
      
      ; Volume widget
      (defwidget volume []
        (eventbox :onscroll "[ {} = up ] && pamixer -i 2 || pamixer -d 2"
          (box :class "volume-box" :orientation "h" :space-evenly false
            (label :class "volume-icon" :text volume_icon)
            (scale :class "volume-slider" :value volume :min 0 :max 100
              :onchange "pamixer --set-volume {}"))))
      
      ; Brightness widget
      (defwidget brightness []
        (box :class "brightness-box" :orientation "h" :space-evenly false
          (label :class "brightness-icon" :text "󰃟")
          (scale :class "brightness-slider" :value brightness :min 0 :max 100
            :onchange "brightnessctl set {}%")))
      
      ; Music widget
      (defwidget music []
        (box :class "music-box" :orientation "h" :space-evenly false
          (box :class "music-info" :orientation "v" :space-evenly false
            (label :class "music-title" :text music_title :limit-width 30)
            (label :class "music-artist" :text music_artist :limit-width 30))
          (box :class "music-controls" :orientation "h" :space-evenly true
            (button :class "music-btn" :onclick "playerctl previous" "󰒮")
            (button :class "music-btn" :onclick "playerctl play-pause" 
              {music_status == "Playing" ? "󰏤" : "󰐊"})
            (button :class "music-btn" :onclick "playerctl next" "󰒭"))))
      
      ; Quick toggles
      (defwidget toggles []
        (box :class "toggles-box" :orientation "h" :space-evenly true
          (button :class "toggle-btn" :onclick "~/.local/bin/powermenu" "󰐥")
          (button :class "toggle-btn" :onclick "hyprlock" "󰍁")
          (button :class "toggle-btn" :onclick "hyprctl dispatch exit" "󰗼")))
      
      ; === WINDOWS ===
      
      ; Dashboard window
      (defwindow dashboard
        :monitor 0
        :geometry (geometry :x "10px" :y "60px" :width "300px" :height "400px" :anchor "top left")
        :stacking "overlay"
        :exclusive false
        :focusable false
        (box :class "dashboard" :orientation "v" :space-evenly false
          (clock)
          (system)
          (battery)
          (volume)
          (brightness)
          (music)
          (toggles)))
      
      ; System monitor corner widget
      (defwindow system-corner
        :monitor 0
        :geometry (geometry :x "10px" :y "10px" :width "200px" :height "150px" :anchor "bottom left")
        :stacking "bottom"
        :exclusive false
        :focusable false
        (box :class "corner-widget" :orientation "v" :space-evenly false
          (system)))
      
      ; Music corner widget  
      (defwindow music-corner
        :monitor 0
        :geometry (geometry :x "10px" :y "10px" :width "300px" :height "100px" :anchor "bottom right")
        :stacking "bottom"
        :exclusive false
        :focusable false
        (box :class "corner-widget" :orientation "v" :space-evenly false
          (music)))
      
      ; Calendar popup
      (defwindow calendar-popup
        :monitor 0
        :geometry (geometry :x "0" :y "50px" :width "300px" :height "200px" :anchor "top center")
        :stacking "overlay"
        :exclusive false
        :focusable false
        (box :class "calendar-popup"
          (calendar :class "cal" :day 1 :month 1 :year 2024)))
    '';

    # EWW styling
    "eww/eww.scss".text = ''
      // ==========================================================================
      // EWW STYLES - Catppuccin Mocha
      // ==========================================================================

      // Colors
      $rosewater: #f5e0dc;
      $flamingo: #f2cdcd;
      $pink: #f5c2e7;
      $mauve: #cba6f7;
      $red: #f38ba8;
      $maroon: #eba0ac;
      $peach: #fab387;
      $yellow: #f9e2af;
      $green: #a6e3a1;
      $teal: #94e2d5;
      $sky: #89dceb;
      $sapphire: #74c7ec;
      $blue: #89b4fa;
      $lavender: #b4befe;
      $text: #cdd6f4;
      $subtext1: #bac2de;
      $subtext0: #a6adc8;
      $overlay2: #9399b2;
      $overlay1: #7f849c;
      $overlay0: #6c7086;
      $surface2: #585b70;
      $surface1: #45475a;
      $surface0: #313244;
      $base: #1e1e2e;
      $mantle: #181825;
      $crust: #11111b;

      // Global
      * {
        all: unset;
        font-family: "JetBrainsMono Nerd Font", "Inter", sans-serif;
        font-size: 14px;
      }

      // Dashboard
      .dashboard {
        background: rgba($base, 0.9);
        border: 2px solid $surface0;
        border-radius: 16px;
        padding: 16px;
      }

      // Corner widgets
      .corner-widget {
        background: rgba($base, 0.85);
        border: 1px solid $surface0;
        border-radius: 12px;
        padding: 12px;
      }

      // Clock
      .clock-box {
        padding: 16px;
        margin-bottom: 12px;
      }

      .clock-time {
        font-size: 48px;
        font-weight: bold;
        color: $text;
      }

      .clock-date {
        font-size: 16px;
        color: $subtext0;
      }

      // System stats
      .system-box {
        background: $surface0;
        border-radius: 12px;
        padding: 12px;
        margin-bottom: 12px;
      }

      .stat {
        margin: 4px 0;
      }

      .stat-icon {
        font-size: 16px;
        color: $mauve;
        margin-right: 8px;
        min-width: 20px;
      }

      .stat-label {
        color: $subtext0;
        font-size: 12px;
        min-width: 40px;
      }

      .stat-bar {
        min-width: 100px;
        min-height: 8px;
        border-radius: 4px;
        background: $surface1;
        margin: 0 8px;

        progress {
          background: linear-gradient(90deg, $blue, $mauve);
          border-radius: 4px;
        }
      }

      .stat-value {
        color: $text;
        font-size: 12px;
        min-width: 40px;
        text-align: right;
      }

      // Battery
      .battery-box {
        background: $surface0;
        border-radius: 12px;
        padding: 12px;
        margin-bottom: 12px;
      }

      .battery-icon {
        font-size: 24px;
        color: $green;
        margin-right: 8px;
      }

      .battery-value {
        color: $text;
        font-size: 16px;
      }

      // Volume
      .volume-box, .brightness-box {
        background: $surface0;
        border-radius: 12px;
        padding: 12px;
        margin-bottom: 12px;
      }

      .volume-icon, .brightness-icon {
        font-size: 20px;
        color: $blue;
        margin-right: 12px;
      }

      .volume-slider, .brightness-slider {
        min-width: 150px;
        min-height: 8px;

        trough {
          background: $surface1;
          border-radius: 4px;
          min-height: 8px;
        }

        slider {
          background: $mauve;
          border-radius: 50%;
          min-width: 16px;
          min-height: 16px;
          margin: -4px 0;
        }

        highlight {
          background: linear-gradient(90deg, $blue, $mauve);
          border-radius: 4px;
        }
      }

      // Music
      .music-box {
        background: $surface0;
        border-radius: 12px;
        padding: 12px;
        margin-bottom: 12px;
      }

      .music-info {
        flex-grow: 1;
      }

      .music-title {
        color: $text;
        font-weight: bold;
      }

      .music-artist {
        color: $subtext0;
        font-size: 12px;
      }

      .music-controls {
        min-width: 100px;
      }

      .music-btn {
        font-size: 20px;
        color: $mauve;
        padding: 4px 8px;
        border-radius: 8px;
        transition: all 0.2s;

        &:hover {
          background: $surface1;
          color: $pink;
        }
      }

      // Toggles
      .toggles-box {
        padding: 8px 0;
      }

      .toggle-btn {
        font-size: 24px;
        color: $text;
        padding: 12px;
        border-radius: 12px;
        background: $surface0;
        transition: all 0.2s;

        &:hover {
          background: $surface1;
          color: $mauve;
        }

        &:nth-child(1):hover { color: $red; }
        &:nth-child(2):hover { color: $yellow; }
        &:nth-child(3):hover { color: $peach; }
      }

      // Calendar
      .calendar-popup {
        background: rgba($base, 0.95);
        border: 2px solid $surface0;
        border-radius: 16px;
        padding: 16px;
      }

      .cal {
        color: $text;

        &:selected {
          background: $mauve;
          color: $base;
        }
      }
    '';
  };

  # ============================================================================
  # EWW SCRIPTS
  # ============================================================================

  home.file.".local/bin/eww-toggle" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      WIDGET="''${1:-dashboard}"
      
      if eww active-windows | grep -q "$WIDGET"; then
        eww close "$WIDGET"
      else
        eww open "$WIDGET"
      fi
    '';
  };

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    widgets = "eww-toggle dashboard";
    eww-dash = "eww-toggle dashboard";
    eww-music = "eww-toggle music-corner";
    eww-sys = "eww-toggle system-corner";
  };
}
