{
  description = "Hypermodern Home Manager - riced to perfection";

  inputs = {
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
    
    # Lean 4
    lean4 = {
      url = "github:leanprover/lean4";
    };
    
    # PureScript overlay
    purescript-overlay = {
      url = "github:thomashoneyman/purescript-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, catppuccin, nix-colors, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.opencode.overlays.default
          inputs.purescript-overlay.overlays.default
          (final: prev: {
            ghostty = inputs.ghostty.packages.${system}.default;
            lean4 = inputs.lean4.packages.${system}.default;
          })
        ];
      };
      
      # Define your username here
      username = "justin"; # CHANGE THIS TO YOUR USERNAME
      
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        
        extraSpecialArgs = {
          inherit inputs username nix-colors;
        };
        
        modules = [
          catppuccin.homeManagerModules.catppuccin
          
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
          ./modules/spicetify.nix
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
        ];
      };
      
      # Dev shell for working on this config
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          home-manager
          nil
          nixfmt-rfc-style
        ];
      };
    };
}
