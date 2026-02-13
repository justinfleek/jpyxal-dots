# PRISM Themes & Editor Integration

Unified theming system across all editors with 64 curated color themes.

## Included Editors

### Cursor IDE

AI-first code editor based on VS Code. Since it's not in nixpkgs, install with:

```bash
cursor-install
```

This downloads the AppImage and creates a wrapper script. Update with `cursor-update`.

Config location: `~/.config/Cursor/User/settings.json`

### VS Code / VSCodium

Pre-configured with PRISM themes and vim keybindings.

### Emacs (hypermodern-emacs)

Modern Emacs setup with completion, LSP, and doom themes:

```bash
hypermodern-emacs-setup
```

Or run directly: `nix run github:b7r6/hypermodern-emacs`

### Neovim

PRISM plugin auto-installed via LazyVim config.

### OpenCode

Themes copied to `~/.config/opencode/themes/`

## Theme Management

### Setup PRISM Themes

```bash
prism-setup
# or
prism
```

Clones/updates PRISM repo and installs themes to all editors.

### Switch Themes

```bash
# List available themes
theme-switch

# Switch to a theme
theme-switch nord_aurora
theme-switch catppuccin_mocha
theme-switch tokyo_night_bento
```

## Available Themes

PRISM includes 64 curated themes across categories:

**Dark Themes:**
- nord_aurora, catppuccin_mocha, gruvbox_material
- tokyo_night_bento, one_dark_pro, night_owl
- holographic, neon_nexus, vaporwave_sunset
- nero_marquina, midnight_sapphire, aurora_glass
- And 50+ more...

**Light Themes:**
- catppuccin_latte, one_light, github_light
- rose_pine_dawn, everforest_light

## Theme Locations

| Editor | Location |
|--------|----------|
| VS Code | `~/.vscode/extensions/prism-themes/` |
| Cursor | `~/.cursor/extensions/prism-themes/` |
| Neovim | Via LazyVim plugin system |
| Emacs | Via doom-themes (compatible) |
| OpenCode | `~/.config/opencode/themes/` |
| Alacritty | `~/.config/alacritty/themes/` |
| Kitty | `~/.config/kitty/themes/` |
| WezTerm | `~/.config/wezterm/colors/` |

## Keybindings

### Cursor/VS Code
- Standard VS Code keybindings
- Vim mode enabled by default

### Emacs (hypermodern-emacs)
- `SPC` - Leader key (evil mode)
- `M-x` - Command palette
- `C-x C-f` - Find file
- `C-c g` - Magit

### Neovim
- See `NEOVIM.md` for full keybindings
