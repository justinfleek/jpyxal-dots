{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # NUSHELL - Modern shell with structured data
  # ============================================================================

  programs.nushell = {
    enable = true;
    
    # Extra packages for nushell
    extraConfig = ''
      # ==========================================================================
      # NUSHELL CONFIGURATION
      # ==========================================================================
      
      # Environment
      $env.config = {
        show_banner: false
        
        # LS colors
        ls: {
          use_ls_colors: true
          clickable_links: true
        }
        
        # Table display
        table: {
          mode: rounded
          index_mode: always
          show_empty: true
          padding: { left: 1, right: 1 }
          trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
          }
          header_on_separator: false
        }
        
        # Error display
        error_style: "fancy"
        
        # History
        history: {
          max_size: 100000
          sync_on_enter: true
          file_format: "sqlite"
          isolation: false
        }
        
        # Completions
        completions: {
          case_sensitive: false
          quick: true
          partial: true
          algorithm: "fuzzy"
          external: {
            enable: true
            max_results: 100
          }
        }
        
        # File size format
        filesize: {
          metric: false
          format: "auto"
        }
        
        # Cursor shape
        cursor_shape: {
          emacs: line
          vi_insert: line
          vi_normal: block
        }
        
        # Edit mode
        edit_mode: vi
        
        # Hooks
        hooks: {
          pre_prompt: []
          pre_execution: []
          env_change: {
            PWD: [{|before, after| null }]
          }
          display_output: "if (term size).columns >= 100 { table -e } else { table }"
          command_not_found: []
        }
        
        # Menus
        menus: [
          {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
              layout: columnar
              columns: 4
              col_width: 20
              col_padding: 2
            }
            style: {
              text: green
              selected_text: { attr: r }
              description_text: yellow
              match_text: { attr: u }
              selected_match_text: { attr: ur }
            }
          }
          {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
              layout: list
              page_size: 10
            }
            style: {
              text: green
              selected_text: green_reverse
              description_text: yellow
            }
          }
        ]
        
        # Keybindings
        keybindings: [
          {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
              until: [
                { send: menu name: completion_menu }
                { send: menunext }
                { edit: complete }
              ]
            }
          }
          {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: history_menu }
          }
          {
            name: escape
            modifier: none
            keycode: escape
            mode: [emacs, vi_normal, vi_insert]
            event: { send: esc }
          }
          {
            name: cancel_command
            modifier: control
            keycode: char_c
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrlc }
          }
          {
            name: clear_screen
            modifier: control
            keycode: char_l
            mode: [emacs, vi_normal, vi_insert]
            event: { send: clearscreen }
          }
        ]
      }
      
      # ==========================================================================
      # ALIASES
      # ==========================================================================
      
      alias ll = ls -l
      alias la = ls -a
      alias lla = ls -la
      alias lt = ls --tree
      
      alias g = git
      alias ga = git add
      alias gc = git commit
      alias gp = git push
      alias gpl = git pull
      alias gs = git status
      alias gd = git diff
      alias lg = lazygit
      
      alias v = nvim
      alias vim = nvim
      
      alias c = clear
      alias q = exit
      
      alias oc = opencode
      
      # ==========================================================================
      # CUSTOM COMMANDS
      # ==========================================================================
      
      # Quick directory navigation
      def --env z [dir: string] {
        cd (zoxide query $dir | str trim)
      }
      
      # Create and cd into directory
      def --env mkcd [dir: string] {
        mkdir $dir
        cd $dir
      }
      
      # Find files
      def ff [pattern: string] {
        fd $pattern
      }
      
      # Find in files
      def fg [pattern: string] {
        rg $pattern
      }
      
      # Git log pretty
      def glog [] {
        git log --oneline --graph --decorate -20 | lines
      }
      
      # System info
      def sysinfo [] {
        {
          os: (sys host | get name)
          kernel: (sys host | get kernel_version)
          uptime: (sys host | get uptime)
          cpu: (sys cpu | get brand | first)
          memory: $"(sys mem | get used) / (sys mem | get total)"
        }
      }
      
      # JSON pretty print
      def jp [] {
        $in | from json | to json --indent 2
      }
      
      # Process finder
      def pf [name: string] {
        ps | where name =~ $name
      }
      
      # Quick HTTP requests
      def get [url: string] {
        http get $url
      }
      
      def post [url: string, body: any] {
        http post $url $body
      }
    '';
    
    # Environment configuration
    environmentVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  # Carapace - shell completion
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  # Starship works with nushell
  programs.starship.enableNushellIntegration = true;

  # Zoxide works with nushell  
  programs.zoxide.enableNushellIntegration = true;

  # Atuin works with nushell
  programs.atuin.enableNushellIntegration = true;

  # Direnv works with nushell
  programs.direnv.enableNushellIntegration = true;
}
