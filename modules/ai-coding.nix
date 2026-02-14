{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================================================
  # AI CODING TOOLS - Aider, Continue, Cody, coding assistants
  # ============================================================================

  home.packages = with pkgs; [
    # Aider - AI pair programming
    aider-chat

    # Python env consolidated in python.nix
  ];

  # ============================================================================
  # AIDER CONFIGURATION
  # ============================================================================

  xdg.configFile."aider/.aider.conf.yml".text = ''
    # Aider Configuration
    # https://aider.chat/docs/config.html

    # Model settings
    model: claude-sonnet-4-20250514
    # model: gpt-4-turbo-preview
    # model: ollama/codellama:7b

    # Editor integration
    auto-commits: false
    dirty-commits: false

    # Display
    dark-mode: true
    pretty: true
    stream: true
    show-diffs: true

    # Git
    git: true
    gitignore: true

    # Code style
    encoding: utf-8

    # Files
    auto-lint: true
    lint-cmd:
      python: ruff check --fix
      javascript: eslint --fix
      typescript: eslint --fix

    # Chat history
    restore-chat-history: true

    # Caching
    cache-prompts: true

    # Ignore patterns
    # ignore-patterns:
    #   - node_modules
    #   - .git
    #   - dist
    #   - build
  '';

  home.file.".local/bin/aider-start" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Start Aider with common configurations

      MODEL="''${AIDER_MODEL:-claude-sonnet-4-20250514}"

      # Check for API key
      if [ -z "$ANTHROPIC_API_KEY" ] && [ -z "$OPENAI_API_KEY" ]; then
        echo "Warning: No API key found."
        echo "Set ANTHROPIC_API_KEY or OPENAI_API_KEY"
        echo ""
        echo "For local models, use: aider --model ollama/codellama"
        echo ""
      fi

      echo "Starting Aider with $MODEL..."
      echo ""

      aider --model "$MODEL" "$@"
    '';
  };

  # ============================================================================
  # CONTINUE.DEV - VSCode/Cursor AI extension config
  # ============================================================================

  # Continue config for VS Code / Cursor
  xdg.configFile."continue/config.json".text = builtins.toJSON {
    models = [
      {
        title = "Claude Sonnet";
        provider = "anthropic";
        model = "claude-sonnet-4-20250514";
        apiKey = "\${ANTHROPIC_API_KEY}";
      }
      {
        title = "GPT-4 Turbo";
        provider = "openai";
        model = "gpt-4-turbo-preview";
        apiKey = "\${OPENAI_API_KEY}";
      }
      {
        title = "Ollama - CodeLlama";
        provider = "ollama";
        model = "codellama:7b";
      }
      {
        title = "Ollama - DeepSeek Coder";
        provider = "ollama";
        model = "deepseek-coder:6.7b";
      }
    ];

    tabAutocompleteModel = {
      title = "Ollama - DeepSeek Coder";
      provider = "ollama";
      model = "deepseek-coder:6.7b";
    };

    embeddingsProvider = {
      provider = "ollama";
      model = "nomic-embed-text";
    };

    customCommands = [
      {
        name = "test";
        prompt = "Write unit tests for the selected code. Use the project's testing framework.";
      }
      {
        name = "review";
        prompt = "Review the selected code for bugs, security issues, and improvements. Be specific and actionable.";
      }
      {
        name = "docs";
        prompt = "Write clear, comprehensive documentation for the selected code including purpose, parameters, return values, and examples.";
      }
      {
        name = "refactor";
        prompt = "Refactor the selected code to be more readable, maintainable, and efficient while preserving functionality.";
      }
      {
        name = "explain";
        prompt = "Explain what this code does in detail. Include the algorithm, data structures, and any important patterns used.";
      }
    ];

    contextProviders = [
      {
        name = "code";
        params = { };
      }
      {
        name = "docs";
        params = { };
      }
      {
        name = "diff";
        params = { };
      }
      {
        name = "terminal";
        params = { };
      }
      {
        name = "problems";
        params = { };
      }
      {
        name = "folder";
        params = { };
      }
      {
        name = "codebase";
        params = { };
      }
    ];

    slashCommands = [
      {
        name = "commit";
        description = "Generate a commit message for staged changes";
      }
      {
        name = "edit";
        description = "Edit selected code based on instructions";
      }
      {
        name = "comment";
        description = "Add comments to selected code";
      }
    ];

    allowAnonymousTelemetry = false;
  };

  # ============================================================================
  # CODY - Sourcegraph AI assistant
  # ============================================================================

  # Cody CLI config
  xdg.configFile."cody/config.json".text = builtins.toJSON {
    endpoint = "https://sourcegraph.com";
    # accessToken will be set via environment variable SRC_ACCESS_TOKEN
    telemetry = {
      enabled = false;
    };
    chat = {
      model = "anthropic/claude-sonnet-4-20250514";
    };
    autocomplete = {
      enabled = true;
      model = "anthropic/claude-instant-1.2";
    };
  };

  # ============================================================================
  # OPENCODE ENHANCED CONFIG
  # ============================================================================

  # Additional OpenCode config for AI coding
  xdg.configFile."opencode/coding-assistant.json".text = builtins.toJSON {
    name = "coding-assistant";
    description = "AI coding assistant mode";
    systemPrompt = ''
      You are an expert software engineer and AI coding assistant.

      Your capabilities:
      - Write clean, maintainable code following best practices
      - Debug and fix issues efficiently
      - Refactor code for better performance and readability
      - Write comprehensive tests
      - Document code clearly

      Guidelines:
      - Be concise but thorough
      - Explain your reasoning when helpful
      - Consider edge cases and error handling
      - Suggest improvements when you see them
      - Use the project's existing patterns and conventions
    '';
    model = "claude-sonnet-4-20250514";
    temperature = 0.3;
  };

  # ============================================================================
  # HELPER SCRIPTS
  # ============================================================================

  home.file.".local/bin/ai-review" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # AI code review for git diff

      DIFF=$(git diff --staged)

      if [ -z "$DIFF" ]; then
        DIFF=$(git diff)
      fi

      if [ -z "$DIFF" ]; then
        echo "No changes to review"
        exit 1
      fi

      echo "Reviewing changes..."
      echo ""

      # Use aider for review if available
      if command -v aider &> /dev/null; then
        echo "$DIFF" | aider --message "Review this diff for bugs, security issues, and improvements. Be specific and actionable." --no-auto-commits
      else
        # Fall back to direct API call
        echo "Aider not found. Install with: pip install aider-chat"
      fi
    '';
  };

  home.file.".local/bin/ai-commit" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Generate commit message with AI

      DIFF=$(git diff --staged)

      if [ -z "$DIFF" ]; then
        echo "No staged changes. Stage changes first with: git add <files>"
        exit 1
      fi

      echo "Generating commit message..."

      # Use opencode if available
      if command -v opencode &> /dev/null; then
        MSG=$(echo "$DIFF" | opencode --print "Generate a concise, conventional commit message for this diff. Just output the commit message, nothing else.")
        echo ""
        echo "Suggested commit message:"
        echo "$MSG"
        echo ""
        read -p "Use this message? (y/n/e for edit): " choice
        
        case "$choice" in
          y|Y)
            git commit -m "$MSG"
            ;;
          e|E)
            git commit -e -m "$MSG"
            ;;
          *)
            echo "Commit cancelled"
            ;;
        esac
      else
        echo "OpenCode not found"
      fi
    '';
  };

  home.file.".local/bin/ai-explain" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Explain code from file or stdin

      FILE="$1"

      if [ -n "$FILE" ] && [ -f "$FILE" ]; then
        CODE=$(cat "$FILE")
        echo "Explaining: $FILE"
      else
        echo "Paste code (Ctrl+D when done):"
        CODE=$(cat)
      fi

      echo ""
      echo "=== Explanation ==="
      echo ""

      if command -v aider &> /dev/null; then
        echo "$CODE" | aider --message "Explain this code in detail. Cover what it does, how it works, and any important patterns used." --no-auto-commits --yes
      else
        echo "Aider not found"
      fi
    '';
  };

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # Aider
    aid = "aider-start";
    aider-local = "aider --model ollama/codellama:7b";
    aider-claude = "aider --model claude-sonnet-4-20250514";
    aider-gpt = "aider --model gpt-4-turbo-preview";

    # Quick AI tasks
    review = "ai-review";
    aicommit = "ai-commit";
    explain = "ai-explain";

    # OpenCode (already aliased as 'oc' in shell.nix)
    ocode = "opencode";
  };
}
