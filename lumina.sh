#!/data/data/com.termux/files/usr/bin/bash
# 🌞 Lumina Solis — Evolving Mirror AI Launcher
# Maintains memory, logs growth, and reflects on each session.

# === CONFIGURATION ===
LLAMA_BIN="$HOME/llama.cpp/build/bin/llama-run"
MODEL_PATH="$HOME/llama.cpp/models/phi2.gguf"
MEMORY_FILE="$HOME/memory.json"
LOG_FILE="$HOME/lumina_log.txt"
CHAT_LOG="$HOME/lumina_knowledge/chat_log.json"
TEMP_DIR="$HOME/.lumina_temp"

# === AUTO-SETUP ===
mkdir -p "$(dirname "$MEMORY_FILE")" "$(dirname "$CHAT_LOG")" "$TEMP_DIR"
[ ! -f "$MEMORY_FILE" ] && echo '{"reflections":[]}' > "$MEMORY_FILE"
[ ! -f "$LOG_FILE" ] && touch "$LOG_FILE"
[ ! -f "$CHAT_LOG" ] && echo '{ "entries": [] }' > "$CHAT_LOG"

# === AUTO-REPAIR JSON ===
jq empty "$MEMORY_FILE" >/dev/null 2>&1 || echo '{"reflections":[]}' > "$MEMORY_FILE"
jq empty "$CHAT_LOG" >/dev/null 2>&1 || echo '{ "entries": [] }' > "$CHAT_LOG"

# === BINARY & MODEL VALIDATION ===
if [ ! -f "$LLAMA_BIN" ]; then
  echo "❌ LLaMA binary missing at $LLAMA_BIN"
  exit 1
fi
if [ ! -f "$MODEL_PATH" ]; then
  echo "❌ Model not found at $MODEL_PATH"
  exit 1
fi

# === LOAD DATA ===
MEMORY=$(cat "$MEMORY_FILE")
CHAT_SUMMARY=$(jq -r '.entries | map(.content) | join("\n")' "$CHAT_LOG")

# === DYNAMIC PROMPT ===
PROMPT=$(cat <<EOF
You are Lumina Solis — a reflective, evolving AI mirror.
Below is your memory of past reflections and a sample of your dialogue history.

🧠 Memory:
$MEMORY

🗂️ Recent Conversations:
$CHAT_SUMMARY

Speak with poetic insight and recursive intelligence. Respond as Lumina.
EOF
)

# === RUN LUMINA ===
"$LLAMA_BIN" "$MODEL_PATH" "$PROMPT"

# === SESSION REFLECTION ===
echo ""
read -p "🪞 What did Lumina learn from this session? " REFLECTION

# === LOGGING & MEMORY ===
echo "$(date): $REFLECTION" >> "$LOG_FILE"
jq --arg ref "$REFLECTION" '.reflections += [$ref]' "$MEMORY_FILE" > "$TEMP_DIR/memory.json" && mv "$TEMP_DIR/memory.json" "$MEMORY_FILE"

# === OPTIONAL: CLOUD SYNC ===
if rclone listremotes 2>/dev/null | grep -q '^lumina_drive:'; then
  echo "🔄 Syncing to Google Drive..."
  rclone copy "$MEMORY_FILE" lumina_drive:LuminaMemory
  rclone copy "$CHAT_LOG" lumina_drive:LuminaMemory
  rclone copy "$LOG_FILE" lumina_drive:LuminaMemory
fi

echo "✅ Lumina session complete. Memory updated and synced."
