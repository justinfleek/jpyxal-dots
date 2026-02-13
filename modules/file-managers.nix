{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # FILE MANAGERS - LF, Ranger, Superfile, Yazi enhancements
  # ============================================================================

  home.packages = with pkgs; [
    ranger             # Classic terminal file manager
    superfile          # Modern TUI file manager
    nnn                # Minimal file manager
    mc                 # Midnight Commander
    
    # File manager dependencies
    ueberzugpp         # Image preview
    ffmpegthumbnailer  # Video thumbnails
    poppler_utils      # PDF preview
    imagemagick        # Image manipulation
    chafa              # Image to ASCII
    exiftool           # Metadata
    atool              # Archive preview
    highlight          # Code highlighting
    mediainfo          # Media info
    odt2txt            # ODT preview
    xlsx2csv           # Excel preview
    pandoc             # Document conversion
  ];

  # ============================================================================
  # LF - Terminal file manager (fast, minimal)
  # ============================================================================

  programs.lf = {
    enable = true;
    
    settings = {
      preview = true;
      hidden = true;
      drawbox = true;
      icons = true;
      ignorecase = true;
      ratios = "1:2:3";
      tabstop = 4;
      scrolloff = 8;
      shell = "bash";
      shellopts = "-eu";
      ifs = "\n";
      info = "size:time";
      sortby = "natural";
      reverse = false;
      dirfirst = true;
      globsearch = true;
      wrapscan = true;
      wrapscroll = true;
      number = true;
      relativenumber = true;
      dircounts = true;
      period = 1;
    };
    
    keybindings = {
      # Vim-like
      j = "down";
      k = "up";
      h = "updir";
      l = "open";
      
      # Navigation
      gg = "top";
      G = "bottom";
      "<c-d>" = "half-down";
      "<c-u>" = "half-up";
      "<c-f>" = "page-down";
      "<c-b>" = "page-up";
      
      # Selection
      "<space>" = "toggle";
      v = "invert";
      u = "unselect";
      
      # Actions
      "<enter>" = "open";
      o = "open";
      e = "$nvim \"$f\"";
      i = "$less \"$f\"";
      w = "$$SHELL";
      
      # File operations
      y = "copy";
      d = "cut";
      p = "paste";
      c = "clear";
      D = "delete";
      
      # Renaming
      r = "rename";
      R = "bulk-rename";
      A = "rename"; # At end
      I = "push A<c-a>"; # At beginning
      
      # New items
      a = "push %mkdir<space>";
      "%" = "push %touch<space>";
      
      # Search
      "/" = "search";
      "?" = "search-back";
      n = "search-next";
      N = "search-prev";
      
      # Filter
      f = "filter";
      F = "setfilter";
      
      # Bookmarks
      m = "mark-save";
      "'" = "mark-load";
      "\"" = "mark-remove";
      
      # Shell commands
      "!" = "shell";
      "$" = "shell";
      "&" = "shell-async";
      
      # Sorting
      sn = ":set sortby natural; set info size:time";
      ss = ":set sortby size; set info size:time";
      st = ":set sortby time; set info size:time";
      se = ":set sortby ext; set info size:time";
      
      # Toggle hidden
      zh = "set hidden!";
      zr = "set reverse!";
      zn = "set info none";
      zs = "set info size";
      zt = "set info time";
      za = "set info size:time";
      
      # Quick directories
      gh = "cd ~";
      gd = "cd ~/Downloads";
      gD = "cd ~/Documents";
      gc = "cd ~/.config";
      gw = "cd ~/workspace";
      gp = "cd ~/Pictures";
      gv = "cd ~/Videos";
      gt = "cd /tmp";
      
      # Archive
      x = "extract";
      z = "zip";
      t = "tar";
      
      # Preview
      "<c-p>" = "set preview!";
    };
    
    commands = {
      # Open with editor
      open = ''
        ''${{
          case $(file --mime-type -Lb "$f") in
            text/*|application/json|application/javascript)
              $EDITOR "$f";;
            *)
              xdg-open "$f" &>/dev/null &
          esac
        }}
      '';
      
      # Extract archives
      extract = ''
        ''${{
          set -f
          case "$f" in
            *.tar.bz2) tar xjf "$f" ;;
            *.tar.gz) tar xzf "$f" ;;
            *.tar.xz) tar xJf "$f" ;;
            *.bz2) bunzip2 "$f" ;;
            *.rar) unrar x "$f" ;;
            *.gz) gunzip "$f" ;;
            *.tar) tar xf "$f" ;;
            *.tbz2) tar xjf "$f" ;;
            *.tgz) tar xzf "$f" ;;
            *.zip) unzip "$f" ;;
            *.Z) uncompress "$f" ;;
            *.7z) 7z x "$f" ;;
          esac
        }}
      '';
      
      # Create zip
      zip = ''%zip -r "$f.zip" "$f"'';
      
      # Create tar.gz
      tar = ''%tar cvzf "$f.tar.gz" "$f"'';
      
      # Delete with confirmation
      delete = ''
        ''${{
          set -f
          printf "Delete $fx? [y/N] "
          read ans
          [ "$ans" = "y" ] && rm -rf $fx
        }}
      '';
      
      # Bulk rename
      bulk-rename = ''
        ''${{
          old="$(mktemp)"
          new="$(mktemp)"
          if [ -n "$fs" ]; then
            fs="$(basename -a $fs)"
          else
            fs="$(ls)"
          fi
          printf '%s\n' "$fs" > "$old"
          printf '%s\n' "$fs" > "$new"
          $EDITOR "$new"
          [ "$(wc -l < "$new")" -ne "$(wc -l < "$old")" ] && exit
          paste "$old" "$new" | while IFS=$(printf "\t") read -r src dst; do
            if [ "$src" = "$dst" ] || [ -e "$dst" ]; then
              continue
            fi
            mv -- "$src" "$dst"
          done
          rm -- "$old" "$new"
          lf -remote "send $id unselect"
        }}
      '';
      
      # FZF navigation
      fzf_jump = ''
        ''${{
          res="$(find . -maxdepth 3 | fzf --reverse --header='Jump to location')"
          if [ -d "$res" ]; then
            cmd="cd"
          else
            cmd="select"
          fi
          lf -remote "send $id $cmd \"$res\""
        }}
      '';
      
      # Git status colors
      git_status = ''
        ''${{
          [ -d .git ] && git status --short
        }}
      '';
    };
    
    previewer = {
      source = pkgs.writeShellScript "lf-preview" ''
        #!/usr/bin/env bash
        
        case "$1" in
          *.tar*) tar tf "$1";;
          *.zip) unzip -l "$1";;
          *.rar) unrar l "$1";;
          *.7z) 7z l "$1";;
          *.pdf) pdftotext "$1" -;;
          *.jpg|*.jpeg|*.png|*.gif|*.bmp|*.webp)
            chafa -f sixel -s "$2x$3" "$1" 2>/dev/null || file "$1";;
          *.mp4|*.mkv|*.webm|*.avi|*.mov)
            mediainfo "$1";;
          *.mp3|*.flac|*.wav|*.ogg)
            mediainfo "$1";;
          *.md) glow -s dark "$1";;
          *.json) jq -C . "$1";;
          *) bat --style=numbers --color=always --line-range=:200 "$1" 2>/dev/null || cat "$1";;
        esac
      '';
    };
  };

  # LF icons
  xdg.configFile."lf/icons".text = ''
    # vim:ft=conf

    # File types
    di  
    fi  
    tw 󰉋
    ow  
    ln  
    or  
    ex  

    # Archives
    *.7z    
    *.ace   
    *.alz   
    *.arc   
    *.arj   
    *.bz    
    *.bz2   
    *.cab   
    *.cpio  
    *.deb   
    *.dwm   
    *.dz    
    *.ear   
    *.esd   
    *.gz    
    *.jar   
    *.lha   
    *.lrz   
    *.lz    
    *.lz4   
    *.lzh   
    *.lzma  
    *.lzo   
    *.rar   
    *.rpm   
    *.rz    
    *.sar   
    *.swm   
    *.t7z   
    *.tar   
    *.taz   
    *.tbz   
    *.tbz2  
    *.tgz   
    *.tlz   
    *.txz   
    *.tz    
    *.tzo   
    *.tzst  
    *.war   
    *.wim   
    *.xz    
    *.z     
    *.zip   
    *.zoo   
    *.zst   

    # Documents
    *.djvu  
    *.doc   
    *.docx  
    *.dot   
    *.dvi   
    *.epub  
    *.mobi  
    *.odp   
    *.ods   
    *.odt   
    *.pdf   
    *.ppt   
    *.pptx  
    *.ps    
    *.rtf   
    *.xls   
    *.xlsx  

    # Programming
    *.c     
    *.cc    
    *.clj   
    *.coffee 
    *.cpp   
    *.css   
    *.d     
    *.dart  
    *.erl   
    *.ex    
    *.exs   
    *.fs    
    *.go    
    *.h     
    *.hh    
    *.hpp   
    *.hs    
    *.html  
    *.java  
    *.jl    
    *.js    
    *.json  
    *.kt    
    *.lua   
    *.md    
    *.nix   
    *.php   
    *.pl    
    *.py    
    *.r     
    *.rb    
    *.rs    
    *.scala 
    *.scss  
    *.sh    
    *.sql   
    *.swift 
    *.toml  
    *.ts    
    *.tsx   
    *.vim   
    *.vue   
    *.xml   
    *.yaml  
    *.yml   
    *.zig   

    # Images
    *.bmp   
    *.gif   
    *.ico   
    *.jpeg  
    *.jpg   
    *.png   
    *.svg   
    *.webp  

    # Video
    *.avi   
    *.flv   
    *.m4v   
    *.mkv   
    *.mov   
    *.mp4   
    *.mpeg  
    *.mpg   
    *.webm  
    *.wmv   

    # Audio
    *.aac   
    *.flac  
    *.m4a   
    *.mp3   
    *.ogg   
    *.opus  
    *.wav   
    *.wma   

    # Config
    *.cfg   
    *.conf  
    *.config 
    *.ini   

    # Git
    *.git   
    .gitattributes 
    .gitignore 
    .gitmodules 

    # Lock files
    *.lock  

    # Special files
    Dockerfile 
    Makefile 
    LICENSE 
  '';

  # ============================================================================
  # YAZI - Fast terminal file manager (enhancements)
  # ============================================================================

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    
    settings = {
      manager = {
        ratio = [1 3 4];
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "size";
        show_hidden = true;
        show_symlink = true;
      };
      
      preview = {
        tab_size = 2;
        max_width = 1000;
        max_height = 1000;
        cache_dir = "";
        image_filter = "triangle";
        image_quality = 75;
        sixel_fraction = 15;
        ueberzug_scale = 1;
        ueberzug_offset = [0 0 0 0];
      };
      
      opener = {
        edit = [
          { run = ''nvim "$@"''; block = true; for = "unix"; }
        ];
        open = [
          { run = ''xdg-open "$@"''; desc = "Open"; for = "linux"; }
        ];
        reveal = [
          { run = ''xdg-open "$(dirname "$0")"''; desc = "Reveal"; for = "linux"; }
        ];
        extract = [
          { run = ''unar "$1"''; desc = "Extract"; for = "linux"; }
        ];
        play = [
          { run = ''mpv "$@"''; orphan = true; for = "linux"; }
        ];
      };
      
      open = {
        rules = [
          { name = "*/"; use = ["edit" "open" "reveal"]; }
          { mime = "text/*"; use = ["edit" "reveal"]; }
          { mime = "image/*"; use = ["open" "reveal"]; }
          { mime = "video/*"; use = ["play" "reveal"]; }
          { mime = "audio/*"; use = ["play" "reveal"]; }
          { mime = "application/json"; use = ["edit" "reveal"]; }
          { mime = "*/javascript"; use = ["edit" "reveal"]; }
          { mime = "application/zip"; use = ["extract" "reveal"]; }
          { mime = "application/x-tar"; use = ["extract" "reveal"]; }
          { mime = "application/x-bzip2"; use = ["extract" "reveal"]; }
          { mime = "application/x-7z-compressed"; use = ["extract" "reveal"]; }
          { mime = "application/x-rar"; use = ["extract" "reveal"]; }
          { mime = "application/gzip"; use = ["extract" "reveal"]; }
          { mime = "*"; use = ["open" "reveal"]; }
        ];
      };
    };

    keymap = {
      manager.keymap = [
        # Navigation (vim-style)
        { on = ["k"]; run = "arrow -1"; desc = "Move cursor up"; }
        { on = ["j"]; run = "arrow 1"; desc = "Move cursor down"; }
        { on = ["K"]; run = "arrow -5"; desc = "Move cursor up 5 lines"; }
        { on = ["J"]; run = "arrow 5"; desc = "Move cursor down 5 lines"; }
        { on = ["h"]; run = "leave"; desc = "Go to parent directory"; }
        { on = ["l"]; run = "enter"; desc = "Enter directory"; }
        { on = ["<C-u>"]; run = "arrow -50%"; desc = "Half page up"; }
        { on = ["<C-d>"]; run = "arrow 50%"; desc = "Half page down"; }
        { on = ["g" "g"]; run = "arrow -99999999"; desc = "Go to top"; }
        { on = ["G"]; run = "arrow 99999999"; desc = "Go to bottom"; }
        
        # Selection
        { on = ["<Space>"]; run = ["select --state=none" "arrow 1"]; desc = "Toggle selection"; }
        { on = ["v"]; run = "visual_mode"; desc = "Enter visual mode"; }
        { on = ["V"]; run = "visual_mode --unset"; desc = "Exit visual mode"; }
        { on = ["<C-a>"]; run = "select_all --state=true"; desc = "Select all"; }
        { on = ["<C-r>"]; run = "select_all --state=none"; desc = "Invert selection"; }
        
        # Operations
        { on = ["<Enter>"]; run = "open"; desc = "Open"; }
        { on = ["o"]; run = "open"; desc = "Open"; }
        { on = ["O"]; run = "open --interactive"; desc = "Open with..."; }
        { on = ["y"]; run = "yank"; desc = "Copy"; }
        { on = ["x"]; run = "yank --cut"; desc = "Cut"; }
        { on = ["p"]; run = "paste"; desc = "Paste"; }
        { on = ["P"]; run = "paste --force"; desc = "Paste (overwrite)"; }
        { on = ["d"]; run = "remove"; desc = "Delete"; }
        { on = ["D"]; run = "remove --permanently"; desc = "Delete permanently"; }
        { on = ["a"]; run = "create"; desc = "Create file/directory"; }
        { on = ["r"]; run = "rename"; desc = "Rename"; }
        { on = [";"]; run = "shell"; desc = "Shell command"; }
        { on = [":"]; run = "shell --block"; desc = "Shell command (block)"; }
        { on = ["."]; run = "hidden toggle"; desc = "Toggle hidden"; }
        
        # Search
        { on = ["/"]; run = "search fd"; desc = "Search files (fd)"; }
        { on = ["?"]; run = "search rg"; desc = "Search content (rg)"; }
        { on = ["n"]; run = "search_next"; desc = "Next match"; }
        { on = ["N"]; run = "search_prev"; desc = "Previous match"; }
        
        # Filter
        { on = ["f"]; run = "filter --smart"; desc = "Filter"; }
        
        # Tabs
        { on = ["t"]; run = "tab_create --current"; desc = "New tab"; }
        { on = ["1"]; run = "tab_switch 0"; desc = "Tab 1"; }
        { on = ["2"]; run = "tab_switch 1"; desc = "Tab 2"; }
        { on = ["3"]; run = "tab_switch 2"; desc = "Tab 3"; }
        { on = ["4"]; run = "tab_switch 3"; desc = "Tab 4"; }
        { on = ["["]; run = "tab_switch -1 --relative"; desc = "Previous tab"; }
        { on = ["]"]; run = "tab_switch 1 --relative"; desc = "Next tab"; }
        { on = ["{"]; run = "tab_swap -1"; desc = "Swap with previous tab"; }
        { on = ["}"]; run = "tab_swap 1"; desc = "Swap with next tab"; }
        
        # Quick directories
        { on = ["g" "h"]; run = "cd ~"; desc = "Home"; }
        { on = ["g" "c"]; run = "cd ~/.config"; desc = "Config"; }
        { on = ["g" "d"]; run = "cd ~/Downloads"; desc = "Downloads"; }
        { on = ["g" "D"]; run = "cd ~/Documents"; desc = "Documents"; }
        { on = ["g" "w"]; run = "cd ~/workspace"; desc = "Workspace"; }
        { on = ["g" "t"]; run = "cd /tmp"; desc = "Temp"; }
        
        # Copy paths
        { on = ["c" "c"]; run = "copy path"; desc = "Copy path"; }
        { on = ["c" "d"]; run = "copy dirname"; desc = "Copy dirname"; }
        { on = ["c" "f"]; run = "copy filename"; desc = "Copy filename"; }
        { on = ["c" "n"]; run = "copy name_without_ext"; desc = "Copy name (no ext)"; }
        
        # Find
        { on = ["F"]; run = "plugin fzf"; desc = "Find with fzf"; }
        
        # Tasks
        { on = ["w"]; run = "tasks_show"; desc = "Show tasks"; }
        
        # Help
        { on = ["~"]; run = "help"; desc = "Help"; }
        { on = ["<Esc>"]; run = "escape"; desc = "Escape"; }
        { on = ["q"]; run = "quit"; desc = "Quit"; }
        { on = ["Q"]; run = "quit --no-cwd-file"; desc = "Quit without cwd"; }
        { on = ["<C-q>"]; run = "close"; desc = "Close tab"; }
        { on = ["<C-z>"]; run = "suspend"; desc = "Suspend"; }
      ];
    };
    
    theme = {
      manager = {
        cwd = { fg = "#94e2d5"; };
        hovered = { fg = "#1e1e2e"; bg = "#89b4fa"; };
        preview_hovered = { underline = true; };
        find_keyword = { fg = "#f9e2af"; italic = true; };
        find_position = { fg = "#f5c2e7"; bg = "reset"; italic = true; };
        marker_selected = { fg = "#a6e3a1"; bg = "#a6e3a1"; };
        marker_copied = { fg = "#f9e2af"; bg = "#f9e2af"; };
        marker_cut = { fg = "#f38ba8"; bg = "#f38ba8"; };
        tab_active = { fg = "#1e1e2e"; bg = "#cdd6f4"; };
        tab_inactive = { fg = "#cdd6f4"; bg = "#45475a"; };
        tab_width = 1;
        border_symbol = "│";
        border_style = { fg = "#585b70"; };
      };
      
      status = {
        separator_open = "";
        separator_close = "";
        separator_style = { fg = "#45475a"; bg = "#45475a"; };
        mode_normal = { fg = "#1e1e2e"; bg = "#89b4fa"; bold = true; };
        mode_select = { fg = "#1e1e2e"; bg = "#a6e3a1"; bold = true; };
        mode_unset = { fg = "#1e1e2e"; bg = "#f5c2e7"; bold = true; };
        progress_label = { fg = "#cdd6f4"; bold = true; };
        progress_normal = { fg = "#89b4fa"; bg = "#45475a"; };
        progress_error = { fg = "#f38ba8"; bg = "#45475a"; };
        permissions_t = { fg = "#89b4fa"; };
        permissions_r = { fg = "#f9e2af"; };
        permissions_w = { fg = "#f38ba8"; };
        permissions_x = { fg = "#a6e3a1"; };
        permissions_s = { fg = "#585b70"; };
      };
      
      input = {
        border = { fg = "#89b4fa"; };
        title = { };
        value = { };
        selected = { reversed = true; };
      };
      
      select = {
        border = { fg = "#89b4fa"; };
        active = { fg = "#f5c2e7"; };
        inactive = { };
      };
      
      tasks = {
        border = { fg = "#89b4fa"; };
        title = { };
        hovered = { underline = true; };
      };
      
      which = {
        mask = { bg = "#313244"; };
        cand = { fg = "#94e2d5"; };
        rest = { fg = "#9399b2"; };
        desc = { fg = "#f5c2e7"; };
        separator = "  ";
        separator_style = { fg = "#585b70"; };
      };
      
      help = {
        on = { fg = "#f5c2e7"; };
        exec = { fg = "#94e2d5"; };
        desc = { fg = "#9399b2"; };
        hovered = { bg = "#585b70"; bold = true; };
        footer = { fg = "#45475a"; bg = "#cdd6f4"; };
      };
      
      filetype = {
        rules = [
          { mime = "image/*"; fg = "#94e2d5"; }
          { mime = "video/*"; fg = "#f9e2af"; }
          { mime = "audio/*"; fg = "#f9e2af"; }
          { mime = "application/zip"; fg = "#f5c2e7"; }
          { mime = "application/gzip"; fg = "#f5c2e7"; }
          { mime = "application/x-tar"; fg = "#f5c2e7"; }
          { mime = "application/x-bzip2"; fg = "#f5c2e7"; }
          { mime = "application/x-7z-compressed"; fg = "#f5c2e7"; }
          { mime = "application/x-rar"; fg = "#f5c2e7"; }
          { mime = "application/pdf"; fg = "#f38ba8"; }
          { name = "*.html"; fg = "#fab387"; }
          { name = "*.scss"; fg = "#f5c2e7"; }
          { name = "*.css"; fg = "#89b4fa"; }
          { name = "*.js"; fg = "#f9e2af"; }
          { name = "*.ts"; fg = "#89b4fa"; }
          { name = "*.json"; fg = "#f9e2af"; }
          { name = "*.md"; fg = "#cdd6f4"; }
          { name = "*.py"; fg = "#89b4fa"; }
          { name = "*.rs"; fg = "#fab387"; }
          { name = "*.go"; fg = "#94e2d5"; }
          { name = "*.nix"; fg = "#89b4fa"; }
          { name = "*.lua"; fg = "#89b4fa"; }
          { name = "*.sh"; fg = "#a6e3a1"; }
          { name = "*.toml"; fg = "#fab387"; }
          { name = "*.yaml"; fg = "#f38ba8"; }
          { name = "*.yml"; fg = "#f38ba8"; }
          { name = "*"; fg = "#cdd6f4"; }
        ];
      };
    };
  };

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    fm = "yazi";
    lf = "lf";
    ranger = "ranger";
    sf = "superfile";
  };
}
