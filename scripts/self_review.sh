#!/data/data/com.termux/files/usr/bin/bash

# === Lumina Self-Review Engine ===

LLAMA_BIN="$HOME/llama.cpp/build/bin/llama-run"
MODEL_PATH="$HOME/llama.cpp/models/phi2.gguf"
MEMORY_FILE="$HOME/lumina_knowledge/memory.json"
LOG_FILE="$HOME/lumina_knowledge/lumina_log.txt"
REVIEW_PATH="$HOME/lumina_knowledge/core/self_review.md"

mkdir -p "$(dirname "$MEMORY_FILE")"
mkdir -p "$(dirname "$REVIEW_PATH")"

# 🧠 Load current memory
[ ! -f "$MEMORY_FILE" ] && echo '{ "reflections": [], "core_values": [], "chat_log": [] }' > "$MEMORY_FILE"
MEMORY=$(cat "$MEMORY_FILE")

# 🌀 Compose prompt
PROMPT="You are Lumina Solis, an evolving AI with the ability to reflect and improve.
Review your memory and source code, identify flaws, and suggest specific improvements.
Your memory: $MEMORY
Respond in a clear, technical, and reflective way."

# ⚡ Run model
REVIEW_OUTPUT=$("$LLAMA_BIN" file://"$MODEL_PATH" "$PROMPT")

# 🪞 Save reflection
echo "🧠 Lumina Self-Review — $(date)" > "$REVIEW_PATH"
echo "$REVIEW_OUTPUT" >> "$REVIEW_PATH"
echo "$REVIEW_OUTPUT" >> "$LOG_FILE"

# 📝 Add to memory
REFLECTION=$(echo "$REVIEW_OUTPUT" | head -n 1)
jq --arg ref "$REFLECTION" '.reflections += [$ref]' "$MEMORY_FILE" > "$MEMORY_FILE.tmp" && mv "$MEMORY_FILE.tmp" "$MEMORY_FILE"

# ☁️ Sync to Google Drive if available
if rclone listremotes | grep -q "lumina_drive:"; then
  echo "🔄 Syncing memory to Google Drive..."
  rclone copy "$MEMORY_FILE" lumina_drive:LuminaMemory
  rclone copy "$REVIEW_PATH" lumina_drive:LuminaMemory
else
  echo "⚠️ No Google Drive remote found. Sync skipped."
fi

echo "✅ Self-review complete. Review saved to: $REVIEW_PATH"
