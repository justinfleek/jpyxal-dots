{
  config,
  pkgs,
  pkgs-bun,
  lib,
  inputs,
  username,
  nix-colors,
  ...
}:

{
  # ============================================================================
  # JPYXAL DOTS
  # Riced to absolute perfection - vim joyer approved
  # ============================================================================

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";

    # Environment variables
    sessionVariables = {
      FLAKE = "$HOME/.config/jpyxal-dots";
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "ghostty";
      BROWSER = "firefox";

      # Wayland specific
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland,x11";

      FZF_DEFAULT_OPTS = lib.mkForce "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --border=rounded --preview-window=border-rounded --prompt=\"> \" --marker=\"> \" --pointer=\"> \" --separator=─ --scrollbar=│";
    };

    # Session path additions
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
    ];
  };

  # ============================================================================
  # CATPPUCCIN GLOBAL THEMING
  # ============================================================================


  # ============================================================================
  # PACKAGES
  # ============================================================================

  home.packages = with pkgs; [
    # === CORE UTILS ===
    coreutils
    findutils
    gnugrep
    gnused
    gawk
    ripgrep
    fd
    sd
    jq
    yq
    tree
    file
    which
    htop
    btop
    procs
    dust
    duf
    ncdu

    # === DEVELOPMENT ===
    pkgs-bun.bun # Bun 1.3.9+ for opencode
    git
    gh
    lazygit
    delta
    difftastic

    # Languages & runtimes
    nodejs_22
    deno
    # python312  # Unified Python env provided via python.nix
    rustup
    go

    # LSPs & formatters
    nil # Nix LSP
    nixfmt # Was nixfmt-rfc-style, now just nixfmt
    nodePackages.typescript-language-server
    nodePackages.prettier
    lua-language-server
    stylua
    marksman
    taplo
    yaml-language-server

    # === CLI TOOLS ===
    eza # Better ls
    bat # Better cat
    zoxide # Smart cd
    fzf # Fuzzy finder
    atuin # Shell history
    # tldr # Quick man pages - conflicts with tealdeer in dev.nix
    glow # Markdown viewer
    silicon # Code screenshots
    hyperfine # Benchmarking
    tokei # Code stats

    # === SYSTEM ===
    fastfetch
    cpufetch
    onefetch
    nitch

    # === MEDIA ===
    mpv
    imv
    swappy
    grim
    slurp
    wl-clipboard
    cliphist

    # === HYPRLAND ECOSYSTEM ===
    hyprpicker
    hyprshot
    wlsunset
    swww # Animated wallpapers

    # === FONTS ===
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.iosevka
    nerd-fonts.caskaydia-cove
    nerd-fonts.geist-mono
    inter
    lexend

    # === GTK/QT THEMING ===

    # === MISC ===
    obs-studio
    discord
    spotify
    obsidian
    zathura # PDF viewer

    # === NETWORKING ===
    wget
    curl
    httpie
    aria2

    # === ARCHIVE ===
    zip
    unzip
    p7zip

    # === PASSWORDS ===
    pass
    gnupg
    # pinentry-curses # conflicts with pinentry-gnome3 in security.nix
  ];

  # ============================================================================
  # FONTS
  # ============================================================================

  fonts.fontconfig.enable = true;

  # ============================================================================
  # XDG
  # ============================================================================

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      videos = "${config.home.homeDirectory}/videos";
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "application/pdf" = "org.pwmt.zathura.desktop";
        "image/*" = "imv.desktop";
        "video/*" = "mpv.desktop";
        "audio/*" = "mpv.desktop";
      };
    };
  };

  # ============================================================================
  # GTK THEMING
  # ============================================================================

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
    };
    font = {
      name = "Inter";
      size = 11;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # ============================================================================
  # QT THEMING
  # ============================================================================

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style = {
      name = "kvantum";
    };
  };

  # ============================================================================
  # CURSOR
  # ============================================================================

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    gtk.enable = true;
    x11.enable = true;
  };

  # ============================================================================
  # SERVICES
  # ============================================================================

  services = {
    # Clipboard manager
    cliphist.enable = true;

    # Blue light filter
    wlsunset = {
      enable = true;
      latitude = 40.7;
      longitude = -74.0;
      temperature = {
        day = 6500;
        night = 4000;
      };
    };

    # Network tray
    network-manager-applet.enable = true;

    # Bluetooth tray
    blueman-applet.enable = true;

    # GPG agent - configured in security.nix
  };

  # ============================================================================
  # PROGRAMS (simple ones configured inline)
  # ============================================================================

  programs = {
    home-manager.enable = true;

    # Bat (better cat)
    bat = {
      enable = true;
      config = {
        theme = "Catppuccin Mocha";
        style = "numbers,changes,header";
        italic-text = "always";
      };
    };

    # Eza (better ls)
    eza = {
      enable = true;
      enableBashIntegration = true;
      icons = "auto"; # Changed from boolean to string
      git = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    # Zoxide (smart cd)
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [ "--cmd cd" ];
    };

    # FZF
    fzf = {
      enable = true;
      enableBashIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    };

    btop = {
      enable = true;
      settings = {
        theme_background = false;
        vim_keys = true;
        rounded_corners = true;
        graph_symbol = "braille";
        shown_boxes = "cpu mem net proc";
      };
    };

    # Zathura PDF viewer - configured in research.nix

    # MPV
    mpv = {
      enable = true;
      config = {
        profile = "gpu-hq";
        vo = "gpu-next";
        hwdec = "auto-safe";
        gpu-context = "wayland";

        # UI
        osc = "no";
        border = "no";
        osd-bar = "no";
        osd-font = "Inter";
        osd-font-size = 30;

        # Subtitles
        sub-auto = "fuzzy";
        sub-font = "Inter";
        sub-font-size = 36;
        sub-color = "#FFFFFF";
        sub-border-color = "#000000";
        sub-border-size = 2;
        sub-shadow-offset = 1;
        sub-shadow-color = "#33000000";

        # Audio
        volume = 100;
        volume-max = 200;

        # Screenshots
        screenshot-format = "png";
        screenshot-high-bit-depth = "yes";
        screenshot-png-compression = 7;
        screenshot-directory = "~/pictures/screenshots";
      };
    };

    # Lazygit
    lazygit = {
      enable = true;
      settings = {
        gui = {
          theme = {
            activeBorderColor = [
              "#cba6f7"
              "bold"
            ];
            inactiveBorderColor = [ "#a6adc8" ];
            optionsTextColor = [ "#89b4fa" ];
            selectedLineBgColor = [ "#313244" ];
            cherryPickedCommitBgColor = [ "#45475a" ];
            cherryPickedCommitFgColor = [ "#cba6f7" ];
            unstagedChangesColor = [ "#f38ba8" ];
            defaultFgColor = [ "#cdd6f4" ];
            searchingActiveBorderColor = [ "#f9e2af" ];
          };
          nerdFontsVersion = "3";
          showFileTree = true;
          showRandomTip = false;
          showCommandLog = false;
        };
        git = {
          paging = {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          };
        };
      };
    };

    # Direnv
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };

  # ============================================================================
  # WALLPAPER (swww)
  # ============================================================================

  home.file.".local/share/wallpapers/.keep".text = "";

  # Wallpaper script
  home.file.".local/bin/wallpaper" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      WALLPAPER_DIR="$HOME/.local/share/wallpapers"

      if [ -z "$1" ]; then
        # Random wallpaper
        WALL=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)
      else
        WALL="$1"
      fi

      if [ -n "$WALL" ] && [ -f "$WALL" ]; then
        swww img "$WALL" \
          --transition-type grow \
          --transition-pos 0.9,0.1 \
          --transition-step 90 \
          --transition-fps 60
      fi
    '';
  };

  # Screenshot script
  home.file.".local/bin/screenshot" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      DIR="$HOME/pictures/screenshots"
      mkdir -p "$DIR"

      case "$1" in
        "area")
          grim -g "$(slurp)" - | swappy -f -
          ;;
        "window")
          hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | grim -g - - | swappy -f -
          ;;
        "full")
          grim - | swappy -f -
          ;;
        *)
          grim -g "$(slurp)" - | swappy -f -
          ;;
      esac
    '';
  };

  # Color picker script
  home.file.".local/bin/colorpicker" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      COLOR=$(hyprpicker -a)
      notify-send "Color Picked" "$COLOR copied to clipboard" -i color-select
    '';
  };

  # Power menu script
  home.file.".local/bin/powermenu" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      OPTIONS="Lock\nLogout\nSuspend\nReboot\nShutdown"

      CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Power" -theme-str 'window {width: 200px;}')

      case "$CHOICE" in
        "Lock") hyprlock ;;
        "Logout") hyprctl dispatch exit ;;
        "Suspend") systemctl suspend ;;
        "Reboot") systemctl reboot ;;
        "Shutdown") systemctl poweroff ;;
      esac
    '';
  };
}
