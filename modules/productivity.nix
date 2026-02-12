{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # PRODUCTIVITY - Note-taking, docs, and productivity apps
  # ============================================================================

  home.packages = with pkgs; [
    # === NOTE-TAKING ===
    obsidian                 # Markdown knowledge base
    logseq                   # Outliner + knowledge base
    zettlr                   # Academic markdown
    
    # === TASK MANAGEMENT ===
    todoist-electron         # Todoist client
    super-productivity       # Time tracking + todos
    
    # === DOCUMENTS ===
    zathura                  # PDF viewer (vim keybinds)
    sioyek                   # PDF viewer (research)
    evince                   # PDF viewer (simple)
    libreoffice              # Office suite
    onlyoffice-bin           # Office suite (MS compat)
    
    # === DIAGRAMS ===
    drawio                   # Diagram editor
    
    # === PRESENTATIONS ===
    slides                   # Terminal presentations
    sent                     # Simple presentations
    
    # === CALENDAR ===
    calcurse                 # TUI calendar
    gnome-calendar           # GUI calendar
    
    # === PASSWORDS ===
    bitwarden                # Password manager
    bitwarden-cli            # CLI
    
    # === CLIPBOARD ===
    copyq                    # Clipboard manager GUI
    
    # === SCREENSHOT/ANNOTATION ===
    flameshot                # Screenshot tool
    satty                    # Screenshot annotation
    
    # === SCREEN RECORDING ===
    kooha                    # Screen recorder
    peek                     # GIF recorder
    
    # === MISC ===
    qalculate-gtk            # Calculator
    gnome-clocks             # World clock + timers
  ];

  # ============================================================================
  # ZATHURA CONFIG (already in home.nix, this extends it)
  # ============================================================================

  # Additional zathura config is in home.nix

  # ============================================================================
  # SIOYEK CONFIG
  # ============================================================================

  xdg.configFile."sioyek/prefs_user.config".text = ''
    # Sioyek config - Catppuccin Mocha
    
    # Appearance
    background_color    0.118 0.118 0.180
    text_highlight_color    0.796 0.651 0.969
    visual_mark_color   0.192 0.192 0.270 0.8
    search_highlight_color  0.976 0.886 0.686
    link_highlight_color    0.537 0.705 0.980
    synctex_highlight_color 0.651 0.890 0.631
    
    # UI
    ui_font JetBrainsMono Nerd Font
    font_size 14
    status_bar_font_size 14
    
    # Dark mode
    dark_mode_background_color  0.118 0.118 0.180
    dark_mode_contrast  0.9
    
    # Keybinds (vim-like)
    move_down           j
    move_up             k
    move_left           h
    move_right          l
    next_page           J
    prev_page           K
    zoom_in             =
    zoom_out            -
    fit_to_page_width   w
    fit_to_page_height  W
    goto_toc            t
    search              /
    
    # Performance
    page_separator_width    8
    should_launch_new_window    0
    shared_database_path    ~/.local/share/sioyek
  '';

  # ============================================================================
  # CALCURSE CONFIG
  # ============================================================================

  xdg.configFile."calcurse/conf".text = ''
    # Calcurse config

    appearance.calendarview=monthly
    appearance.compactpanels=no
    appearance.defaultpanel=calendar
    appearance.layout=1
    appearance.headerline=yes
    appearance.eventseparator=yes
    appearance.dateseparator=yes
    appearance.emptyday=yes
    appearance.dayheading=yes
    appearance.notifybar=yes
    appearance.sidebar=yes
    appearance.todoview=yes

    format.inputdate=1
    format.notifydate=%a %d/%m/%Y
    format.notifytime=%H:%M
    format.outputdate=%D
    format.dayheading=%B %e, %Y

    general.autogc=no
    general.autosave=yes
    general.confirmdelete=yes
    general.confirmquit=yes
    general.firstdayofweek=monday
    general.periodicsave=5
    general.systemdialogs=yes

    notification.command=notify-send "Calcurse" "%s"
    notification.notifyall=flagged-only
    notification.warning=300
  '';

  # Calcurse keys (vim-like)
  xdg.configFile."calcurse/keys".text = ''
    generic-cancel  ESC
    generic-select  SPC
    generic-credits  @
    generic-help  ?
    generic-quit  q
    generic-save  s
    generic-reload  R
    generic-copy  y
    generic-paste  p
    generic-change-view  TAB
    generic-import  i
    generic-export  x
    generic-goto  g
    generic-other-cmd  o
    generic-config-menu  C
    generic-redraw  ^R
    generic-add-appt  a
    generic-add-todo  t
    generic-prev-day  h
    generic-next-day  l
    generic-prev-week  k
    generic-next-week  j
    generic-prev-month  K
    generic-next-month  J
    generic-prev-year  Y
    generic-next-year  y
    generic-scroll-down  ^D
    generic-scroll-up  ^U
    generic-goto-today  G
    move-right  l
    move-left  h
    move-down  j
    move-up  k
    start-of-week  0
    end-of-week  $
    add-item  a
    del-item  d
    edit-item  e
    view-item  v
    pipe-item  |
    flag-item  !
    repeat  r
    edit-note  n
    view-note  N
    raise-priority  +
    lower-priority  -
  '';

  # ============================================================================
  # FLAMESHOT CONFIG
  # ============================================================================

  xdg.configFile."flameshot/flameshot.ini".text = ''
    [General]
    contrastOpacity=188
    contrastUiColor=#cba6f7
    copyAndCloseAfterUpload=true
    copyPathAfterSave=true
    disabledTrayIcon=false
    drawColor=#f38ba8
    drawFontSize=8
    drawThickness=3
    filenamePattern=screenshot-%F_%H-%M-%S
    savePath=/home/${config.home.username}/pictures/screenshots
    savePathFixed=true
    showDesktopNotification=true
    showHelp=false
    showMagnifier=true
    showStartupLaunchMessage=false
    squareMagnifier=true
    startupLaunch=false
    uiColor=#313244
  '';

  # ============================================================================
  # SLIDES (Terminal Presentations)
  # ============================================================================

  xdg.configFile."slides/theme.json".text = builtins.toJSON {
    padding = 5;
    date = {
      format = "2006-01-02";
      color = "#cba6f7";
    };
    author = {
      color = "#89b4fa";
    };
    border = {
      color = "#45475a";
      width = 1;
    };
    pager = {
      color = "#6c7086";
    };
    code = {
      theme = "catppuccin-mocha";
    };
    headings = {
      h1 = {
        prefix = "# ";
        color = "#f38ba8";
        bold = true;
      };
      h2 = {
        prefix = "## ";
        color = "#fab387";
        bold = true;
      };
      h3 = {
        prefix = "### ";
        color = "#f9e2af";
      };
    };
    text = {
      primary = "#cdd6f4";
      code = "#a6e3a1";
      bold = "#f5c2e7";
      italic = "#89b4fa";
      strikethrough = "#6c7086";
      underline = "#94e2d5";
    };
  };

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # Notes
    notes = "cd ~/documents/notes && nvim .";
    journal = "nvim ~/documents/notes/journal/$(date +%Y-%m-%d).md";
    
    # PDF
    pdf = "zathura";
    
    # Calendar
    cal = "calcurse";
    
    # Passwords
    bw = "bitwarden-cli";
    
    # Screenshots
    ss = "flameshot gui";
    
    # Calculator
    calc = "qalculate-gtk";
  };
}
