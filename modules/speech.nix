{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================================================
  # SPEECH - Whisper STT, TTS, voice tools
  # ============================================================================

  home.packages = with pkgs; [
    # Speech-to-Text
    whisper-cpp # Whisper C++ port (faster)

    # Text-to-Speech
    espeak-ng # Open source TTS
    piper-tts # Fast neural TTS
    mimic # Festival-based TTS (mycroft)

    # Audio processing
    sox # Sound processing
    # ffmpeg             # Provided by nvidia.nix (ffmpeg-full with NVENC)
    pulseaudio # For parecord

    # Voice recording
    audacity # Audio editor

    # Python env consolidated in python.nix
  ];

  # ============================================================================
  # WHISPER SCRIPTS
  # ============================================================================

  home.file.".local/bin/whisper-record" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Record audio and transcribe with Whisper

      OUTPUT_DIR="''${WHISPER_OUTPUT:-$HOME/transcriptions}"
      mkdir -p "$OUTPUT_DIR"

      TIMESTAMP=$(date +%Y%m%d_%H%M%S)
      AUDIO_FILE="$OUTPUT_DIR/recording_$TIMESTAMP.wav"
      TRANSCRIPT_FILE="$OUTPUT_DIR/transcript_$TIMESTAMP.txt"

      echo "=== Whisper Voice Recording ==="
      echo ""
      echo "Press Ctrl+C to stop recording..."
      echo ""

      # Record audio
      ffmpeg -f pulse -i default -ar 16000 -ac 1 "$AUDIO_FILE" 2>/dev/null

      echo ""
      echo "Recording saved: $AUDIO_FILE"
      echo ""
      echo "Transcribing..."

      # Transcribe with whisper
      whisper "$AUDIO_FILE" --model small --language en --output_format txt --output_dir "$OUTPUT_DIR"

      # Rename output
      mv "$OUTPUT_DIR/recording_$TIMESTAMP.txt" "$TRANSCRIPT_FILE" 2>/dev/null || true

      echo ""
      echo "=== Transcript ==="
      cat "$TRANSCRIPT_FILE" 2>/dev/null || cat "$OUTPUT_DIR/recording_$TIMESTAMP.txt"
      echo ""
      echo "Saved to: $TRANSCRIPT_FILE"
    '';
  };

  home.file.".local/bin/whisper-file" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Transcribe audio/video file with Whisper

      FILE="$1"
      MODEL="''${2:-small}"
      LANG="''${3:-en}"

      if [ -z "$FILE" ]; then
        echo "Usage: whisper-file <audio/video file> [model] [language]"
        echo ""
        echo "Models: tiny, base, small, medium, large"
        echo "Languages: en, es, fr, de, ja, zh, etc."
        echo ""
        echo "Examples:"
        echo "  whisper-file podcast.mp3"
        echo "  whisper-file video.mp4 medium"
        echo "  whisper-file interview.wav large es"
        exit 1
      fi

      if [ ! -f "$FILE" ]; then
        echo "File not found: $FILE"
        exit 1
      fi

      OUTPUT_DIR="$(dirname "$FILE")"
      BASENAME="$(basename "$FILE" | sed 's/\.[^.]*$//')"

      echo "Transcribing: $FILE"
      echo "Model: $MODEL"
      echo "Language: $LANG"
      echo ""

      whisper "$FILE" \
        --model "$MODEL" \
        --language "$LANG" \
        --output_format all \
        --output_dir "$OUTPUT_DIR"

      echo ""
      echo "=== Output Files ==="
      ls -la "$OUTPUT_DIR/$BASENAME".*
    '';
  };

  home.file.".local/bin/whisper-live" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Live transcription with whisper.cpp (faster)

      MODEL_PATH="$HOME/.local/share/whisper-models/ggml-base.en.bin"

      # Download model if not exists
      if [ ! -f "$MODEL_PATH" ]; then
        echo "Downloading whisper model..."
        mkdir -p "$(dirname "$MODEL_PATH")"
        curl -L "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin" \
          -o "$MODEL_PATH"
      fi

      echo "=== Live Transcription ==="
      echo "Speak into your microphone..."
      echo "Press Ctrl+C to stop"
      echo ""

      # Use whisper-cpp stream mode
      whisper-cpp --model "$MODEL_PATH" --stream --step 3000 --length 10000
    '';
  };

  # ============================================================================
  # TEXT-TO-SPEECH SCRIPTS
  # ============================================================================

  home.file.".local/bin/tts-speak" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Text-to-speech with piper or espeak

      TEXT="$*"

      if [ -z "$TEXT" ]; then
        echo "Usage: tts-speak <text>"
        echo "Or: echo 'text' | tts-speak"
        read -r TEXT
      fi

      # Try piper first (better quality)
      if command -v piper &> /dev/null; then
        echo "$TEXT" | piper --output-raw | aplay -r 22050 -f S16_LE -t raw - 2>/dev/null
      # Fall back to espeak
      elif command -v espeak-ng &> /dev/null; then
        espeak-ng "$TEXT"
      else
        echo "No TTS engine found"
        exit 1
      fi
    '';
  };

  home.file.".local/bin/tts-file" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Convert text file to speech audio

      INPUT="$1"
      OUTPUT="''${2:-output.wav}"

      if [ -z "$INPUT" ]; then
        echo "Usage: tts-file <input.txt> [output.wav]"
        exit 1
      fi

      if [ ! -f "$INPUT" ]; then
        echo "File not found: $INPUT"
        exit 1
      fi

      echo "Converting: $INPUT -> $OUTPUT"

      if command -v piper &> /dev/null; then
        cat "$INPUT" | piper --output_file "$OUTPUT"
      else
        espeak-ng -f "$INPUT" -w "$OUTPUT"
      fi

      echo "Done: $OUTPUT"
    '';
  };

  # ============================================================================
  # PIPER TTS SETUP
  # ============================================================================

  home.file.".local/bin/piper-setup" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Download Piper TTS voices

      VOICE_DIR="$HOME/.local/share/piper-voices"
      mkdir -p "$VOICE_DIR"

      echo "=== Piper TTS Voice Setup ==="
      echo ""

      # Download a good quality English voice
      VOICE="en_US-lessac-medium"
      VOICE_URL="https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium"

      if [ ! -f "$VOICE_DIR/$VOICE.onnx" ]; then
        echo "Downloading voice: $VOICE..."
        curl -L "$VOICE_URL/en_US-lessac-medium.onnx" -o "$VOICE_DIR/$VOICE.onnx"
        curl -L "$VOICE_URL/en_US-lessac-medium.onnx.json" -o "$VOICE_DIR/$VOICE.onnx.json"
      else
        echo "Voice already downloaded: $VOICE"
      fi

      echo ""
      echo "Available voices:"
      ls "$VOICE_DIR"/*.onnx 2>/dev/null | xargs -I{} basename {} .onnx
      echo ""
      echo "More voices: https://github.com/rhasspy/piper#voices"
    '';
  };

  # ============================================================================
  # VOICE ASSISTANT INTEGRATION
  # ============================================================================

  home.file.".local/bin/voice-assistant" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Voice assistant: Speak -> Whisper -> LLM -> TTS

      echo "=== Voice Assistant ==="
      echo "Speak your question, then press Enter to stop recording..."
      echo ""

      # Record
      TMPFILE=$(mktemp --suffix=.wav)
      ffmpeg -f pulse -i default -ar 16000 -ac 1 -t 30 "$TMPFILE" 2>/dev/null &
      FFMPEG_PID=$!

      read -r # Wait for Enter
      kill $FFMPEG_PID 2>/dev/null

      echo ""
      echo "Transcribing..."

      # Transcribe
      QUESTION=$(whisper "$TMPFILE" --model tiny --language en --output_format txt 2>/dev/null | tail -1)
      rm "$TMPFILE"

      if [ -z "$QUESTION" ]; then
        echo "Could not transcribe audio"
        exit 1
      fi

      echo "You asked: $QUESTION"
      echo ""
      echo "Thinking..."

      # Get response from Ollama
      RESPONSE=$(ollama run llama3.2 "$QUESTION" 2>/dev/null)

      if [ -z "$RESPONSE" ]; then
        echo "Could not get response"
        exit 1
      fi

      echo ""
      echo "Response: $RESPONSE"
      echo ""
      echo "Speaking..."

      # Speak response
      tts-speak "$RESPONSE"
    '';
  };

  # ============================================================================
  # DICTATION MODE
  # ============================================================================

  home.file.".local/bin/dictate" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Dictation mode - speak and type
      # Copies transcribed text to clipboard

      echo "=== Dictation Mode ==="
      echo "Speak now... Press Ctrl+C to stop"
      echo ""

      TMPFILE=$(mktemp --suffix=.wav)

      # Record until Ctrl+C
      trap "echo; echo 'Processing...'" INT
      ffmpeg -f pulse -i default -ar 16000 -ac 1 "$TMPFILE" 2>/dev/null

      # Transcribe
      TEXT=$(whisper "$TMPFILE" --model tiny --language en --output_format txt 2>/dev/null | tail -1)
      rm "$TMPFILE"

      if [ -n "$TEXT" ]; then
        echo ""
        echo "Transcribed: $TEXT"
        echo ""
        
        # Copy to clipboard
        echo -n "$TEXT" | wl-copy
        echo "(Copied to clipboard)"
      else
        echo "No speech detected"
      fi
    '';
  };

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================

  programs.bash.shellAliases = {
    # Whisper
    whisper-rec = "whisper-record";
    transcribe = "whisper-file";
    stt = "whisper-live";

    # TTS
    speak = "tts-speak";
    tts = "tts-speak";

    # Voice
    va = "voice-assistant";
    dict = "dictate";
  };
}
