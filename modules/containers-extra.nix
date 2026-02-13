{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # CONTAINERS EXTRA - Lazydocker, K8s TUIs, more tools
  # ============================================================================

  home.packages = with pkgs; [
    # Docker TUI
    lazydocker             # Docker TUI
    dive                   # Docker image explorer
    ctop                   # Container top
    dockly                 # Docker console UI
    
    # Kubernetes TUIs
    k9s                    # Kubernetes TUI
    kdash                  # Kubernetes dashboard TUI
    kubespy                # Kubernetes resource watching
    stern                  # Multi-pod log tailing
    kubectx                # Context/namespace switching
    kubie                  # Context/namespace manager
    
    # Kubernetes tools
    kubectl
    kubernetes-helm
    helmfile
    kustomize
    kubeseal               # Sealed secrets
    krew                   # kubectl plugin manager
    
    # Kubernetes development
    kind                   # Kubernetes in Docker
    minikube
    k3d                    # k3s in Docker
    tilt                   # Local K8s dev
    skaffold               # K8s development workflow
    
    # Container building
    buildah                # OCI image builder
    skopeo                 # Container image CLI
    crane                  # Container registry tool
    
    # Compose
    docker-compose
    podman-compose
    
    # Security
    trivy                  # Container vulnerability scanner
    grype                  # Container vulnerability scanner
    syft                   # SBOM generator
    
    # Networking
    kubeshark              # K8s network sniffer
  ];

  # ============================================================================
  # LAZYDOCKER CONFIG
  # ============================================================================

  xdg.configFile."lazydocker/config.yml".text = ''
    # Lazydocker Configuration
    
    gui:
      scrollHeight: 2
      language: "auto"
      theme:
        activeBorderColor:
          - "#89b4fa"
          - bold
        inactiveBorderColor:
          - "#45475a"
        selectedLineBgColor:
          - "#313244"
        optionsTextColor:
          - "#89b4fa"
      returnImmediately: false
      wrapMainPanel: true
      sidePanelWidth: 0.333
      showAllContainers: false
      
    logs:
      timestamps: false
      since: '60m'
      tail: 200
      
    commandTemplates:
      dockerCompose: docker compose
      restartService: '{{ .DockerCompose }} restart {{ .Service.Name }}'
      up: '{{ .DockerCompose }} up -d'
      down: '{{ .DockerCompose }} down'
      downWithVolumes: '{{ .DockerCompose }} down --volumes'
      upService: '{{ .DockerCompose }} up -d {{ .Service.Name }}'
      startService: '{{ .DockerCompose }} start {{ .Service.Name }}'
      stopService: '{{ .DockerCompose }} stop {{ .Service.Name }}'
      serviceLogs: '{{ .DockerCompose }} logs --since=60m --follow {{ .Service.Name }}'
      viewServiceLogs: '{{ .DockerCompose }} logs --follow {{ .Service.Name }}'
      rebuildService: '{{ .DockerCompose }} up -d --build {{ .Service.Name }}'
      recreateService: '{{ .DockerCompose }} up -d --force-recreate {{ .Service.Name }}'
      
    oS:
      openCommand: xdg-open {{filename}}
      openLinkCommand: xdg-open {{link}}
      
    stats:
      graphs:
        - caption: CPU (%)
          statPath: DerivedStats.CPUPercentage
          color: blue
        - caption: Memory (%)
          statPath: DerivedStats.MemoryPercentage
          color: green
  '';

  # ============================================================================
  # K9S CONFIG
  # ============================================================================

  xdg.configFile."k9s/config.yml".text = ''
    k9s:
      liveViewAutoRefresh: true
      refreshRate: 2
      maxConnRetry: 5
      readOnly: false
      noExitOnCtrlC: false
      ui:
        enableMouse: true
        headless: false
        logoless: false
        crumbsless: false
        reactive: true
        noIcons: false
        defaultsToFullScreen: false
        skin: catppuccin-mocha
      skipLatestRevCheck: false
      disablePodCounting: false
      shellPod:
        image: busybox:1.35.0
        namespace: default
        limits:
          cpu: 100m
          memory: 100Mi
      imageScans:
        enable: false
      logger:
        tail: 100
        buffer: 5000
        sinceSeconds: 300
        fullScreenLogs: false
        textWrap: false
        showTime: false
      thresholds:
        cpu:
          critical: 90
          warn: 70
        memory:
          critical: 90
          warn: 70
  '';

  # K9s Catppuccin skin
  xdg.configFile."k9s/skins/catppuccin-mocha.yml".text = ''
    # K9s Catppuccin Mocha skin
    k9s:
      body:
        fgColor: "#cdd6f4"
        bgColor: "#1e1e2e"
        logoColor: "#89b4fa"
      prompt:
        fgColor: "#cdd6f4"
        bgColor: "#1e1e2e"
        suggestColor: "#89b4fa"
      info:
        fgColor: "#89b4fa"
        sectionColor: "#cdd6f4"
      dialog:
        fgColor: "#cdd6f4"
        bgColor: "#1e1e2e"
        buttonFgColor: "#1e1e2e"
        buttonBgColor: "#89b4fa"
        buttonFocusFgColor: "#1e1e2e"
        buttonFocusBgColor: "#a6e3a1"
        labelFgColor: "#f9e2af"
        fieldFgColor: "#cdd6f4"
      frame:
        border:
          fgColor: "#45475a"
          focusColor: "#89b4fa"
        menu:
          fgColor: "#cdd6f4"
          keyColor: "#89b4fa"
          numKeyColor: "#f9e2af"
        crumbs:
          fgColor: "#1e1e2e"
          bgColor: "#89b4fa"
          activeColor: "#f5c2e7"
        status:
          newColor: "#94e2d5"
          modifyColor: "#89b4fa"
          addColor: "#a6e3a1"
          pendingColor: "#f9e2af"
          errorColor: "#f38ba8"
          highlightColor: "#f5c2e7"
          killColor: "#f5c2e7"
          completedColor: "#6c7086"
        title:
          fgColor: "#cdd6f4"
          bgColor: "#1e1e2e"
          highlightColor: "#f5c2e7"
          counterColor: "#89b4fa"
          filterColor: "#a6e3a1"
      views:
        charts:
          bgColor: "#1e1e2e"
          dialBgColor: "#1e1e2e"
          chartBgColor: "#1e1e2e"
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
          markColor: "#f9e2af"
          header:
            fgColor: "#cdd6f4"
            bgColor: "#1e1e2e"
            sorterColor: "#94e2d5"
        xray:
          fgColor: "#cdd6f4"
          bgColor: "#1e1e2e"
          cursorColor: "#45475a"
          cursorTextColor: "#1e1e2e"
          graphicColor: "#89b4fa"
        yaml:
          keyColor: "#89b4fa"
          colonColor: "#45475a"
          valueColor: "#cdd6f4"
        logs:
          fgColor: "#cdd6f4"
          bgColor: "#1e1e2e"
          indicator:
            fgColor: "#cdd6f4"
            bgColor: "#1e1e2e"
  '';

  # ============================================================================
  # DIVE CONFIG
  # ============================================================================

  xdg.configFile."dive/.dive.yaml".text = ''
    # Dive Configuration
    
    log:
      enabled: true
      path: ./dive.log
      level: info
      
    # CI rules
    rules:
      lowestEfficiency: 0.9
      highestWastedBytes: disabled
      highestUserWastedPercent: 0.1
      
    diff:
      hide:
        - added
        - removed
        - modified
        
    filetree:
      # show-attributes only on file details
      showAttributes: true
      # collapse all directories
      collapseDir: false
      # the percentage of screen width the filetree should take
      paneWidth: 0.5
      
    layer:
      showAggregatedChanges: false
      
    keybinding:
      quit: q
      toggle-view: tab
      filter-files: ctrl+f
      toggle-added-files: ctrl+a
      toggle-removed-files: ctrl+r
      toggle-modified-files: ctrl+m
      toggle-unchanged-files: ctrl+u
      toggle-filetree-collapse: space
      toggle-all-collapse: ctrl+space
      page-up: pgup
      page-down: pgdn
  '';

  # ============================================================================
  # HELPER SCRIPTS
  # ============================================================================

  home.file.".local/bin/docker-clean" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Clean up Docker resources
      
      echo "=== Docker Cleanup ==="
      echo ""
      
      echo "Stopping all containers..."
      docker stop $(docker ps -q) 2>/dev/null || echo "No running containers"
      
      echo ""
      echo "Removing stopped containers..."
      docker container prune -f
      
      echo ""
      echo "Removing unused images..."
      docker image prune -f
      
      echo ""
      echo "Removing unused volumes..."
      docker volume prune -f
      
      echo ""
      echo "Removing unused networks..."
      docker network prune -f
      
      echo ""
      echo "=== Cleanup Complete ==="
      docker system df
    '';
  };

  home.file.".local/bin/docker-nuke" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # DANGER: Remove ALL Docker resources
      
      echo "⚠️  WARNING: This will remove ALL Docker resources!"
      echo "   - All containers (running and stopped)"
      echo "   - All images"
      echo "   - All volumes"
      echo "   - All networks"
      echo ""
      read -p "Are you sure? (type 'yes' to confirm): " confirm
      
      if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        exit 1
      fi
      
      echo ""
      echo "Stopping all containers..."
      docker stop $(docker ps -aq) 2>/dev/null
      
      echo "Removing all containers..."
      docker rm -f $(docker ps -aq) 2>/dev/null
      
      echo "Removing all images..."
      docker rmi -f $(docker images -aq) 2>/dev/null
      
      echo "Removing all volumes..."
      docker volume rm $(docker volume ls -q) 2>/dev/null
      
      echo "Pruning system..."
      docker system prune -af --volumes
      
      echo ""
      echo "=== Docker Nuked ==="
      docker system df
    '';
  };

  home.file.".local/bin/kube-ctx" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Quick Kubernetes context/namespace switching with fzf
      
      case "$1" in
        ctx|context)
          kubectl config get-contexts -o name | fzf --header "Select context" | xargs -r kubectl config use-context
          ;;
        ns|namespace)
          kubectl get namespaces -o name | sed 's|namespace/||' | fzf --header "Select namespace" | xargs -r kubectl config set-context --current --namespace
          ;;
        *)
          echo "Usage: kube-ctx [ctx|ns]"
          echo ""
          echo "  ctx   - Switch Kubernetes context"
          echo "  ns    - Switch namespace"
          ;;
      esac
    '';
  };

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # Docker
    lzd = "lazydocker";
    dps = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'";
    dimg = "docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'";
    dexec = "docker exec -it";
    dlogs = "docker logs -f";
    dclean = "docker-clean";
    dnuke = "docker-nuke";
    
    # Docker Compose
    dc = "docker compose";
    dcu = "docker compose up -d";
    dcd = "docker compose down";
    dcl = "docker compose logs -f";
    dcr = "docker compose restart";
    
    # Kubernetes
    k = "kubectl";
    kx = "kubectx";
    kn = "kubens";
    kctx = "kube-ctx ctx";
    kns = "kube-ctx ns";
    
    # K9s
    k9 = "k9s";
    
    # Dive
    ddive = "dive";
  };
}
