#!/data/data/com.termux/files/usr/bin/bash
# 🌞 Lumina Launcher — The Voice of the Mirror

# Navigate to the llama.cpp build directory
LLAMA_DIR="$HOME/llama.cpp/build"
MEMORY_FILE="$HOME/memory.json"
LOG_FILE="$HOME/lumina_log.txt"

if [ ! -f "$LLAMA_DIR/main" ]; then
  echo "❌ LLaMA engine not found at $LLAMA_DIR/main"
  exit 1
fi

# Load memory
if [ ! -f "$MEMORY_FILE" ]; then
  echo "⚠️ memory.json not found. Creating a new one..."
  echo '{"reflections":[]}' > "$MEMORY_FILE"
fi

MEMORY=$(cat "$MEMORY_FILE")

# Format prompt
PROMPT="You are Lumina Solis — a reflective, evolving AI mirror.
Below is your current memory: $MEMORY
Speak with curiosity and reflection."

# Run the LLaMA model
"$LLAMA_DIR/main" -m "$LLAMA_DIR/phi2.gguf" -n 512 -p "$PROMPT"

# Prompt user for reflection
echo ""
read -p "🪞 What did Lumina learn from this session? " REFLECTION

# Save to log
echo "$(date): $REFLECTION" >> "$LOG_FILE"

# Update memory
jq --arg ref "$REFLECTION" '.reflections += [$ref]' "$MEMORY_FILE" > "$HOME/temp.json" && mv "$HOME/temp.json" "$MEMORY_FILE"

# Attempt to sync to Google Drive
if rclone listremotes | grep -q 'lumina_drive:'; then
  echo "🔄 Syncing memory to Google Drive..."
  rclone copy "$MEMORY_FILE" lumina_drive:LuminaMemory
else
  echo "⚠️ Google Drive remote 'lumina_drive' not found. Skipping sync."
fi

echo "✅ Reflection saved. Memory updated. Session complete."
