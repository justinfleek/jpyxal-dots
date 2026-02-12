# Hypermodern Home Manager

```
    ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ ███╗   ███╗ ██████╗ ██████╗ ███████╗██████╗ ███╗   ██╗
    ██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗████╗ ████║██╔═══██╗██╔══██╗██╔════╝██╔══██╗████╗  ██║
    ███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝██╔████╔██║██║   ██║██║  ██║█████╗  ██████╔╝██╔██╗ ██║
    ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║╚██╗██║
    ██║  ██║   ██║   ██║     ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗██║  ██║██║ ╚████║
    ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝
```

**THE KITCHEN SINK** - A fully riced NixOS Home Manager configuration with EVERYTHING.

### Core Desktop

| Component | Description | Docs |
|-----------|-------------|------|
| [Hyprland](modules/docs/HYPRLAND.md) | Tiling Wayland compositor | [Keybinds](modules/docs/HYPRLAND.md) |
| [Waybar](modules/docs/WAYBAR.md) | Glassmorphism status bar | [Modules](modules/docs/WAYBAR.md) |
| [EWW](modules/eww.nix) | Desktop widgets | - |
| [Rofi](modules/docs/ROFI.md) | App launcher | [Usage](modules/docs/ROFI.md) |
| [Dunst](modules/docs/DUNST.md) | Notifications | [Config](modules/docs/DUNST.md) |

### Terminal & Shell

| Component | Description | Docs |
|-----------|-------------|------|
| [Ghostty](modules/docs/GHOSTTY.md) | GPU-accelerated terminal | [Keybinds](modules/docs/GHOSTTY.md) |
| [Tmux](modules/docs/TMUX.md) | Terminal multiplexer | [Keybinds](modules/docs/TMUX.md) |
| [Shell](modules/docs/SHELL.md) | Bash + Starship + Atuin | [Aliases](modules/docs/SHELL.md) |

### Development

| Component | Description |
|-----------|-------------|
| [Neovim](modules/docs/NEOVIM.md) | LazyVim IDE with LSPs |
| [Dev Tools](modules/dev.nix) | Rust, Go, Python, Node, Zig, Haskell |
| [Containers](modules/containers.nix) | Docker, Podman, K8s, Distrobox |
| [Git](modules/git.nix) | Git + Lazygit + Delta + gh |

### Apps & Media

| Component | Description |
|-----------|-------------|
| Firefox | Riced browser with userChrome |
| [Spicetify](modules/spicetify.nix) | Themed Spotify |
| [Music](modules/music.nix) | MPD + ncmpcpp + cava visualizer |
| [Gaming](modules/gaming.nix) | Steam, Lutris, MangoHud, Gamemode |
| [Productivity](modules/productivity.nix) | Obsidian, Zathura, Calcurse |

### Communication

| Component | Description |
|-----------|-------------|
| [Chat](modules/chat.nix) | Discord (Vesktop), Matrix, IRC |
| [Email](modules/email.nix) | Aerc, Himalaya |

### Theming

| Component | Description |
|-----------|-------------|
| Catppuccin Mocha | Unified theme EVERYWHERE |
| GTK/QT | Matching system theme |
| Cursors & Icons | Catppuccin cursors + Papirus |

## Prerequisites

1. NixOS with flakes enabled
2. Add to your `/etc/nixos/configuration.nix`:

```nix
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # For Hyprland
  programs.hyprland.enable = true;

  # Required system packages
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
  ];

  # Audio (pipewire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    inter
  ];
}
```

## Quick Start

1. **Clone this config:**

```bash
cd ~/.config
git clone <this-repo> home-manager
cd home-manager
```

2. **Edit your username:**

Open `flake.nix` and change:

```nix
username = "justin"; # Change to your username
```

3. **Build and activate:**

```bash
# First time setup
nix run nixpkgs#home-manager -- switch --flake .#$(whoami)

# After first run
home-manager switch --flake .#$(whoami)
```

4. **Reboot and login to Hyprland**

## File Structure

```
.
├── flake.nix           # Flake definition with all inputs
├── home.nix            # Main config with packages and settings
├── README.md           # You are here
└── modules/
    ├── hyprland.nix    # Window manager + lock screen + idle
    ├── waybar.nix      # Status bar
    ├── ghostty.nix     # Terminal
    ├── neovim.nix      # Editor (LazyVim)
    ├── shell.nix       # Bash + Starship + Atuin
    ├── tmux.nix        # Terminal multiplexer
    ├── rofi.nix        # App launcher
    ├── dunst.nix       # Notifications
    ├── firefox.nix     # Browser
    ├── git.nix         # Git + GitHub CLI
    ├── tools.nix       # Additional utilities
    └── docs/           # Detailed documentation
        ├── HYPRLAND.md # Window manager keybinds
        ├── WAYBAR.md   # Status bar modules
        ├── GHOSTTY.md  # Terminal keybinds
        ├── NEOVIM.md   # Editor keybinds (LazyVim)
        ├── TMUX.md     # Multiplexer keybinds
        ├── SHELL.md    # Shell aliases & functions
        ├── ROFI.md     # Launcher usage
        └── DUNST.md    # Notification config
```

## Keybindings

### Hyprland

| Key                       | Action                   |
| ------------------------- | ------------------------ |
| `Super + Return`          | Terminal (Ghostty)       |
| `Super + Space`           | App launcher (Rofi)      |
| `Super + B`               | Browser (Firefox)        |
| `Super + E`               | File manager             |
| `Super + Q`               | Close window             |
| `Super + F`               | Fullscreen               |
| `Super + T`               | Toggle floating          |
| `Super + H/J/K/L`         | Focus left/down/up/right |
| `Super + Shift + H/J/K/L` | Move window              |
| `Super + 1-9`             | Switch workspace         |
| `Super + Shift + 1-9`     | Move to workspace        |
| `Super + V`               | Clipboard history        |
| `Print`                   | Screenshot area          |
| `Shift + Print`           | Screenshot fullscreen    |
| `Super + Shift + Escape`  | Lock screen              |
| `Super + Escape`          | Power menu               |

### Tmux

| Key                | Action                     |
| ------------------ | -------------------------- |
| `Ctrl + A`         | Prefix (instead of Ctrl+B) |
| `Prefix + \|`      | Split horizontal           |
| `Prefix + -`       | Split vertical             |
| `Prefix + h/j/k/l` | Navigate panes             |
| `Prefix + H/J/K/L` | Resize panes               |
| `Prefix + c`       | New window                 |
| `Prefix + ,`       | Rename window              |
| `Alt + G`          | Popup lazygit              |
| `Alt + T`          | Popup btop                 |

### Neovim

Standard LazyVim keybindings plus:

| Key          | Action              |
| ------------ | ------------------- |
| `Space`      | Leader key          |
| `jk` / `kj`  | Escape              |
| `Space + e`  | File explorer       |
| `Space + ff` | Find files          |
| `Space + fg` | Live grep           |
| `Space + l`  | Lazy plugin manager |

## Shell Aliases

```bash
# Navigation
..     # cd ..
...    # cd ../..

# Listing (eza)
ls     # Icons + directories first
ll     # Long list
la     # Show hidden
lt     # Tree view

# Git
g      # git
gs     # status
ga     # add
gc     # commit
gp     # push
lg     # lazygit

# Nix
nrs    # nixos-rebuild switch
hms    # home-manager switch
nfu    # nix flake update

# Utils
v      # nvim
c      # clear
ff     # fastfetch
```

## Shell Functions

```bash
mkcd <dir>      # Create and cd into directory
extract <file>  # Extract any archive
fcd             # Fuzzy cd with fzf
fe              # Fuzzy edit with fzf
fkill           # Fuzzy kill process
fbr             # Fuzzy git branch switch
serve [port]    # Quick HTTP server
note [name]     # Quick notes
```

## Customization

### Change Colorscheme

The config uses Catppuccin Mocha. To switch flavors, edit `home.nix`:

```nix
catppuccin = {
  enable = true;
  flavor = "mocha";  # latte, frappe, macchiato, mocha
  accent = "mauve";  # rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender
};
```

### Add Wallpapers

Put wallpapers in `~/.local/share/wallpapers/` then press `Super + W` to cycle.

### Add Firefox Extensions

Uncomment and edit the extensions section in `modules/firefox.nix`.

### Adjust Monitors

Edit the monitor section in `modules/hyprland.nix`:

```nix
monitor = [
  "DP-1,2560x1440@144,0x0,1"
  "HDMI-A-1,1920x1080@60,2560x0,1"
];
```

Use `hyprctl monitors` to find your monitor names.

## Updating

```bash
cd ~/.config/home-manager

# Update all flake inputs
nix flake update

# Rebuild
home-manager switch --flake .#$(whoami)
```

## Troubleshooting

### Fonts not showing correctly

```bash
fc-cache -fv
```

### Hyprland not starting

Check logs:

```bash
cat ~/.local/share/hyprland/hyprland.log
```

### Neovim plugins not installing

Open neovim and run `:Lazy sync`

### Home Manager build fails

```bash
# Check what's wrong
home-manager switch --flake .#$(whoami) --show-trace

# Clear old generations
home-manager expire-generations "-7 days"
nix-collect-garbage -d
```

## Credits

- Inspired by [vim joyer](https://www.youtube.com/@vimjoyer) videos
- [Catppuccin](https://catppuccin.com/) theme
- [LazyVim](https://www.lazyvim.org/) neovim distribution
- [Hyprland](https://hyprland.org/) compositor

Enjoy your riced setup!
