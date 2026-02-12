# Containers

```
     ██████╗ ██████╗ ███╗   ██╗████████╗ █████╗ ██╗███╗   ██╗███████╗██████╗ ███████╗
    ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝██╔══██╗██╔════╝
    ██║     ██║   ██║██╔██╗ ██║   ██║   ███████║██║██╔██╗ ██║█████╗  ██████╔╝███████╗
    ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██║██║██║╚██╗██║██╔══╝  ██╔══██╗╚════██║
    ╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║██║ ╚████║███████╗██║  ██║███████║
     ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚══════╝
```

Container and virtualization tools: Docker, Podman, Kubernetes, Distrobox.

## Included Tools

### Containers

| Tool | Description |
|------|-------------|
| Podman | Rootless Docker alternative |
| Docker Compose | Multi-container apps |
| Distrobox | Use any Linux distro |
| Lazydocker | Docker TUI |
| Dive | Explore image layers |

### Kubernetes

| Tool | Description |
|------|-------------|
| kubectl | K8s CLI |
| k9s | K8s TUI |
| kubectx/kubens | Context/namespace switcher |
| Helm | K8s package manager |
| Kind | K8s in Docker |
| Minikube | Local K8s |

### Infrastructure

| Tool | Description |
|------|-------------|
| Terraform | Infrastructure as code |
| Ansible | Configuration management |
| Packer | Image builder |
| Vagrant | Dev environments |

## Distrobox

Use any Linux distro in your terminal.

### Create Containers

```bash
# Create Arch container
distrobox create -n arch -i archlinux

# Create Fedora container
distrobox create -n fedora -i fedora

# Create Ubuntu container
distrobox create -n ubuntu -i ubuntu
```

### Enter Container

```bash
distrobox enter arch
# or use alias
arch
```

### Export Apps

```bash
# Inside distrobox
distrobox-export --app firefox
distrobox-export --bin /usr/bin/some-app --export-path ~/.local/bin
```

### Aliases

| Alias | Command |
|-------|---------|
| `db` | `distrobox` |
| `dbe` | `distrobox enter` |
| `dbc` | `distrobox create` |
| `dbl` | `distrobox list` |
| `dbr` | `distrobox rm` |
| `arch` | `distrobox enter arch` |
| `fedora` | `distrobox enter fedora` |
| `ubuntu` | `distrobox enter ubuntu` |

## Podman

Rootless container runtime (Docker-compatible).

### Aliases

| Alias | Command |
|-------|---------|
| `pd` | `podman` |
| `pdi` | `podman images` |
| `pdc` | `podman ps` |
| `pdca` | `podman ps -a` |
| `pdr` | `podman run -it --rm` |

### Common Commands

```bash
# Run container
podman run -it --rm ubuntu bash

# List containers
podman ps -a

# Build image
podman build -t myimage .

# Push to registry
podman push myimage docker.io/user/myimage
```

## Docker Compose

### Aliases

| Alias | Command |
|-------|---------|
| `dc` | `docker-compose` |
| `dcu` | `docker-compose up -d` |
| `dcd` | `docker-compose down` |
| `dcl` | `docker-compose logs -f` |

## Lazydocker

TUI for Docker/Podman.

### Launch

```bash
lazydocker
```

### Keybinds

| Key | Action |
|-----|--------|
| `j/k` | Navigate |
| `Enter` | Select |
| `d` | Delete |
| `s` | Stop |
| `r` | Restart |
| `a` | Attach |
| `l` | Logs |
| `[` | Previous tab |
| `]` | Next tab |
| `q` | Quit |

## Kubernetes (k9s)

TUI for Kubernetes.

### Launch

```bash
k9s
```

### Keybinds

| Key | Action |
|-----|--------|
| `:` | Command mode |
| `/` | Filter |
| `d` | Describe |
| `l` | Logs |
| `s` | Shell |
| `e` | Edit |
| `Ctrl+D` | Delete |
| `y` | YAML |
| `Esc` | Back |
| `q` | Quit |

### Quick Commands

Type `:` then:

| Command | Action |
|---------|--------|
| `pods` | View pods |
| `deploy` | View deployments |
| `svc` | View services |
| `ns` | View namespaces |
| `ctx` | View contexts |
| `help` | Show help |

### Aliases

| Alias | Command |
|-------|---------|
| `k` | `kubectl` |
| `kx` | `kubectx` |
| `kn` | `kubens` |
| `kga` | `kubectl get all` |
| `kgp` | `kubectl get pods` |
| `kgs` | `kubectl get svc` |
| `kl` | `kubectl logs -f` |
| `ke` | `kubectl exec -it` |

## Tips

1. **Podman is Docker-compatible**: Use `podman` anywhere you'd use `docker`
2. **Rootless by default**: Podman doesn't need sudo
3. **Distrobox exports**: Export apps from any distro to your host
4. **k9s theme**: Catppuccin Mocha is pre-configured
5. **Context switching**: Use `kubectx` to switch K8s clusters easily
