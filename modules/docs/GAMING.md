# Gaming

```
     ██████╗  █████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗
    ██╔════╝ ██╔══██╗████╗ ████║██║████╗  ██║██╔════╝
    ██║  ███╗███████║██╔████╔██║██║██╔██╗ ██║██║  ███╗
    ██║   ██║██╔══██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║
    ╚██████╔╝██║  ██║██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝
     ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝
```

Full Linux gaming stack with Steam, Lutris, emulators, and performance tools.

## Included Software

### Launchers

| App | Description |
|-----|-------------|
| Steam | Official Steam client |
| Lutris | GOG, Epic, Origin, Uplay |
| Heroic | Epic/GOG (native) |
| Bottles | Wine prefix manager |

### Performance

| Tool | Description |
|------|-------------|
| MangoHud | FPS overlay |
| Gamemode | System optimization |
| Gamescope | Micro-compositor |
| vkBasalt | Vulkan post-processing |

### Emulators

| Emulator | Systems |
|----------|---------|
| RetroArch | Multi-system |
| Dolphin | GameCube, Wii |
| PCSX2 | PlayStation 2 |
| RPCS3 | PlayStation 3 |
| Yuzu | Nintendo Switch |
| Ryujinx | Nintendo Switch |

## MangoHud

### Toggle

| Key | Action |
|-----|--------|
| `Shift + F12` | Toggle HUD |
| `Shift + F11` | Toggle FPS limit |
| `Shift + F10` | Toggle logging |

### Display Info

- FPS & frametime
- CPU usage & temp
- GPU usage, temp, power
- RAM & VRAM usage

### Colors (Catppuccin)

The HUD uses Catppuccin Mocha colors for a unified look.

## Gamemode

Automatically optimizes system when gaming:

- Renice game process
- Set I/O priority
- GPU performance mode
- Sends notification on start/stop

### Usage

```bash
# Run game with gamemode
gamemoderun ./game

# In Steam launch options
gamemoderun %command%
```

## Steam Launch Options

### MangoHud Only

```
mangohud %command%
```

### Gamemode Only

```
gamemoderun %command%
```

### Both

```
gamemoderun mangohud %command%
```

### With Gamescope (best for fullscreen)

```
gamemoderun mangohud gamescope -W 2560 -H 1440 -f -- %command%
```

### Proton Options

```bash
# Use OpenGL instead of DXVK
PROTON_USE_WINED3D=1 %command%

# Show DXVK HUD
DXVK_HUD=fps %command%

# Disable VKD3D debug logging
VKD3D_DEBUG=none %command%

# Force specific Proton
STEAM_COMPAT_DATA_PATH=~/.proton-ge %command%
```

## Gamescope

Micro-compositor for better fullscreen gaming.

### Common Options

```bash
gamescope -W 2560 -H 1440 -r 144 -f -- game
```

| Option | Description |
|--------|-------------|
| `-W` | Output width |
| `-H` | Output height |
| `-r` | Refresh rate |
| `-f` | Fullscreen |
| `-e` | Steam integration |
| `--hdr-enabled` | HDR support |
| `--force-grab-cursor` | Better cursor capture |

## Proton-GE

Install custom Proton versions:

```bash
protonup-qt
```

Gives better compatibility for many games.

## Tips

1. **Enable Proton for all titles**: Steam Settings → Compatibility → Enable Steam Play for all titles
2. **Check compatibility**: https://www.protondb.com
3. **MangoHud config**: `~/.config/MangoHud/MangoHud.conf`
4. **Per-game MangoHud**: `~/.config/MangoHud/game-name.conf`
5. **Check Vulkan**: `vulkaninfo --summary`
