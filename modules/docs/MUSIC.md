# Music

```
    ███╗   ███╗██╗   ██╗███████╗██╗ ██████╗
    ████╗ ████║██║   ██║██╔════╝██║██╔════╝
    ██╔████╔██║██║   ██║███████╗██║██║
    ██║╚██╔╝██║██║   ██║╚════██║██║██║
    ██║ ╚═╝ ██║╚██████╔╝███████║██║╚██████╗
    ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝ ╚═════╝
```

Terminal music stack with MPD, ncmpcpp, cava visualizer, and Spotify.

## Components

| Tool | Description |
|------|-------------|
| MPD | Music Player Daemon |
| ncmpcpp | MPD TUI client |
| cava | Audio visualizer |
| spotify-player | Spotify TUI |
| yt-dlp | YouTube downloader |

## ncmpcpp

### Navigation

| Key | Action |
|-----|--------|
| `j/k` | Scroll down/up |
| `h/l` | Previous/next column |
| `g` | Go to top |
| `G` | Go to bottom |
| `Tab` | Switch view |

### Playback

| Key | Action |
|-----|--------|
| `Enter` | Play selection |
| `p` | Pause |
| `s` | Stop |
| `>` | Next track |
| `<` | Previous track |
| `f` | Seek forward |
| `b` | Seek backward |
| `r` | Toggle repeat |
| `z` | Toggle random |

### Playlist

| Key | Action |
|-----|--------|
| `a` | Add to playlist |
| `A` | Add album |
| `d` | Delete from playlist |
| `c` | Clear playlist |
| `S` | Save playlist |
| `o` | Load playlist |

### Views

| Key | Action |
|-----|--------|
| `1` | Playlist |
| `2` | Browser |
| `3` | Search |
| `4` | Library |
| `5` | Playlist editor |
| `6` | Tag editor |
| `7` | Outputs |
| `8` | Visualizer |
| `v` | Quick visualizer |
| `L` | Lyrics |

### Search

| Key | Action |
|-----|--------|
| `/` | Search |
| `n` | Next match |
| `N` | Previous match |

## Cava Visualizer

Audio spectrum visualizer with Catppuccin gradient.

### Launch

```bash
cava
# or
vis
```

### Controls

| Key | Action |
|-----|--------|
| `q` | Quit |
| `+/-` | Sensitivity |
| `b` | Toggle bar style |
| `c` | Change color |
| `r` | Reload config |

### Config

Edit `~/.config/cava/config` to customize:

- Bar width/spacing
- Smoothing
- Colors (gradient)
- Input source

## Shell Aliases

| Alias | Command |
|-------|---------|
| `music` | Open ncmpcpp |
| `vis` | Open cava |
| `play` | Play music |
| `pause` | Pause music |
| `next` | Next track |
| `prev` | Previous track |
| `sp` | Spotify player |

## YouTube Download

```bash
# Download audio only (MP3)
yta "https://youtube.com/watch?v=..."

# Download video
ytv "https://youtube.com/watch?v=..."
```

## Spotify Player

Terminal Spotify client.

### Keybinds

| Key | Action |
|-----|--------|
| `n` | Next track |
| `p` | Previous track |
| `Space` | Play/pause |
| `+/-` | Volume |
| `/` | Search |
| `q` | Quit |

### Setup

First run will prompt for Spotify authentication.

## MPD Setup

Music directory: `~/music`

MPD creates a database from your music files. To update:

```bash
mpc update
```

### Outputs

MPD is configured with:
- PipeWire output (audio)
- FIFO output (for cava)
- HTTP stream (port 8000)

## Tips

1. **Split view**: Use `v` in ncmpcpp for visualizer + playlist
2. **Fetch lyrics**: Automatic with `fetch_lyrics_for_current_song_in_background`
3. **Update library**: `mpc update` after adding music
4. **Cava + ncmpcpp**: Run side by side in tmux
