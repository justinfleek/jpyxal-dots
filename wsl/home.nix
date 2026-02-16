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
  # JPYXAL DOTS — WSL2 EDITION
  # All the dev power, none of the Wayland drama
  # ============================================================================

  home = {
    username = "nixos"; # WSL default user
    homeDirectory = "/home/nixos";
    stateVersion = "24.11";

    sessionVariables = {
      FLAKE = "$HOME/.config/jpyxal-dots";
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "ghostty";

      FZF_DEFAULT_OPTS = lib.mkForce ''
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
        --border="rounded" --border-label="" --preview-window="border-rounded"
        --prompt="> " --marker=">" --pointer=">"
        --separator="─" --scrollbar="│"
      '';
    };

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
  # PACKAGES — CLI/Dev only, no Wayland/desktop stuff
  # ============================================================================

  home.packages = with pkgs; [
    # === CORE UTILS ===
    coreutils findutils gnugrep gnused gawk
    ripgrep fd sd jq yq tree file which
    htop btop procs dust duf ncdu

    # === DEVELOPMENT ===
    pkgs-bun.bun
    git gh lazygit delta difftastic

    # Languages & runtimes
    nodejs_22 deno rustup go

    # LSPs & formatters
    nil nixfmt
    nodePackages.typescript-language-server
    nodePackages.prettier
    lua-language-server stylua
    marksman taplo yaml-language-server

    # === CLI TOOLS ===
    eza bat zoxide fzf atuin
    glow silicon hyperfine tokei

    # === SYSTEM ===
    fastfetch cpufetch onefetch nitch

    # === FONTS ===
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.iosevka
    nerd-fonts.caskaydia-cove
    nerd-fonts.geist-mono
    inter lexend

    # === NETWORKING ===
    wget curl httpie aria2

    # === ARCHIVE ===
    zip unzip p7zip

    # === PASSWORDS ===
    pass gnupg
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
  };

  # ============================================================================
  # PROGRAMS
  # ============================================================================

  programs = {
    home-manager.enable = true;

    bat = {
      enable = true;
      config = {
        theme = "Catppuccin Mocha";
        style = "numbers,changes,header";
        italic-text = "always";
      };
    };

    eza = {
      enable = true;
      enableBashIntegration = true;
      icons = "auto";
      git = true;
      extraOptions = [ "--group-directories-first" "--header" ];
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [ "--cmd cd" ];
    };

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

    mpv = {
      enable = true;
      config = {
        profile = "gpu-hq";
        hwdec = "auto-safe";
        volume = 100;
        volume-max = 200;
      };
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          theme = {
            activeBorderColor = [ "#cba6f7" "bold" ];
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
        git.paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
      };
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
