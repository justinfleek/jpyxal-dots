{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # OPENCODE WORKSPACE - Pre-configured for your multi-repo setup
  # ============================================================================

  # ============================================================================
  # OPENCODE AGENTS CONFIG
  # ============================================================================

  # Create workspace-level AGENTS.md that opencode reads
  home.file."workspace/.opencode/AGENTS.md".text = ''
    # Workspace Agents Configuration

    This workspace contains multiple interconnected repositories:

    ## Repositories

    ### sensenet (straylight-software/sensenet)
    Neural network and AI infrastructure

    ### nvidia-sdk (weyl-ai/nvidia-sdk)  
    NVIDIA SDK integrations and GPU computing

    ### nix-compile (straylight-software/nix-compile)
    Nix-based compilation and build infrastructure

    ### slide (straylight-software/slide)
    Slide presentation and visualization tools

    ### isospin-microvm (straylight-software/isospin-microvm)
    MicroVM infrastructure with isospin

    ### omega-agentic (omega-agentic/omega-agentic)
    Agentic AI systems and automation

    ## Development Stack

    - **Nix**: All projects use Nix flakes for reproducible builds
    - **PureScript/Halogen**: Frontend UI components
    - **Dhall**: Configuration language
    - **Lean 4**: Formal verification and theorem proving
    - **Tailscale**: Secure networking between services

    ## Working Across Repos

    When making changes that span multiple repos:
    1. Identify dependencies between repos
    2. Make changes in dependency order
    3. Test integration points
    4. Commit atomically where possible

    ## Build Commands

    Each repo typically has:
    ```bash
    nix develop      # Enter dev shell
    nix build        # Build project
    nix flake check  # Validate flake
    ```

    ## Testing

    Run tests with:
    ```bash
    just test        # If justfile exists
    nix flake check  # Nix-level checks
    ```
  '';

  # ============================================================================
  # OPENCODE SKILLS
  # ============================================================================

  home.file."workspace/.opencode/skill/workspace/SKILL.md".text = ''
    # Workspace Navigation Skill

    ## Quick Navigation

    | Alias | Directory |
    |-------|-----------|
    | sensenet | ~/workspace/sensenet |
    | nvidia | ~/workspace/nvidia-sdk |
    | nxc | ~/workspace/nix-compile |
    | slide | ~/workspace/slide |
    | isospin | ~/workspace/isospin-microvm |
    | omega | ~/workspace/omega-agentic |

    ## Cross-Repo Operations

    ### Sync All Repos
    ```bash
    workspace-sync
    ```

    ### Open Workspace in Tmux
    ```bash
    workspace-tmux
    ```

    ### Open OpenCode in Workspace
    ```bash
    workspace-opencode
    # or
    wso
    ```

    ## Stack-Specific Commands

    ### PureScript/Halogen
    ```bash
    spago build     # Build
    spago test      # Test
    spago run       # Run
    ```

    ### Dhall
    ```bash
    dhall           # REPL
    dhall-to-json   # Convert to JSON
    dhall-to-yaml   # Convert to YAML
    ```

    ### Lean 4
    ```bash
    lake build      # Build
    lake test       # Test
    ```

    ### Nix
    ```bash
    nix develop     # Enter dev shell
    nix build       # Build
    nix flake check # Validate
    ```
  '';

  home.file."workspace/.opencode/skill/purescript/SKILL.md".text = ''
    # PureScript/Halogen Skill

    ## Project Structure

    ```
    src/
    ├── Main.purs           # Entry point
    ├── Component/          # Halogen components
    │   ├── App.purs        # Root component
    │   └── ...
    ├── Data/               # Data types
    ├── Effect/             # Effects
    └── Util/               # Utilities
    test/
    └── Test/Main.purs      # Tests
    ```

    ## Common Patterns

    ### Halogen Component
    ```purescript
    module Component.MyComponent where

    import Prelude
    import Halogen as H
    import Halogen.HTML as HH
    import Halogen.HTML.Events as HE

    type State = { count :: Int }
    data Action = Increment | Decrement

    component :: forall q i o m. H.Component q i o m
    component = H.mkComponent
      { initialState: \_ -> { count: 0 }
      , render
      , eval: H.mkEval H.defaultEval { handleAction = handleAction }
      }

    render :: forall m. State -> H.ComponentHTML Action () m
    render state = HH.div_
      [ HH.button [ HE.onClick \_ -> Decrement ] [ HH.text "-" ]
      , HH.span_ [ HH.text $ show state.count ]
      , HH.button [ HE.onClick \_ -> Increment ] [ HH.text "+" ]
      ]

    handleAction :: forall o m. Action -> H.HalogenM State Action () o m Unit
    handleAction = case _ of
      Increment -> H.modify_ \s -> s { count = s.count + 1 }
      Decrement -> H.modify_ \s -> s { count = s.count - 1 }
    ```

    ## Build Commands

    ```bash
    spago build             # Build project
    spago test              # Run tests
    spago bundle-app        # Bundle for browser
    spago docs              # Generate docs
    purs-tidy format-in-place src/**/*.purs  # Format
    ```

    ## LSP

    PureScript Language Server provides:
    - Autocompletion
    - Type information
    - Go to definition
    - Diagnostics
  '';

  home.file."workspace/.opencode/skill/dhall/SKILL.md".text = ''
    # Dhall Skill

    ## Basics

    Dhall is a programmable configuration language.

    ### Types
    ```dhall
    -- Primitives
    let x : Natural = 42
    let s : Text = "hello"
    let b : Bool = True

    -- Records
    let person : { name : Text, age : Natural } = 
      { name = "Alice", age = 30 }

    -- Lists
    let nums : List Natural = [1, 2, 3]

    -- Optionals
    let maybe : Optional Text = Some "value"
    ```

    ### Functions
    ```dhall
    let double = \(n : Natural) -> n * 2

    let greet = \(name : Text) -> "Hello, " ++ name
    ```

    ### Imports
    ```dhall
    let Prelude = https://prelude.dhall-lang.org/v21.1.0/package.dhall

    let config = ./config.dhall
    ```

    ## Convert to Other Formats

    ```bash
    dhall-to-json <<< './config.dhall'
    dhall-to-yaml <<< './config.dhall'
    dhall-to-bash <<< './config.dhall'
    ```

    ## Type Checking

    ```bash
    dhall type <<< './config.dhall'
    dhall normalize <<< './config.dhall'
    ```

    ## LSP

    dhall-lsp-server provides IDE features in Neovim.
  '';

  home.file."workspace/.opencode/skill/lean4/SKILL.md".text = ''
    # Lean 4 Skill

    ## Project Structure

    ```
    MyProject/
    ├── lakefile.lean       # Build config
    ├── MyProject.lean      # Main library
    ├── MyProject/
    │   ├── Basic.lean
    │   └── Advanced.lean
    └── Main.lean           # Executable entry
    ```

    ## Basics

    ### Definitions
    ```lean
    def hello := "Hello, World!"

    def add (a b : Nat) : Nat := a + b

    def factorial : Nat → Nat
      | 0 => 1
      | n + 1 => (n + 1) * factorial n
    ```

    ### Theorems
    ```lean
    theorem add_comm (a b : Nat) : a + b = b + a := by
      induction a with
      | zero => simp
      | succ n ih => simp [Nat.succ_add, ih]
    ```

    ### Structures
    ```lean
    structure Point where
      x : Float
      y : Float
      deriving Repr

    def origin : Point := ⟨0.0, 0.0⟩
    ```

    ## Lake Commands

    ```bash
    lake init myproject     # Create new project
    lake build              # Build project
    lake test               # Run tests
    lake clean              # Clean build
    lake update             # Update dependencies
    ```

    ## Tactics

    Common tactics:
    - `simp` - Simplify
    - `rfl` - Reflexivity
    - `exact` - Exact match
    - `apply` - Apply lemma
    - `induction` - Induction
    - `cases` - Case analysis
    - `have` - Introduce hypothesis
    - `sorry` - Placeholder (incomplete proof)
  '';

  # ============================================================================
  # AUTO-START WORKSPACE
  # ============================================================================

  # Script to open workspace with everything ready
  home.file.".local/bin/start-workspace" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      WORKSPACE="$HOME/workspace"
      
      # Ensure workspace exists
      if [ ! -d "$WORKSPACE" ]; then
        echo "Running workspace setup..."
        workspace-setup
      fi
      
      # Sync repos
      echo "Syncing repos..."
      workspace-sync
      
      # Start tailscale if not connected
      if ! tailscale status &>/dev/null; then
        echo "Starting Tailscale..."
        sudo tailscale up
      fi
      
      # Open tmux workspace or attach
      if tmux has-session -t workspace 2>/dev/null; then
        tmux attach -t workspace
      else
        workspace-tmux
      fi
    '';
  };

  # ============================================================================
  # HYPRLAND AUTOSTART (optional)
  # ============================================================================

  # Add to hyprland exec-once to auto-setup workspace on login
  # exec-once = start-workspace
}
