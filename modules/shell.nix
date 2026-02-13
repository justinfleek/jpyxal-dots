{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # SHELL CONFIG - Bash + Starship + Atuin
  # Fast, beautiful, and feature-rich
  # ============================================================================

  programs.bash = {
    enable = true;
    enableCompletion = true;
    
    historyControl = [ "erasedups" "ignorespace" ];
    historyFileSize = 100000;
    historySize = 100000;
    historyIgnore = [ "ls" "cd" "exit" "clear" "bg" "fg" "history" ];
    
    shellOptions = [
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
      "checkjobs"
      "autocd"
      "cdspell"
      "dirspell"
      "cmdhist"
    ];

    shellAliases = {
      # === NAVIGATION ===
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "~" = "cd ~";
      
      # === LS (using eza) ===
      ls = "eza --icons --group-directories-first";
      ll = "eza -la --icons --group-directories-first";
      la = "eza -a --icons --group-directories-first";
      lt = "eza --tree --level=2 --icons";
      lta = "eza --tree --level=2 --icons -a";
      
      # === CAT (using bat) ===
      cat = "bat --style=plain";
      catp = "bat";
      
      # === GIT ===
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit";
      gcm = "git commit -m";
      gco = "git checkout";
      gd = "git diff";
      gds = "git diff --staged";
      gl = "git log --oneline --graph --decorate -10";
      gla = "git log --oneline --graph --decorate --all";
      gp = "git push";
      gpl = "git pull";
      gs = "git status -sb";
      gst = "git stash";
      gstp = "git stash pop";
      lg = "lazygit";
      
      # === DIRECTORIES ===
      md = "mkdir -p";
      rd = "rmdir";
      
      # === SAFETY ===
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
      
      # === GREP ===
      grep = "grep --color=auto";
      rg = "rg --smart-case";
      
      # === SYSTEM ===
      df = "df -h";
      du = "du -h";
      free = "free -h";
      
      # === PROCESS ===
      psg = "ps aux | grep -v grep | grep -i";
      
      # === NIX ===
      nrs = "sudo nixos-rebuild switch --flake .#";
      nrb = "sudo nixos-rebuild boot --flake .#";
      hms = "home-manager switch --flake .#";
      nfu = "nix flake update";
      nfc = "nix flake check";
      nfm = "nix flake metadata";
      nsp = "nix-shell -p";
      nrp = "nix run nixpkgs#";
      ngc = "nix-collect-garbage -d";
      nso = "nix store optimise";
      
      # === EDITORS ===
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      
      # === MISC ===
      c = "clear";
      q = "exit";
      please = "sudo";
      fuck = "sudo !!";
      weather = "curl wttr.in";
      pubip = "curl ifconfig.me";
      localip = "ip -4 addr show | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}'";
      
      # === OPENCODE ===
      oc = "opencode";
      
      # === FASTFETCH ===
      ff = "fastfetch";
      fetch = "fastfetch";
      
      # === TMUX ===
      t = "tmux";
      ta = "tmux attach -t";
      tl = "tmux list-sessions";
      tn = "tmux new -s";
      tk = "tmux kill-session -t";
      
      # === PRISM THEMES ===
      prism = "prism-setup";
      themes = "theme-switch";
      hme = "hypermodern-emacs-setup";
      
      # === CURSOR ===
      cursor-update = "cursor-install";
    };

    initExtra = ''
      # ==========================================================================
      # BASH CONFIG - Extra initialization
      # ==========================================================================

      # === BETTER COMPLETION ===
      bind 'set show-all-if-ambiguous on'
      bind 'set completion-ignore-case on'
      bind 'set menu-complete-display-prefix on'
      bind 'TAB:menu-complete'
      bind '"\e[Z":menu-complete-backward'

      # === VI MODE SETTINGS ===
      set -o vi
      bind -m vi-insert 'Control-l: clear-screen'
      bind -m vi-insert '"\C-a": beginning-of-line'
      bind -m vi-insert '"\C-e": end-of-line'
      bind -m vi-insert '"\C-w": backward-kill-word'
      
      # Show mode in prompt
      bind 'set show-mode-in-prompt on'
      bind 'set vi-ins-mode-string \1\e[6 q\2'
      bind 'set vi-cmd-mode-string \1\e[2 q\2'

      # === WELCOME MESSAGE ===
      if command -v fastfetch &> /dev/null; then
        fastfetch --config small
      fi

      # === FZF KEYBINDINGS ===
      # Ctrl+R - History search (handled by atuin)
      # Ctrl+T - File search
      # Alt+C  - Directory search

      # === USEFUL FUNCTIONS ===

      # Create directory and cd into it
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }

      # Extract any archive
      extract() {
        if [ -f "$1" ]; then
          case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.tar.xz)    tar xJf "$1"   ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7z x "$1"      ;;
            *)           echo "'$1' cannot be extracted" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }

      # Quick notes
      note() {
        local notes_dir="$HOME/documents/notes"
        mkdir -p "$notes_dir"
        if [ -z "$1" ]; then
          $EDITOR "$notes_dir/$(date +%Y-%m-%d).md"
        else
          $EDITOR "$notes_dir/$1.md"
        fi
      }

      # Fuzzy cd with fzf
      fcd() {
        local dir
        dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf --height 40% --reverse)
        if [ -n "$dir" ]; then
          cd "$dir"
        fi
      }

      # Fuzzy edit with fzf
      fe() {
        local file
        file=$(fd --type f --hidden --follow --exclude .git 2>/dev/null | fzf --height 40% --reverse --preview 'bat --color=always --style=numbers --line-range=:500 {}')
        if [ -n "$file" ]; then
          $EDITOR "$file"
        fi
      }

      # Kill process with fzf
      fkill() {
        local pid
        pid=$(ps -ef | sed 1d | fzf -m --height 40% --reverse | awk '{print $2}')
        if [ -n "$pid" ]; then
          echo "$pid" | xargs kill -''${1:-9}
        fi
      }

      # Git branch with fzf
      fbr() {
        local branch
        branch=$(git branch -a | fzf --height 40% --reverse | tr -d '[:space:]' | sed 's/remotes\/origin\///')
        if [ -n "$branch" ]; then
          git checkout "$branch"
        fi
      }

      # Quick serve directory
      serve() {
        local port="''${1:-8000}"
        echo "Serving on http://localhost:$port"
        python3 -m http.server "$port"
      }

      # Man pages with color
      man() {
        LESS_TERMCAP_mb=$'\e[1;32m' \
        LESS_TERMCAP_md=$'\e[1;32m' \
        LESS_TERMCAP_me=$'\e[0m' \
        LESS_TERMCAP_se=$'\e[0m' \
        LESS_TERMCAP_so=$'\e[01;33m' \
        LESS_TERMCAP_ue=$'\e[0m' \
        LESS_TERMCAP_us=$'\e[1;4;31m' \
        command man "$@"
      }

      # Countdown timer
      countdown() {
        local secs="''${1:-60}"
        while [ $secs -gt 0 ]; do
          printf "\r%02d:%02d" $((secs/60)) $((secs%60))
          sleep 1
          ((secs--))
        done
        printf "\rTime's up!\n"
        notify-send "Timer" "Countdown finished!"
      }

      # Quick calculator
      calc() {
        echo "scale=2; $*" | bc -l
      }

      # Nix develop with direnv auto-enable
      ndev() {
        if [ ! -f .envrc ]; then
          echo "use flake" > .envrc
        fi
        direnv allow
      }
    '';

    profileExtra = ''
      # Start Hyprland on tty1
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };

  # ============================================================================
  # STARSHIP - Cross-shell prompt
  # ============================================================================

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    
    settings = {
      format = lib.concatStrings [
        "[](mauve)"
        "$os"
        "$username"
        "[](bg:peach fg:mauve)"
        "$directory"
        "[](bg:yellow fg:peach)"
        "$git_branch"
        "$git_status"
        "[](bg:teal fg:yellow)"
        "$c"
        "$rust"
        "$golang"
        "$nodejs"
        "$python"
        "$nix_shell"
        "[](bg:blue fg:teal)"
        "$docker_context"
        "$conda"
        "[](bg:lavender fg:blue)"
        "$time"
        "[ ](fg:lavender)"
        "$line_break"
        "$character"
      ];

      palette = "catppuccin_mocha";

      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };

      os = {
        disabled = false;
        style = "bg:mauve fg:base";
        symbols = {
          NixOS = " ";
          Linux = " ";
          Macos = " ";
          Windows = " ";
        };
      };

      username = {
        show_always = true;
        style_user = "bg:mauve fg:base";
        style_root = "bg:mauve fg:red";
        format = "[ $user ]($style)";
      };

      directory = {
        style = "bg:peach fg:base";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = ".../";
        substitutions = {
          Documents = " ";
          Downloads = " ";
          Music = " ";
          Pictures = " ";
          projects = " ";
          ".config" = " ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:yellow fg:base";
        format = "[ $symbol $branch ]($style)";
      };

      git_status = {
        style = "bg:yellow fg:base";
        format = "[$all_status$ahead_behind ]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:teal fg:base";
        format = "[ $symbol ($version) ]($style)";
      };

      c = {
        symbol = " ";
        style = "bg:teal fg:base";
        format = "[ $symbol ($version) ]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:teal fg:base";
        format = "[ $symbol ($version) ]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:teal fg:base";
        format = "[ $symbol ($version) ]($style)";
      };

      python = {
        symbol = "";
        style = "bg:teal fg:base";
        format = "[ $symbol ($version) ]($style)";
      };

      nix_shell = {
        symbol = "";
        style = "bg:teal fg:base";
        format = "[ $symbol $state ]($style)";
      };

      docker_context = {
        symbol = "";
        style = "bg:blue fg:base";
        format = "[ $symbol $context ]($style)";
      };

      conda = {
        style = "bg:blue fg:base";
        format = "[ $symbol $environment ]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:lavender fg:base";
        format = "[  $time ]($style)";
      };

      line_break = {
        disabled = false;
      };

      character = {
        disabled = false;
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold mauve)";
      };

      cmd_duration = {
        min_time = 2000;
        format = "took [$duration](bold yellow)";
      };
    };
  };

  # ============================================================================
  # ATUIN - Magical shell history
  # ============================================================================

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    
    settings = {
      auto_sync = false;
      sync_frequency = "0";
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "session";
      style = "compact";
      inline_height = 20;
      show_preview = true;
      show_help = true;
      exit_mode = "return-original";
      history_filter = [
        "^ls$"
        "^cd$"
        "^exit$"
        "^clear$"
        "^pwd$"
      ];
      
      # Catppuccin colors
      colors = {
        normal = "#cdd6f4";
        selected = "#f5c2e7";
        hostname = "#89b4fa";
        directory = "#fab387";
        duration = "#a6e3a1";
        time = "#6c7086";
        command = "#cdd6f4";
      };
    };
  };
}
