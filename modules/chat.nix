{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # CHAT - Terminal chat clients for IRC, Matrix, etc
  # ============================================================================

  home.packages = with pkgs; [
    # === IRC ===
    weechat                  # IRC client
    irssi                    # Classic IRC
    
    # === MATRIX ===
    iamb                     # Matrix TUI
    element-desktop          # Matrix GUI
    
    # === DISCORD ===
    vesktop                  # Discord with Vencord
    # Also see BetterDiscord in home.nix packages
    
    # === MISC ===
    signal-desktop           # Signal messenger
    telegram-desktop         # Telegram
    slack                    # Slack
  ];

  # ============================================================================
  # WEECHAT CONFIG
  # ============================================================================

  programs.weechat = {
    enable = true;
    init = ''
      # Catppuccin Mocha colors
      /set weechat.bar.status.color_bg 30
      /set weechat.bar.title.color_bg 30
      /set weechat.color.chat_nick_colors 1,2,3,4,5,6,9,10,11,12,13
      
      # UI
      /set weechat.look.buffer_time_format "%H:%M"
      /set weechat.look.prefix_suffix "│"
      /set weechat.look.read_marker_string "─"
      
      # Encryption
      /secure passphrase
    '';
  };

  # Weechat config
  xdg.configFile."weechat/weechat.conf".text = ''
    # WeeChat configuration

    [debug]

    [startup]
    command_after_plugins = ""
    command_before_plugins = ""
    display_logo = on
    display_version = on
    sys_rlimit = ""

    [look]
    align_end_of_lines = message
    align_multiline_words = on
    bar_more_down = "++"
    bar_more_left = "<<"
    bar_more_right = ">>"
    bar_more_up = "--"
    bare_display_exit_on_input = on
    bare_display_time_format = "%H:%M"
    buffer_auto_renumber = on
    buffer_notify_default = all
    buffer_position = end
    buffer_search_case_sensitive = off
    buffer_search_force_default = off
    buffer_search_regex = off
    buffer_search_where = prefix_message
    buffer_time_format = "%H:%M"
    buffer_time_same = ""
    color_basic_force_bold = off
    color_inactive_buffer = on
    color_inactive_message = on
    color_inactive_prefix = on
    color_inactive_prefix_buffer = on
    color_inactive_time = off
    color_inactive_window = on
    color_nick_offline = off
    color_pairs_auto_reset = 5
    color_real_white = off
    command_chars = ""
    command_incomplete = off
    confirm_quit = off
    confirm_upgrade = off
    day_change = on
    day_change_message_1date = "-- %a, %d %b %Y --"
    day_change_message_2dates = "-- %%a, %%d %%b %%Y (%a, %d %b %Y) --"
    eat_newline_glitch = off
    emphasized_attributes = ""
    highlight = ""
    highlight_disable_regex = off
    highlight_regex = ""
    highlight_tags = ""
    hotlist_add_conditions = "${away} || ${buffer.num_displayed} == 0"
    hotlist_buffer_separator = ", "
    hotlist_count_max = 2
    hotlist_count_min_msg = 2
    hotlist_names_count = 3
    hotlist_names_length = 0
    hotlist_names_level = 12
    hotlist_names_merged_buffers = off
    hotlist_prefix = "H: "
    hotlist_remove = merged
    hotlist_short_names = on
    hotlist_sort = group_time_asc
    hotlist_suffix = ""
    hotlist_unique_numbers = on
    input_cursor_scroll = 20
    input_multiline_lead_linebreak = on
    input_share = none
    input_share_overwrite = off
    input_undo_max = 32
    item_away_message = on
    item_buffer_filter = "*"
    item_buffer_zoom = "!"
    item_mouse_status = "M"
    item_time_format = "%H:%M"
    jump_current_to_previous_buffer = on
    jump_previous_buffer_when_closing = on
    jump_smart_back_to_buffer = on
    key_bind_safe = on
    key_grab_delay = 800
    mouse = on
    mouse_timer_delay = 100
    nick_color_force = ""
    nick_color_hash = djb2
    nick_color_hash_salt = ""
    nick_color_stop_chars = "_|["
    nick_prefix = ""
    nick_suffix = ""
    paste_auto_add_newline = on
    paste_bracketed = on
    paste_bracketed_timer_delay = 10
    paste_max_lines = 100
    prefix_action = " *"
    prefix_align = right
    prefix_align_max = 15
    prefix_align_min = 0
    prefix_align_more = "+"
    prefix_align_more_after = on
    prefix_buffer_align = right
    prefix_buffer_align_max = 0
    prefix_buffer_align_more = "+"
    prefix_buffer_align_more_after = on
    prefix_error = "=!="
    prefix_join = "-->"
    prefix_network = "--"
    prefix_quit = "<--"
    prefix_same_nick = ""
    prefix_same_nick_middle = ""
    prefix_suffix = "│"
    quote_nick_prefix = "<"
    quote_nick_suffix = ">"
    quote_time_format = "%H:%M:%S"
    read_marker = line
    read_marker_always_show = off
    read_marker_string = "─"
    read_marker_update_on_buffer_switch = on
    save_config_on_exit = on
    save_config_with_fsync = off
    save_layout_on_exit = none
    scroll_amount = 3
    scroll_bottom_after_switch = off
    scroll_page_percent = 100
    search_text_not_found_alert = on
    separator_horizontal = "─"
    separator_vertical = ""
    tab_width = 1
    time_format = "%a, %d %b %Y %T"
    window_auto_zoom = off
    window_separator_horizontal = on
    window_separator_vertical = on
    window_title = "WeeChat ${info:version}"
    word_chars_highlight = "!\u00A0,-,_,|,alnum"
    word_chars_input = "!\u00A0,-,_,|,alnum"
  '';

  # ============================================================================
  # IAMB (Matrix) CONFIG
  # ============================================================================

  xdg.configFile."iamb/config.toml".text = ''
    # Iamb config (Matrix client)
    # See: https://iamb.chat/configure.html
    
    [profiles.main]
    # user_id = "@you:matrix.org"
    # url = "https://matrix.org"

    [settings]
    username_display = "displayname"
    message_user_color = true
    message_shortcode_display = true
    reaction_display = true
    reaction_shortcode_display = true
    read_receipt_send = true
    read_receipt_display = true
    request_timeout = 120
    typing_notice_send = true
    typing_notice_display = true
    users = "long"
    default_room = ""
    open_command = "xdg-open"
    
    [dirs]
    cache = "~/.cache/iamb"
    logs = "~/.local/share/iamb/logs"
    downloads = "~/downloads"

    [macros]
    "n" = "<C-Down>"
    "p" = "<C-Up>"
  '';

  # ============================================================================
  # VESKTOP (Discord with Vencord) CONFIG
  # ============================================================================

  # Vesktop has Vencord built-in, so we just need to create the css file
  xdg.configFile."vesktop/themes/catppuccin-mocha.theme.css".text = ''
    /**
     * @name Catppuccin Mocha
     * @author catppuccin
     * @version 1.0.0
     * @description Catppuccin Mocha theme for Discord
     */

    @import url('https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css');
  '';

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    irc = "weechat";
    matrix = "iamb";
    discord = "vesktop";
  };
}
