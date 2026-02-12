{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # CONTAINERS - Development containers and virtualization
  # ============================================================================

  home.packages = with pkgs; [
    # === CONTAINERS ===
    podman                   # Docker alternative (rootless)
    podman-compose           # Docker-compose for Podman
    podman-tui               # TUI for Podman
    distrobox                # Use any Linux distro in terminal
    toolbox                  # Fedora toolbox
    
    # === DOCKER ===
    docker-compose           # Multi-container apps
    lazydocker               # TUI for Docker
    dive                     # Explore docker layers
    
    # === KUBERNETES ===
    kubectl                  # K8s CLI
    kubectx                  # Switch contexts
    k9s                      # K8s TUI
    helm                     # K8s package manager
    kind                     # K8s in Docker
    minikube                 # Local K8s
    
    # === VIRTUALIZATION ===
    # Note: QEMU/KVM needs system config
    virt-manager             # VM GUI
    
    # === INFRASTRUCTURE ===
    terraform                # Infrastructure as code
    ansible                  # Configuration management
    packer                   # Image builder
    vagrant                  # Dev environments
  ];

  # ============================================================================
  # DISTROBOX ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # Distrobox
    db = "distrobox";
    dbe = "distrobox enter";
    dbc = "distrobox create";
    dbl = "distrobox list";
    dbr = "distrobox rm";
    dbs = "distrobox stop";
    
    # Quick distroboxes
    arch = "distrobox enter arch";
    fedora = "distrobox enter fedora";
    ubuntu = "distrobox enter ubuntu";
    debian = "distrobox enter debian";
    
    # Podman
    pd = "podman";
    pdi = "podman images";
    pdc = "podman ps";
    pdca = "podman ps -a";
    pdr = "podman run -it --rm";
    
    # Docker
    d = "docker";
    dc = "docker-compose";
    dcu = "docker-compose up -d";
    dcd = "docker-compose down";
    dcl = "docker-compose logs -f";
    
    # Kubernetes
    k = "kubectl";
    kx = "kubectx";
    kn = "kubens";
    kga = "kubectl get all";
    kgp = "kubectl get pods";
    kgs = "kubectl get svc";
    kgd = "kubectl get deployments";
    kl = "kubectl logs -f";
    ke = "kubectl exec -it";
  };

  # ============================================================================
  # K9S CONFIG
  # ============================================================================

  xdg.configFile."k9s/skin.yml".text = ''
    # Catppuccin Mocha for k9s
    k9s:
      body:
        fgColor: "#cdd6f4"
        bgColor: "#1e1e2e"
        logoColor: "#cba6f7"
      prompt:
        fgColor: "#cdd6f4"
        bgColor: "#1e1e2e"
        suggestColor: "#89b4fa"
      info:
        fgColor: "#f5c2e7"
        sectionColor: "#cdd6f4"
      dialog:
        fgColor: "#cdd6f4"
        bgColor: "#313244"
        buttonFgColor: "#1e1e2e"
        buttonBgColor: "#cba6f7"
        buttonFocusFgColor: "#1e1e2e"
        buttonFocusBgColor: "#f5c2e7"
        labelFgColor: "#fab387"
        fieldFgColor: "#cdd6f4"
      frame:
        border:
          fgColor: "#45475a"
          focusColor: "#cba6f7"
        menu:
          fgColor: "#cdd6f4"
          keyColor: "#89b4fa"
          numKeyColor: "#f38ba8"
        crumbs:
          fgColor: "#1e1e2e"
          bgColor: "#cba6f7"
          activeColor: "#f5c2e7"
        status:
          newColor: "#a6e3a1"
          modifyColor: "#89b4fa"
          addColor: "#a6e3a1"
          errorColor: "#f38ba8"
          highlightColor: "#fab387"
          killColor: "#585b70"
          completedColor: "#6c7086"
        title:
          fgColor: "#cdd6f4"
          bgColor: "#313244"
          highlightColor: "#cba6f7"
          counterColor: "#f5c2e7"
          filterColor: "#a6e3a1"
      views:
        charts:
          bgColor: "#1e1e2e"
          defaultDialColors:
            - "#89b4fa"
            - "#f38ba8"
          defaultChartColors:
            - "#89b4fa"
            - "#f38ba8"
        table:
          fgColor: "#cdd6f4"
          bgColor: "#1e1e2e"
          cursorFgColor: "#1e1e2e"
          cursorBgColor: "#45475a"
          markColor: "#fab387"
          header:
            fgColor: "#cdd6f4"
            bgColor: "#1e1e2e"
            sorterColor: "#94e2d5"
        xray:
          fgColor: "#cdd6f4"
          bgColor: "#1e1e2e"
          cursorColor: "#45475a"
          graphicColor: "#cba6f7"
          showIcons: false
        yaml:
          keyColor: "#89b4fa"
          colonColor: "#585b70"
          valueColor: "#cdd6f4"
        logs:
          fgColor: "#cdd6f4"
          bgColor: "#1e1e2e"
          indicator:
            fgColor: "#cdd6f4"
            bgColor: "#cba6f7"
  '';

  # ============================================================================
  # LAZYDOCKER CONFIG
  # ============================================================================

  xdg.configFile."lazydocker/config.yml".text = ''
    gui:
      scrollHeight: 2
      theme:
        activeBorderColor:
          - "#cba6f7"
          - bold
        inactiveBorderColor:
          - "#45475a"
        selectedLineBgColor:
          - "#313244"
        optionsTextColor:
          - "#89b4fa"
    commandTemplates:
      dockerCompose: docker compose
    oS:
      openCommand: xdg-open {{filename}}
      openLinkCommand: xdg-open {{link}}
  '';
}
