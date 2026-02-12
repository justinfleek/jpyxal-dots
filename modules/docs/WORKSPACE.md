# Workspace

```
    ██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗███████╗██████╗  █████╗  ██████╗███████╗
    ██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝
    ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ ███████╗██████╔╝███████║██║     █████╗
    ██║███╗██║██║   ██║██╔══██╗██╔═██╗ ╚════██║██╔═══╝ ██╔══██║██║     ██╔══╝
    ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗███████║██║     ██║  ██║╚██████╗███████╗
     ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝╚══════╝
```

Your development workspace with OpenCode, Dhall, PureScript, Lean 4, and more.

## Quick Start

```bash
# Setup workspace (clone all repos)
workspace-setup
# or
wss

# Sync all repos
workspace-sync
# or
wsy

# Open OpenCode in workspace
workspace-opencode
# or
wso

# Open workspace in tmux
workspace-tmux
```

## Repositories

| Alias | Repo | Path |
|-------|------|------|
| `sensenet` | straylight-software/sensenet | ~/workspace/sensenet |
| `nvidia` | weyl-ai/nvidia-sdk | ~/workspace/nvidia-sdk |
| `nxc` | straylight-software/nix-compile | ~/workspace/nix-compile |
| `slide` | straylight-software/slide | ~/workspace/slide |
| `isospin` | straylight-software/isospin-microvm | ~/workspace/isospin-microvm |
| `omega` | omega-agentic/omega-agentic | ~/workspace/omega-agentic |

Just type the alias to cd into that repo.

## Stack

### OpenCode

AI coding assistant pre-configured for your workspace.

```bash
# Open in workspace
wso

# Or manually
cd ~/workspace && opencode
```

### Dhall

Programmable configuration language.

```bash
dhall              # REPL
dhall-to-json      # Convert to JSON
dhall-to-yaml      # Convert to YAML
dhall-to-bash      # Convert to Bash
```

#### Aliases

| Alias | Command |
|-------|---------|
| `dh` | `dhall` |
| `dhj` | `dhall-to-json` |
| `dhy` | `dhall-to-yaml` |

### PureScript / Halogen

Functional frontend development.

```bash
spago build        # Build project
spago test         # Run tests
spago run          # Run project
spago bundle-app   # Bundle for browser
purs-tidy format-in-place src/**/*.purs  # Format
```

#### Aliases

| Alias | Command |
|-------|---------|
| `ps` | `purs` |
| `sp` | `spago` |
| `spb` | `spago build` |
| `spt` | `spago test` |
| `spr` | `spago run` |

#### Create New Project

```bash
mkpurs my-project
```

### Lean 4

Theorem prover and programming language.

```bash
lake build         # Build project
lake test          # Run tests
lake clean         # Clean build
lake update        # Update deps
```

#### Aliases

| Alias | Command |
|-------|---------|
| `lk` | `lake` |
| `lkb` | `lake build` |
| `lkt` | `lake test` |

#### Create New Project

```bash
mklean my-project
```

### Tailscale

Mesh VPN for secure networking.

```bash
tailscale status   # Check status
sudo tailscale up  # Connect
sudo tailscale down # Disconnect
```

#### Aliases

| Alias | Command |
|-------|---------|
| `ts` | `tailscale` |
| `tss` | `tailscale status` |
| `tsu` | `sudo tailscale up` |
| `tsd` | `sudo tailscale down` |

## Tmux Workspace

Open all repos in a tmux session:

```bash
workspace-tmux
```

This creates:
- `main` - ~/workspace
- `sensenet` - sensenet repo
- `nvidia` - nvidia-sdk repo
- `nix-compile` - nix-compile repo
- `slide` - slide repo
- `isospin` - isospin-microvm repo
- `omega` - omega-agentic repo

## Project Templates

Create new projects with pre-configured flakes:

```bash
# PureScript/Halogen
mkpurs my-project

# Dhall
mkdhall my-project

# Lean 4
mklean my-project
```

Templates include:
- `flake.nix` with all dependencies
- `.envrc` for direnv
- Proper LSP support

## OpenCode Skills

The workspace includes OpenCode skills for:

- **workspace** - Navigation and commands
- **purescript** - PureScript/Halogen patterns
- **dhall** - Dhall configuration
- **lean4** - Lean 4 theorem proving

These load automatically when you run `opencode` in the workspace.

## Full Startup

Run everything:

```bash
start-workspace
```

This will:
1. Ensure workspace is set up
2. Sync all repos
3. Start Tailscale
4. Open tmux workspace

## Tips

1. **Quick navigation**: Just type repo name as alias
2. **Sync daily**: Run `wsy` to keep repos updated
3. **Use tmux**: `workspace-tmux` for multi-repo work
4. **direnv auto-loads**: Each repo with `.envrc` auto-activates
5. **OpenCode context**: Run from ~/workspace for full context
