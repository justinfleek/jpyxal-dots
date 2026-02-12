{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # MUSIC - Terminal music stack with MPD, ncmpcpp, cava
  # ============================================================================

  home.packages = with pkgs; [
    # === AUDIO ===
    mpd                      # Music Player Daemon
    mpc-cli                  # MPD CLI
    ncmpcpp                  # MPD TUI client
    cava                     # Audio visualizer
    playerctl                # Media control
    
    # === SPOTIFY ===
    spotify-player           # TUI for Spotify
    spotifyd                 # Spotify daemon
    
    # === OTHER ===
    musikcube                # Cross-platform music player
    cmus                     # CLI music player
    
    # === TOOLS ===
    ffmpeg                   # Media conversion
    yt-dlp                   # Download from YouTube
    beets                    # Music organizer
  ];

  # ============================================================================
  # MPD CONFIG
  # ============================================================================

  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/music";
    
    extraConfig = ''
      # Audio output
      audio_output {
        type            "pipewire"
        name            "PipeWire Sound Server"
      }
      
      # Visualization FIFO
      audio_output {
        type            "fifo"
        name            "Visualizer"
        path            "/tmp/mpd.fifo"
        format          "44100:16:2"
      }
      
      # HTTP streaming
      audio_output {
        type            "httpd"
        name            "HTTP Stream"
        encoder         "vorbis"
        port            "8000"
        quality         "5.0"
        format          "44100:16:2"
      }
      
      # Settings
      auto_update             "yes"
      restore_paused          "yes"
      max_output_buffer_size  "16384"
    '';
  };

  # ============================================================================
  # NCMPCPP CONFIG
  # ============================================================================

  programs.ncmpcpp = {
    enable = true;
    mpdMusicDir = "${config.home.homeDirectory}/music";
    
    settings = {
      # MPD connection
      mpd_host = "localhost";
      mpd_port = 6600;
      
      # Visualizer
      visualizer_data_source = "/tmp/mpd.fifo";
      visualizer_output_name = "Visualizer";
      visualizer_in_stereo = "yes";
      visualizer_type = "spectrum";
      visualizer_look = "●▮";
      visualizer_color = "blue, cyan, green, yellow, magenta, red";
      visualizer_spectrum_smooth_look = "yes";
      
      # Interface
      user_interface = "alternative";
      playlist_display_mode = "columns";
      browser_display_mode = "columns";
      search_engine_display_mode = "columns";
      playlist_editor_display_mode = "columns";
      
      # Progress bar
      progressbar_look = "─╼ ";
      progressbar_color = "blue:b";
      progressbar_elapsed_color = "magenta:b";
      
      # Now playing
      song_list_format = "{$5%a$9} {$2%t$9}$R{$7%b$9} {$8(%l)$9}";
      song_status_format = "$7%a$9 - $5%t$9 - $2%b$9";
      song_window_title_format = "{%a - %t}";
      
      # Library
      song_library_format = "{%n - }{%t}|{%f}";
      
      # Colors (Catppuccin Mocha)
      colors_enabled = "yes";
      main_window_color = "white";
      header_window_color = "magenta";
      volume_color = "blue:b";
      state_line_color = "black:b";
      state_flags_color = "magenta:b";
      current_item_prefix = "$(magenta)$r";
      current_item_suffix = "$/r$(end)";
      current_item_inactive_column_prefix = "$(blue)$r";
      current_item_inactive_column_suffix = "$/r$(end)";
      
      # Other
      lyrics_directory = "${config.home.homeDirectory}/music/lyrics";
      follow_now_playing_lyrics = "yes";
      fetch_lyrics_for_current_song_in_background = "yes";
      store_lyrics_in_song_dir = "no";
      external_editor = "nvim";
      use_console_editor = "yes";
      
      # Startup
      startup_screen = "playlist";
      startup_slave_screen = "visualizer";
      startup_slave_screen_focus = "no";
      locked_screen_width_part = 50;
      
      # Misc
      enable_window_title = "yes";
      mouse_support = "yes";
      display_bitrate = "yes";
      display_remaining_time = "yes";
      clock_display_seconds = "no";
      ignore_leading_the = "yes";
    };
    
    bindings = [
      { key = "j"; command = "scroll_down"; }
      { key = "k"; command = "scroll_up"; }
      { key = "J"; command = [ "select_item" "scroll_down" ]; }
      { key = "K"; command = [ "select_item" "scroll_up" ]; }
      { key = "h"; command = "previous_column"; }
      { key = "l"; command = "next_column"; }
      { key = "g"; command = "move_home"; }
      { key = "G"; command = "move_end"; }
      { key = "n"; command = "next_found_item"; }
      { key = "N"; command = "previous_found_item"; }
      { key = "v"; command = "show_visualizer"; }
      { key = "L"; command = "show_lyrics"; }
    ];
  };

  # ============================================================================
  # CAVA CONFIG
  # ============================================================================

  xdg.configFile."cava/config".text = ''
    # Cava config - Catppuccin Mocha

    [general]
    mode = normal
    framerate = 60
    autosens = 1
    overshoot = 20
    sensitivity = 100
    bars = 0
    bar_width = 2
    bar_spacing = 1
    lower_cutoff_freq = 50
    higher_cutoff_freq = 10000

    [input]
    method = fifo
    source = /tmp/mpd.fifo
    sample_rate = 44100
    sample_bits = 16
    channels = stereo

    [output]
    method = ncurses
    channels = stereo
    mono_option = average
    reverse = 0
    bar_delimiter = 0
    ascii_max_range = 1000
    data_format = binary
    bit_format = 16bit

    [color]
    # Catppuccin Mocha gradient
    gradient = 1
    gradient_count = 8
    gradient_color_1 = '#89b4fa'
    gradient_color_2 = '#89dceb'
    gradient_color_3 = '#94e2d5'
    gradient_color_4 = '#a6e3a1'
    gradient_color_5 = '#f9e2af'
    gradient_color_6 = '#fab387'
    gradient_color_7 = '#f38ba8'
    gradient_color_8 = '#cba6f7'

    [smoothing]
    integral = 77
    monstercat = 1
    waves = 1
    gravity = 100
    ignore = 0

    [eq]
    1 = 1
    2 = 1
    3 = 1
    4 = 1
    5 = 1
  '';

  # ============================================================================
  # SPOTIFY-PLAYER CONFIG
  # ============================================================================

  xdg.configFile."spotify-player/app.toml".text = ''
    theme = "default"
    
    [device]
    name = "spotify-player"
    device_type = "computer"
    volume = 70
    bitrate = 320
    audio_cache = true
    
    [playback]
    track_table_item_max_len = 32
    enable_media_control = true
    
    [keymaps]
    # Vim-like keybindings
    next_track = ["n", "l"]
    previous_track = ["p", "h"]
    volume_up = ["=", "+"]
    volume_down = ["-"]
    seek_forward = ["L", ">"]
    seek_backward = ["H", "<"]
  '';

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # MPD
    mpc = "mpc";
    music = "ncmpcpp";
    play = "mpc play";
    pause = "mpc pause";
    next = "mpc next";
    prev = "mpc prev";
    
    # Cava
    vis = "cava";
    visualizer = "cava";
    
    # YouTube
    yta = "yt-dlp -x --audio-format mp3 --audio-quality 0";
    ytv = "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]'";
    
    # Spotify
    sp = "spotify-player";
  };
}
