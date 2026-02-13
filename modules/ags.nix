{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # AGS - Aylur's GTK Shell / Astal widgets
  # Fancy animated widgets in the style of Aylur's dotfiles
  # ============================================================================

  home.packages = with pkgs; [
    # AGS (Aylur's GTK Shell)
    ags
    
    # Fabric (Python GTK widgets)
    # fabric # If available in nixpkgs
    
    # Dependencies
    gjs                    # JavaScript runtime for GNOME
    gtk3
    gtk4
    gtk-layer-shell
    libadwaita
    
    # AGS dependencies
    sassc                  # Sass compiler
    inotify-tools          # File watching
    socat                  # Socket communication
    jaq                    # JSON processor (fast jq)
    
    # For Aylur-style effects
    swww                   # Animated wallpapers
    matugen                # Material You color generation
    
    # Fonts used in Aylur dots
    lexend
    material-design-icons
    material-symbols
  ];

  # ============================================================================
  # AGS CONFIG - Aylur-inspired bar and widgets
  # ============================================================================

  xdg.configFile."ags/config.js".text = ''
    // AGS Configuration - Aylur-inspired
    // Modern, animated, glassmorphism widgets

    const { App, Widget, Utils, Variable } = ags;
    const { Box, Button, Label, Icon, Revealer, Stack, CenterBox, Window } = Widget;
    const { exec, execAsync } = Utils;

    // =========================================================================
    // VARIABLES
    // =========================================================================

    const time = Variable("", {
      poll: [1000, 'date "+%H:%M"'],
    });

    const date = Variable("", {
      poll: [60000, 'date "+%A, %B %d"'],
    });

    const battery = Variable({}, {
      poll: [5000, "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100", out => ({
        percent: parseInt(out) || 100,
      })],
    });

    const volume = Variable(0, {
      poll: [1000, "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}'"],
    });

    const workspaces = Variable([], {
      poll: [500, "hyprctl workspaces -j", out => {
        try { return JSON.parse(out); }
        catch { return []; }
      }],
    });

    const activeWorkspace = Variable(1, {
      poll: [100, "hyprctl activeworkspace -j", out => {
        try { return JSON.parse(out).id; }
        catch { return 1; }
      }],
    });

    // =========================================================================
    // STYLES
    // =========================================================================

    const css = `
      * {
        font-family: "Lexend", "JetBrainsMono Nerd Font", sans-serif;
        font-size: 13px;
      }

      window {
        background: transparent;
      }

      .bar {
        background: alpha(#1e1e2e, 0.85);
        border-radius: 16px;
        margin: 8px;
        padding: 4px 16px;
        border: 1px solid alpha(#cdd6f4, 0.1);
      }

      .module {
        padding: 4px 12px;
        margin: 0 4px;
        border-radius: 12px;
        transition: all 200ms ease;
      }

      .module:hover {
        background: alpha(#cdd6f4, 0.1);
      }

      .workspaces button {
        min-width: 32px;
        min-height: 32px;
        border-radius: 50%;
        margin: 0 2px;
        padding: 0;
        background: alpha(#45475a, 0.5);
        transition: all 200ms ease;
      }

      .workspaces button.active {
        background: #89b4fa;
        min-width: 48px;
        border-radius: 16px;
      }

      .workspaces button.occupied {
        background: alpha(#89b4fa, 0.3);
      }

      .workspaces button label {
        color: #cdd6f4;
        font-weight: bold;
      }

      .workspaces button.active label {
        color: #1e1e2e;
      }

      .clock {
        font-size: 14px;
        font-weight: 600;
        color: #cdd6f4;
      }

      .date {
        font-size: 12px;
        color: #a6adc8;
      }

      .battery {
        color: #a6e3a1;
      }

      .battery.low {
        color: #f38ba8;
      }

      .battery.charging {
        color: #f9e2af;
      }

      .volume {
        color: #89b4fa;
      }

      .systray {
        padding: 0 8px;
      }

      .systray button {
        padding: 4px;
        margin: 0 2px;
      }

      .notification-popup {
        background: alpha(#1e1e2e, 0.95);
        border-radius: 16px;
        padding: 16px;
        margin: 8px;
        border: 1px solid alpha(#89b4fa, 0.3);
        box-shadow: 0 8px 32px alpha(#000000, 0.4);
      }

      .notification-popup .title {
        font-size: 14px;
        font-weight: 600;
        color: #cdd6f4;
      }

      .notification-popup .body {
        font-size: 12px;
        color: #a6adc8;
      }
    `;

    // =========================================================================
    // WIDGETS
    // =========================================================================

    const Workspaces = () => Box({
      className: "workspaces",
      children: workspaces.bind().transform(ws => {
        const occupied = ws.map(w => w.id);
        return Array.from({ length: 10 }, (_, i) => i + 1).map(id =>
          Button({
            className: activeWorkspace.bind().transform(active =>
              `workspace ${active === id ? 'active' : ''} ${occupied.includes(id) ? 'occupied' : ''}`
            ),
            onClicked: () => execAsync(`hyprctl dispatch workspace ${id}`),
            child: Label({ label: String(id) }),
          })
        );
      }),
    });

    const Clock = () => Box({
      className: "module clock-module",
      vertical: true,
      children: [
        Label({
          className: "clock",
          label: time.bind(),
        }),
        Label({
          className: "date",
          label: date.bind(),
        }),
      ],
    });

    const Battery = () => Box({
      className: "module",
      children: [
        Icon({
          icon: battery.bind().transform(b => {
            const p = b.percent || 100;
            if (p > 90) return "battery-level-100-symbolic";
            if (p > 60) return "battery-level-70-symbolic";
            if (p > 30) return "battery-level-40-symbolic";
            if (p > 10) return "battery-level-20-symbolic";
            return "battery-level-0-symbolic";
          }),
        }),
        Label({
          className: battery.bind().transform(b => 
            `battery ${(b.percent || 100) < 20 ? 'low' : ''}`
          ),
          label: battery.bind().transform(b => `${b.percent || 100}%`),
        }),
      ],
    });

    const Volume = () => Box({
      className: "module",
      children: [
        Icon({
          icon: volume.bind().transform(v => {
            if (v === 0) return "audio-volume-muted-symbolic";
            if (v < 33) return "audio-volume-low-symbolic";
            if (v < 66) return "audio-volume-medium-symbolic";
            return "audio-volume-high-symbolic";
          }),
        }),
        Label({
          className: "volume",
          label: volume.bind().transform(v => `${v}%`),
        }),
      ],
    });

    const SysTray = () => Widget.SystemTray({
      className: "systray",
      items: Widget.SystemTray.bind().transform(items =>
        items.map(item => Button({
          child: Icon({ icon: item.bind("icon") }),
          tooltipMarkup: item.bind("tooltip-markup"),
          onPrimaryClick: (_, event) => item.activate(event),
          onSecondaryClick: (_, event) => item.openMenu(event),
        }))
      ),
    });

    // =========================================================================
    // BAR
    // =========================================================================

    const Left = () => Box({
      hpack: "start",
      children: [
        Workspaces(),
      ],
    });

    const Center = () => Box({
      children: [
        Clock(),
      ],
    });

    const Right = () => Box({
      hpack: "end",
      children: [
        Volume(),
        Battery(),
        SysTray(),
      ],
    });

    const Bar = (monitor = 0) => Window({
      name: `bar-${monitor}`,
      monitor,
      anchor: ["top", "left", "right"],
      exclusivity: "exclusive",
      child: CenterBox({
        className: "bar",
        startWidget: Left(),
        centerWidget: Center(),
        endWidget: Right(),
      }),
    });

    // =========================================================================
    // APP
    // =========================================================================

    App.config({
      style: css,
      windows: [
        Bar(0),
        // Bar(1), // Uncomment for multi-monitor
      ],
    });

    export {};
  '';

  # ============================================================================
  # AGS SCSS (for those who prefer Sass)
  # ============================================================================

  xdg.configFile."ags/style.scss".text = ''
    // AGS Styles - Catppuccin Mocha
    
    $base: #1e1e2e;
    $surface0: #313244;
    $surface1: #45475a;
    $surface2: #585b70;
    $text: #cdd6f4;
    $subtext1: #bac2de;
    $subtext0: #a6adc8;
    $overlay0: #6c7086;
    
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
    
    * {
      font-family: "Lexend", "JetBrainsMono Nerd Font", sans-serif;
      font-size: 13px;
    }
    
    window {
      background: transparent;
    }
    
    .bar {
      background: transparentize($base, 0.15);
      border-radius: 16px;
      margin: 8px;
      padding: 4px 16px;
      border: 1px solid transparentize($text, 0.9);
      
      // Glassmorphism
      backdrop-filter: blur(20px);
    }
    
    .module {
      padding: 4px 12px;
      margin: 0 4px;
      border-radius: 12px;
      transition: all 200ms ease;
      
      &:hover {
        background: transparentize($text, 0.9);
      }
    }
    
    .workspaces {
      button {
        min-width: 32px;
        min-height: 32px;
        border-radius: 50%;
        margin: 0 2px;
        padding: 0;
        background: transparentize($surface1, 0.5);
        transition: all 200ms cubic-bezier(0.4, 0, 0.2, 1);
        
        &.active {
          background: $blue;
          min-width: 48px;
          border-radius: 16px;
          
          label {
            color: $base;
          }
        }
        
        &.occupied {
          background: transparentize($blue, 0.7);
        }
        
        label {
          color: $text;
          font-weight: bold;
        }
      }
    }
    
    .clock-module {
      .clock {
        font-size: 14px;
        font-weight: 600;
        color: $text;
      }
      
      .date {
        font-size: 11px;
        color: $subtext0;
      }
    }
    
    .battery {
      color: $green;
      
      &.low {
        color: $red;
        animation: pulse 1s infinite;
      }
      
      &.charging {
        color: $yellow;
      }
    }
    
    .volume {
      color: $blue;
    }
    
    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.5; }
    }
  '';

  # ============================================================================
  # MATUGEN - Material You color generation
  # ============================================================================

  xdg.configFile."matugen/config.toml".text = ''
    [config]
    reload_apps = true
    set_wallpaper = true
    
    [config.wallpaper]
    command = "swww"
    arguments = ["img", "--transition-type", "grow", "--transition-pos", "center"]
    
    [templates.hyprland]
    input_path = "~/.config/matugen/templates/hyprland.conf"
    output_path = "~/.config/hypr/colors.conf"
    
    [templates.ags]
    input_path = "~/.config/matugen/templates/ags.scss"
    output_path = "~/.config/ags/colors.scss"
    
    [templates.gtk]
    input_path = "~/.config/matugen/templates/gtk.css"
    output_path = "~/.config/gtk-3.0/colors.css"
  '';

  # ============================================================================
  # SHELL ALIASES & SCRIPTS
  # ============================================================================

  home.file.".local/bin/ags-start" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Start AGS with proper environment
      
      pkill ags 2>/dev/null
      sleep 0.2
      ags &
      
      echo "AGS started"
    '';
  };

  home.file.".local/bin/wallpaper-set" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Set wallpaper with swww and optionally generate Material You colors
      
      WALLPAPER="$1"
      
      if [ -z "$WALLPAPER" ]; then
        echo "Usage: wallpaper-set <image>"
        exit 1
      fi
      
      # Set wallpaper with transition
      swww img "$WALLPAPER" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 1 \
        --transition-fps 60
      
      # Generate Material You colors if matugen is available
      if command -v matugen &> /dev/null; then
        echo "Generating Material You colors..."
        matugen image "$WALLPAPER"
      fi
      
      echo "Wallpaper set: $WALLPAPER"
    '';
  };

  programs.bash.shellAliases = {
    ags-start = "ags-start";
    ags-reload = "ags quit && ags &";
    wall = "wallpaper-set";
  };
}
