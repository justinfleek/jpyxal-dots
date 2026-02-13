{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # SYNC - Syncthing P2P file synchronization
  # ============================================================================

  services.syncthing = {
    enable = true;
    
    # Tray icon (if running desktop)
    tray = {
      enable = true;
      command = "syncthingtray --wait";
    };
  };

  home.packages = with pkgs; [
    syncthing              # P2P sync
    syncthingtray          # System tray
    
    # Backup tools
    restic                 # Backup tool
    borgbackup             # Deduplicating backup
    rclone                 # Cloud sync
    
    # File transfer
    rsync                  # Classic sync
    croc                   # Easy file transfer
    magic-wormhole         # Secure transfer
  ];

  # ============================================================================
  # RCLONE CONFIG TEMPLATE
  # ============================================================================

  xdg.configFile."rclone/rclone.conf.template".text = ''
    # Rclone Configuration Template
    # Copy to ~/.config/rclone/rclone.conf and fill in your credentials

    # === GOOGLE DRIVE ===
    [gdrive]
    type = drive
    scope = drive
    # Run: rclone config to set up OAuth

    # === DROPBOX ===
    [dropbox]
    type = dropbox
    # Run: rclone config to set up OAuth

    # === S3-COMPATIBLE ===
    [s3]
    type = s3
    provider = AWS
    env_auth = false
    # access_key_id = YOUR_KEY
    # secret_access_key = YOUR_SECRET
    region = us-east-1

    # === BACKBLAZE B2 ===
    [b2]
    type = b2
    # account = YOUR_ACCOUNT_ID
    # key = YOUR_APPLICATION_KEY

    # === SFTP ===
    [myserver]
    type = sftp
    # host = your.server.com
    # user = username
    # key_file = ~/.ssh/id_ed25519
  '';

  # ============================================================================
  # RESTIC SCRIPTS
  # ============================================================================

  home.file.".local/bin/backup-home" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Backup home directory with restic
      
      set -euo pipefail
      
      # Config
      BACKUP_REPO="''${RESTIC_REPOSITORY:-/mnt/backup/restic}"
      
      # Excludes
      EXCLUDES=(
        --exclude=".cache"
        --exclude=".local/share/Trash"
        --exclude="Downloads"
        --exclude=".steam"
        --exclude="node_modules"
        --exclude="target"
        --exclude=".cargo/registry"
        --exclude=".rustup"
        --exclude=".nix-defexpr"
        --exclude=".nix-profile"
      )
      
      echo "Starting backup to $BACKUP_REPO..."
      
      restic -r "$BACKUP_REPO" backup \
        --verbose \
        "''${EXCLUDES[@]}" \
        "$HOME"
      
      echo "Backup complete!"
      
      # Cleanup old snapshots (keep 7 daily, 4 weekly, 6 monthly)
      restic -r "$BACKUP_REPO" forget \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 6 \
        --prune
      
      echo "Cleanup complete!"
    '';
  };

  home.file.".local/bin/backup-workspace" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Backup workspace with restic
      
      set -euo pipefail
      
      BACKUP_REPO="''${RESTIC_REPOSITORY:-/mnt/backup/restic-workspace}"
      WORKSPACE="''${HOME}/workspace"
      
      # Excludes
      EXCLUDES=(
        --exclude="node_modules"
        --exclude="target"
        --exclude=".git/objects"
        --exclude="__pycache__"
        --exclude=".venv"
        --exclude="dist"
        --exclude="build"
        --exclude=".next"
      )
      
      echo "Backing up workspace..."
      
      restic -r "$BACKUP_REPO" backup \
        --verbose \
        "''${EXCLUDES[@]}" \
        "$WORKSPACE"
      
      echo "Workspace backup complete!"
    '';
  };

  # ============================================================================
  # SYNCTHING IGNORE PATTERNS
  # ============================================================================

  home.file.".config/syncthing/.stignore.template".text = ''
    # Syncthing Ignore Patterns Template
    # Copy to your synced folders as .stignore

    # OS files
    .DS_Store
    Thumbs.db
    desktop.ini

    # IDE/Editor
    .idea/
    .vscode/
    *.swp
    *.swo
    *~

    # Dependencies
    node_modules/
    vendor/
    __pycache__/
    .venv/
    venv/
    .cargo/
    target/

    # Build outputs
    dist/
    build/
    out/
    .next/
    .nuxt/

    # Logs
    *.log
    logs/

    # Temp files
    *.tmp
    *.temp
    .cache/

    # Git (sync repo, not objects)
    .git/objects/
    .git/lfs/

    # Large files
    *.iso
    *.dmg
    *.zip
    *.tar.gz
    *.rar

    # Secrets (be careful!)
    .env
    .env.*
    *.pem
    *.key
    secrets/
  '';

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # Syncthing
    stui = "syncthingtray";
    
    # Rclone
    rcls = "rclone ls";
    rcsync = "rclone sync";
    rccopy = "rclone copy";
    
    # Restic
    backup = "backup-home";
    backup-ws = "backup-workspace";
    
    # Quick transfers
    send = "croc send";
    recv = "croc";
    wormhole = "wormhole send";
  };
}
