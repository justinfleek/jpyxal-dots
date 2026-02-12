{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # GAMING - Full gaming stack for Linux
  # ============================================================================

  home.packages = with pkgs; [
    # === LAUNCHERS ===
    steam                    # Steam client
    lutris                   # Game launcher (GOG, Epic, etc)
    heroic                   # Epic/GOG launcher (native)
    bottles                  # Wine prefix manager
    
    # === WINE & PROTON ===
    wineWowPackages.staging  # Wine with staging patches
    winetricks               # Wine helper scripts
    protontricks             # Proton helper scripts
    protonup-qt              # Proton-GE installer
    
    # === PERFORMANCE ===
    gamemode                 # Optimize system for gaming
    gamescope                # Micro-compositor for games
    mangohud                 # FPS overlay
    goverlay                 # MangoHud GUI config
    vkBasalt                 # Vulkan post-processing
    
    # === CONTROLLERS ===
    antimicrox               # Map controller to keyboard
    sc-controller            # Steam Controller config
    
    # === EMULATORS ===
    retroarch                # Multi-system emulator
    dolphin-emu              # GameCube/Wii
    pcsx2                    # PlayStation 2
    rpcs3                    # PlayStation 3
    yuzu-mainline            # Nintendo Switch
    ryujinx                  # Nintendo Switch (alt)
    
    # === UTILITIES ===
    steamtinkerlaunch        # Steam launch helper
    prusa-slicer             # 3D printing (if you're into that)
    
    # === STREAMING ===
    obs-studio               # Streaming/recording
    obs-studio-plugins.obs-vkcapture  # Vulkan capture
    
    # === VOICE ===
    vesktop                  # Discord with Vencord
    
    # === MISC ===
    vulkan-tools             # Vulkan utilities
    glxinfo                  # OpenGL info
  ];

  # ============================================================================
  # MANGOHUD CONFIG
  # ============================================================================

  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    ### MangoHud Config - Catppuccin Mocha

    # === POSITION ===
    position=top-left
    round_corners=8
    
    # === DISPLAY ===
    fps
    frametime=0
    frame_timing
    gpu_stats
    gpu_temp
    gpu_mem
    gpu_power
    cpu_stats
    cpu_temp
    cpu_power
    ram
    vram
    
    # === STYLE ===
    font_size=20
    font_file=/run/current-system/sw/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFont-Regular.ttf
    background_alpha=0.8
    alpha=1.0
    
    # === CATPPUCCIN MOCHA COLORS ===
    background_color=1e1e2e
    text_color=cdd6f4
    gpu_color=89b4fa
    cpu_color=f38ba8
    vram_color=a6e3a1
    ram_color=fab387
    engine_color=f9e2af
    io_color=94e2d5
    frametime_color=cba6f7
    media_player_color=f5c2e7
    
    # === TOGGLE ===
    toggle_hud=Shift_R+F12
    toggle_fps_limit=Shift_R+F11
    
    # === FPS LIMIT ===
    fps_limit=0,60,144
    
    # === LOGS ===
    output_folder=/tmp/mangohud
    log_duration=30
    toggle_logging=Shift_R+F10
  '';

  # ============================================================================
  # GAMEMODE CONFIG
  # ============================================================================

  xdg.configFile."gamemode.ini".text = ''
    [general]
    renice=10
    softrealtime=auto
    ioprio=0
    
    [gpu]
    apply_gpu_optimisations=accept-responsibility
    gpu_device=0
    nv_powermizer_mode=1
    amd_performance_level=high
    
    [custom]
    start=${pkgs.libnotify}/bin/notify-send 'GameMode' 'Started'
    end=${pkgs.libnotify}/bin/notify-send 'GameMode' 'Stopped'
  '';

  # ============================================================================
  # STEAM LAUNCH OPTIONS CHEATSHEET
  # ============================================================================
  # 
  # MangoHud:
  #   mangohud %command%
  #
  # Gamemode:
  #   gamemoderun %command%
  #
  # Gamescope:
  #   gamescope -W 2560 -H 1440 -r 144 -f -- %command%
  #
  # All combined:
  #   gamemoderun mangohud gamescope -W 2560 -H 1440 -f -- %command%
  #
  # Custom Proton:
  #   PROTON_USE_WINED3D=1 %command%  (use OpenGL)
  #   DXVK_HUD=fps %command%          (DXVK FPS)
  #   VKD3D_DEBUG=none %command%      (less logging)
  #
  # ============================================================================
}
