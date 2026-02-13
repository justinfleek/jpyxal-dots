{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # RESEARCH TOOLS - Sioyek, Zotero, academic workflow
  # ============================================================================

  home.packages = with pkgs; [
    # PDF viewers
    sioyek               # PDF viewer for research papers
    zathura              # Minimal PDF viewer
    evince               # GNOME PDF viewer
    
    # Reference management
    zotero               # Citation manager
    
    # Note-taking
    logseq               # Knowledge graph
    
    # Writing
    typst                # Modern LaTeX alternative
    texlive.combined.scheme-full # Full LaTeX
    pandoc               # Document converter
    
    # E-books
    calibre              # E-book management
    
    # Research tools
    bibtool              # BibTeX tool
    biber                # BibLaTeX backend
  ];

  # ============================================================================
  # SIOYEK - PDF viewer for research papers
  # ============================================================================

  xdg.configFile."sioyek/prefs_user.config".text = ''
    # Sioyek Configuration - Research PDF viewer

    # === APPEARANCE ===
    
    # Colors (Catppuccin Mocha)
    background_color    0.118 0.118 0.180
    dark_mode_background_color    0.118 0.118 0.180
    dark_mode_contrast    0.9
    
    text_highlight_color    0.976 0.886 0.686
    visual_mark_color    0.000 0.5 1.0 0.2
    search_highlight_color    0.953 0.545 0.659
    link_highlight_color    0.537 0.706 0.980
    synctex_highlight_color    0.647 0.890 0.631
    
    # Custom colors for highlights
    highlight_color_a    0.976 0.886 0.686
    highlight_color_b    0.647 0.890 0.631
    highlight_color_c    0.537 0.706 0.980
    highlight_color_d    0.953 0.545 0.659
    highlight_color_e    0.961 0.761 0.906
    highlight_color_f    0.580 0.886 0.835
    
    # UI
    page_separator_width    4
    page_separator_color    0.271 0.278 0.353
    status_bar_color    0.180 0.188 0.251
    status_bar_text_color    0.804 0.839 0.957
    
    # === BEHAVIOR ===
    
    # Start in dark mode
    default_dark_mode    1
    
    # Smooth scrolling
    smooth_scroll_speed    3.0
    smooth_scroll_drag    2000
    
    # Page cache
    page_cache_size    100
    
    # Fit width by default
    fit_to_page_width_ratio    0.95
    
    # === SYNCTEX ===
    
    # Neovim integration
    inverse_search_command    nvim --headless -c "VimtexInverseSearch %2 '%1'"
    
    # === KEYBINDINGS ===
    # (defined in keys_user.config)
    
    # === MISC ===
    
    # Ruler mode (for reading papers)
    ruler_mode    1
    ruler_padding    10
    ruler_x_padding    30
    
    # Super fast search
    super_fast_search    1
    
    # Prerender pages
    prerender_next_page_count    5
    
    # Check for updates
    check_for_updates_on_startup    0
  '';

  xdg.configFile."sioyek/keys_user.config".text = ''
    # Sioyek Keybindings - Vim-style

    # === NAVIGATION ===
    
    # Basic movement
    move_down            j
    move_up              k
    move_left            h
    move_right           l
    
    # Page navigation
    next_page            J
    previous_page        K
    goto_page_with_page_number    g
    
    # Scroll
    screen_down          <C-d>
    screen_up            <C-u>
    
    # Go to beginning/end
    goto_beginning       gg
    goto_end             G
    
    # Zoom
    zoom_in              +
    zoom_in              =
    zoom_out             -
    fit_to_page_width    w
    fit_to_page_height   e
    fit_to_page_width_smart    W
    
    # === SEARCH ===
    
    search               /
    search               <C-f>
    next_item            n
    previous_item        N
    
    # === MARKS & BOOKMARKS ===
    
    set_mark             m
    goto_mark            '
    add_bookmark         B
    delete_bookmark      db
    goto_bookmark        gb
    goto_bookmark_g      gB
    
    # === LINKS ===
    
    open_link            f
    copy_link            F
    
    # === HIGHLIGHTS ===
    
    # Different highlight colors
    add_highlight_with_color_a    ha
    add_highlight_with_color_b    hb
    add_highlight_with_color_c    hc
    add_highlight_with_color_d    hd
    add_highlight_with_color_e    he
    add_highlight_with_color_f    hf
    delete_highlight     dh
    goto_next_highlight  ]h
    goto_prev_highlight  [h
    
    # === TABLE OF CONTENTS ===
    
    toggle_table_of_contents    t
    
    # === DARK MODE ===
    
    toggle_dark_mode     <C-i>
    
    # === PORTALS (for papers with references) ===
    
    portal               p
    delete_portal        dp
    goto_portal          gp
    
    # === SYNCTEX ===
    
    synctex_under_cursor    <C-]>
    
    # === EXTERNAL ===
    
    # Open in external viewer
    external_search      S
    
    # Copy text
    copy                 y
    
    # === MISC ===
    
    toggle_fullscreen    <F11>
    quit                 q
    command              :
    
    # Ruler (great for reading papers)
    toggle_horizontal_scroll_lock    R
    
    # Overview (jump to any page)
    overview_definition  o
    
    # Select text
    toggle_select_highlight    v
    
    # Open file
    open_document        O
    open_document_embedded    <C-o>
  '';

  # ============================================================================
  # ZATHURA - Minimal PDF viewer (backup)
  # ============================================================================

  programs.zathura = {
    enable = true;
    
    options = {
      # Colors (Catppuccin Mocha)
      default-bg = "#1e1e2e";
      default-fg = "#cdd6f4";
      
      statusbar-fg = "#cdd6f4";
      statusbar-bg = "#313244";
      
      inputbar-bg = "#313244";
      inputbar-fg = "#cdd6f4";
      
      notification-bg = "#313244";
      notification-fg = "#cdd6f4";
      notification-error-bg = "#313244";
      notification-error-fg = "#f38ba8";
      notification-warning-bg = "#313244";
      notification-warning-fg = "#f9e2af";
      
      highlight-color = "#f9e2af";
      highlight-active-color = "#f5c2e7";
      
      completion-bg = "#313244";
      completion-fg = "#cdd6f4";
      completion-highlight-bg = "#45475a";
      completion-highlight-fg = "#cdd6f4";
      completion-group-bg = "#313244";
      completion-group-fg = "#89b4fa";
      
      index-bg = "#1e1e2e";
      index-fg = "#cdd6f4";
      index-active-bg = "#313244";
      index-active-fg = "#cdd6f4";
      
      render-loading-bg = "#1e1e2e";
      render-loading-fg = "#cdd6f4";
      
      recolor-lightcolor = "#1e1e2e";
      recolor-darkcolor = "#cdd6f4";
      
      # Settings
      recolor = true;
      recolor-keephue = true;
      selection-clipboard = "clipboard";
      adjust-open = "best-fit";
      pages-per-row = 1;
      scroll-page-aware = true;
      scroll-full-overlap = "0.01";
      scroll-step = 100;
      zoom-min = 10;
      guioptions = "";
      
      # Font
      font = "JetBrainsMono Nerd Font 11";
    };
    
    mappings = {
      # Navigation
      D = "toggle_page_mode";
      r = "reload";
      R = "rotate";
      K = "zoom in";
      J = "zoom out";
      i = "recolor";
      p = "print";
      g = "goto top";
      
      # vim-style
      "<C-d>" = "scroll half-down";
      "<C-u>" = "scroll half-up";
    };
  };

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    pdf = "sioyek";
    zth = "zathura";
    zot = "zotero";
  };
}
