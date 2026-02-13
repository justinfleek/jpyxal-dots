# j-pyxal dots

```
       ██╗      ██████╗ ██╗   ██╗██╗  ██╗ █████╗ ██╗
       ██║      ██╔══██╗╚██╗ ██╔╝╚██╗██╔╝██╔══██╗██║
       ██║█████╗██████╔╝ ╚████╔╝  ╚███╔╝ ███████║██║
  ██   ██║╚════╝██╔═══╝   ╚██╔╝   ██╔██╗ ██╔══██║██║
  ╚█████╔╝      ██║        ██║   ██╔╝ ██╗██║  ██║███████╗
   ╚════╝       ╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
```

**THE KITCHEN SINK** - A fully riced NixOS Home Manager configuration with EVERYTHING.

Catppuccin Mocha + Hyprland + vim joyer vibes + AI/ML stack + ComfyUI + the works.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/justinfleek/home-manager/main/install.sh | bash -s -- --workspace
```

## What's Included

### Core Desktop

| Component | Description |
|-----------|-------------|
| **Hyprland** | Tiling Wayland compositor with animations |
| **Sway** | Alternative i3-compatible WM |
| **Niri** | Scrollable tiling WM |
| **Waybar** | Glassmorphism status bar |
| **AGS** | Aylur-style GTK widgets |
| **HyprPanel** | Modern panel for Hyprland |
| **Rofi** | App launcher |
| **Dunst/Mako** | Notifications |

### Terminals & Shells

| Component | Description |
|-----------|-------------|
| **Ghostty** | GPU-accelerated terminal |
| **Wezterm** | Lua-configurable GPU terminal |
| **Zellij** | Modern tmux alternative |
| **Rio** | Rust WebGPU terminal |
| **Bash** | With Starship + Atuin |
| **Nushell** | Structured data shell |

### Editors

| Component | Description |
|-----------|-------------|
| **Neovim** | LazyVim IDE with full LSP |
| **Neovide** | GPU Neovim GUI with animations |
| **Helix** | Post-modern modal editor |
| **Emacs** | hypermodern-emacs setup |
| **VS Code** | VSCodium with PRISM themes |
| **Cursor** | AI-first code editor |

### File Managers

| Component | Description |
|-----------|-------------|
| **Yazi** | Fast rust file manager |
| **LF** | Minimal Go file manager |
| **Ranger** | Classic Python file manager |
| **Superfile** | Modern TUI file manager |

### AI/ML Stack

| Component | Description |
|-----------|-------------|
| **Ollama** | Local LLM runtime |
| **Open WebUI** | Web interface for LLMs |
| **ComfyUI** | Stable Diffusion workflows with fxy custom nodes |
| **Aider** | AI pair programming |
| **OpenCode** | AI coding assistant |
| **Whisper** | Speech-to-text |
| **Piper TTS** | Text-to-speech |

### ComfyUI Custom Nodes

50+ custom nodes from the fxy infrastructure:

- **Core**: Impact Pack, KJNodes, Essentials, WAS Suite
- **Video**: WanVideoWrapper, Steerable Motion, GIMM-VFI
- **Image**: Florence2, DepthAnythingV2, SAM3, RMBG
- **Performance**: GGUF, bitsandbytes NF4, TensorRT
- **Audio**: MMAudio, Audio Separation
- And many more...

### Development

| Component | Description |
|-----------|-------------|
| **Languages** | Rust, Go, Python, Node, Zig, Haskell, Dhall, PureScript, Lean4 |
| **Containers** | Docker, Podman, K8s, Lazydocker, K9s |
| **Git** | Lazygit, Delta, gh CLI |
| **API Tools** | Posting, HTTPie, Hurl |

### GPU/NVIDIA

| Component | Description |
|-----------|-------------|
| **CUDA** | Full CUDA 12/13 support |
| **cuDNN** | Deep learning libraries |
| **nvtop/nvitop** | GPU monitoring |
| **PyTorch** | With CUDA acceleration |
| **TensorRT** | Inference optimization |

### Apps & Media

| Component | Description |
|-----------|-------------|
| **Firefox** | Riced with userChrome |
| **Zen Browser** | Privacy Firefox fork |
| **Brave/Vivaldi** | Alternative browsers |
| **Qutebrowser** | Vim-style browser |
| **Spicetify** | Themed Spotify |
| **MPD/ncmpcpp** | Music player + visualizer |
| **Sioyek** | Research PDF viewer |
| **Zotero** | Citation manager |

### Productivity

| Component | Description |
|-----------|-------------|
| **Obsidian** | Knowledge management |
| **Syncthing** | P2P file sync |
| **Restic/Borg** | Backups |
| **Calcurse** | Calendar |

### Communication

| Component | Description |
|-----------|-------------|
| **Vesktop** | Discord client |
| **iamb** | Matrix TUI |
| **Weechat** | IRC |
| **Aerc** | Email |

## File Structure

```
.
├── flake.nix                    # Main flake with all inputs
├── home.nix                     # Core home config
├── install.sh                   # curl | bash installer
└── modules/
    ├── hyprland.nix             # Window manager
    ├── sway.nix                 # Alternative WM
    ├── niri.nix                 # Scrollable tiling WM
    ├── waybar.nix               # Status bar
    ├── ags.nix                  # GTK widgets (Aylur-style)
    ├── hyprpanel.nix            # Modern panel
    ├── terminals.nix            # Zellij, Wezterm, Rio
    ├── ghostty.nix              # Primary terminal
    ├── nushell.nix              # Modern shell
    ├── shell.nix                # Bash + Starship + Atuin
    ├── neovim.nix               # Editor (LazyVim)
    ├── editors-extra.nix        # Helix, Neovide
    ├── file-managers.nix        # LF, Ranger, Superfile, Yazi
    ├── ai-local.nix             # Ollama, Open WebUI
    ├── ai-coding.nix            # Aider, Continue
    ├── comfyui.nix              # ComfyUI with fxy nodes
    ├── speech.nix               # Whisper, TTS
    ├── nvidia.nix               # GPU tools, CUDA
    ├── browsers.nix             # Zen, Vivaldi, Brave, Qutebrowser
    ├── containers.nix           # Docker, Podman
    ├── containers-extra.nix     # Lazydocker, K9s
    ├── research.nix             # Sioyek, Zotero
    ├── sync.nix                 # Syncthing, backups
    ├── prism-themes.nix         # PRISM themes for all editors
    ├── workspace.nix            # Dhall, PureScript, Lean4
    └── opencode-workspace.nix   # Multi-repo OpenCode config
```

## Keybindings

### Hyprland

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal (Ghostty) |
| `Super + Space` | App launcher (Rofi) |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + H/J/K/L` | Focus vim-style |
| `Super + Shift + H/J/K/L` | Move window |
| `Super + 1-9` | Workspaces |
| `Super + V` | Clipboard history |
| `Print` | Screenshot |
| `Super + Escape` | Power menu |

### Shell Aliases

```bash
# AI
chat           # Chat with local LLM
code-ai        # Code generation
comfy          # Run ComfyUI
oc             # OpenCode

# Navigation
lg             # Lazygit
fm             # Yazi file manager
lzd            # Lazydocker
k9             # K9s

# Nix
hms            # home-manager switch
nfu            # nix flake update
```

## ComfyUI Setup

The config integrates with [weyl-ai/nixified-ai-flake](https://github.com/weyl-ai/nixified-ai-flake) for Nix-native ComfyUI with GPU support.

```bash
# Setup ComfyUI with fxy infrastructure
comfy-setup

# Run ComfyUI
comfy

# Download models
comfy-dl

# Check custom nodes
comfy-nodes
```

### NixOS Service

For NixOS systems, add to your configuration:

```nix
{ inputs, ... }: {
  imports = [ inputs.nixified-ai.nixosModules.comfyui ];
  
  services.comfyui = {
    enable = true;
    acceleration = "cuda";
    customNodes = with pkgs.comfyuiCustomNodes; [
      comfyui-impact-pack
      comfyui-kjnodes
      comfyui-essentials
      # ... see modules/comfyui.nix for full list
    ];
  };
}
```

## Theming

- **Colorscheme**: Catppuccin Mocha everywhere
- **PRISM Themes**: 64 curated themes for all editors
- **GTK/QT**: Matching system themes
- **Cursors**: Catppuccin cursors
- **Icons**: Papirus Dark

Switch themes:
```bash
prism          # Setup PRISM themes
themes         # Switch color theme
```

## Prerequisites

1. NixOS with flakes enabled
2. NVIDIA GPU (for AI/ML features)
3. Add to `/etc/nixos/configuration.nix`:

```nix
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.hyprland.enable = true;
  
  # For NVIDIA
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
```

## Updating

```bash
cd ~/.config/home-manager
nix flake update
home-manager switch --flake .#$(whoami)
```

## Credits

- [vim joyer](https://www.youtube.com/@vimjoyer) - Inspiration
- [Catppuccin](https://catppuccin.com/) - Theme
- [weyl-ai/nixified-ai-flake](https://github.com/weyl-ai/nixified-ai-flake) - ComfyUI Nix packaging
- [fxy infrastructure](https://github.com/straylight-software) - GPU/ML tooling
- [PRISM](https://github.com/justinfleek/PRISM) - Theme collection
- [hypermodern-emacs](https://github.com/b7r6/hypermodern-emacs) - Emacs config

---

**j-pyxal dots** - *the kitchen sink, riced to perfection*
