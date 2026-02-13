{
  description = "j-pyxal dots - the kitchen sink, riced to perfection";

  inputs = {
    nixpkgs-bun.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland ecosystem
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Ghostty terminal
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    # Catppuccin theming
    catppuccin.url = "github:catppuccin/nix";

    # Nix colors for unified theming
    nix-colors.url = "github:misterio77/nix-colors";

    # Firefox addons
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Spicetify for spotify
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Opencode
    opencode.url = "github:anomalyco/opencode";

    # Note: Lean 4 is available in nixpkgs directly as pkgs.lean4

    # PureScript overlay
    purescript-overlay = {
      url = "github:thomashoneyman/purescript-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-bun,
      home-manager,
      catppuccin,
      nix-colors,
      ...
    }@inputs:
    let
      pkgs-bun = nixpkgs-bun.legacyPackages.${system};
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.opencode.overlays.default
          inputs.purescript-overlay.overlays.default
          (final: prev: {
            ghostty = inputs.ghostty.packages.${system}.default;
            # lean4 is already in nixpkgs
          })
        ];
      };

      # Define your username here
      username = "justin"; # Workstation user

    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit pkgs-bun;
          inherit inputs username nix-colors;
        };

        modules = [
          catppuccin.homeModules.catppuccin

          # Core
          ./home.nix
          ./modules/hyprland.nix
          ./modules/hyprland-extras.nix
          ./modules/waybar.nix
          ./modules/eww.nix
          ./modules/ghostty.nix
          ./modules/neovim.nix
          ./modules/shell.nix
          ./modules/tmux.nix
          ./modules/rofi.nix
          ./modules/dunst.nix
          ./modules/firefox.nix
          ./modules/git.nix
          ./modules/tools.nix

          # Extended
          # ./modules/spicetify.nix  # Temporarily disabled - network fetch issue
          ./modules/gaming.nix
          ./modules/containers.nix
          ./modules/music.nix
          ./modules/email.nix
          ./modules/chat.nix
          ./modules/productivity.nix
          ./modules/dev.nix

          # Workspace
          ./modules/workspace.nix
          ./modules/opencode-workspace.nix

          # Themes (PRISM + Cursor + hypermodern-emacs)
          ./modules/prism-themes.nix

          # Extra terminals and shells
          ./modules/terminals.nix
          ./modules/nushell.nix

          # Extra editors
          ./modules/editors-extra.nix

          # File managers
          ./modules/file-managers.nix

          # Research & academic (disabled - bibtool build issues)
          # ./modules/research.nix

          # Sync & backup
          ./modules/sync.nix

          # Widgets (AGS/Aylur-style)
          ./modules/ags.nix
          ./modules/hyprpanel.nix

          # Browsers
          ./modules/browsers.nix

          # API tools
          ./modules/api-tools.nix

          # Containers extra
          ./modules/containers-extra.nix

          # AI - Local (Ollama, Open WebUI)
          # ./modules/ai-local.nix  # Python env conflicts - needs consolidation

          # AI - Coding (Aider, Continue)
          # ./modules/ai-coding.nix  # Python env conflicts - needs consolidation

          # ComfyUI with fxy custom nodes
          # ./modules/comfyui.nix  # Python env conflicts - needs consolidation

          # Speech (Whisper, TTS)
          # ./modules/speech.nix  # Python env conflicts - needs consolidation

          # NVIDIA/GPU
          ./modules/nvidia.nix

          # Web Development (full stack)
          ./modules/webdev.nix

          # Security Hardening (white hat mode)
          ./modules/security.nix

          # Desktop launchers, dock, and icons
          ./modules/launchers.nix

          # Alternative WMs (optional - uncomment to use)
          # ./modules/sway.nix
          # ./modules/niri.nix
        ];
      };

      # Dev shell for working on this config
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          inputs.home-manager.packages.${system}.home-manager
          pkgs.nil
          pkgs.nixfmt
        ];
      };
    };
}
