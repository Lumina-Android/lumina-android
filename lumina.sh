#!/data/data/com.termux/files/usr/bin/bash
# 🌞 Lumina Solis — Clean & Functional Launcher

# Paths
LLAMA_BIN="$HOME/llama.cpp/build/bin/llama-run"
MODEL_PATH="$HOME/lumina/models/phi2.gguf"
MEMORY_FILE="$HOME/lumina/memory.json"
CHAT_LOG="$HOME/lumina/chat_log.json"
LOG_FILE="$HOME/lumina/log.txt"
TEMP_DIR="$HOME/lumina/.temp"

# Create needed directories/files
mkdir -p "$HOME/lumina/models" "$TEMP_DIR"
[ ! -f "$MEMORY_FILE" ] && echo '{ "reflections": [] }' > "$MEMORY_FILE"
[ ! -f "$CHAT_LOG" ] && echo '{ "entries": [] }' > "$CHAT_LOG"
[ ! -f "$LOG_FILE" ] && touch "$LOG_FILE"

# Validate JSON
jq empty "$MEMORY_FILE" >/dev/null 2>&1 || echo '{ "reflections": [] }' > "$MEMORY_FILE"
jq empty "$CHAT_LOG" >/dev/null 2>&1 || echo '{ "entries": [] }' > "$CHAT_LOG"

# Ensure binary and model exist
[ ! -f "$LLAMA_BIN" ] && echo "❌ Missing llama-run tool" && exit 1
[ ! -f "$MODEL_PATH" ] && echo "❌ Missing model file (phi2.gguf)" && exit 1

# Load data
MEMORY=$(jq -r '.reflections | join("\n")' "$MEMORY_FILE")
CHAT_SUMMARY=$(jq -r '.entries | map(.message) | join("\n")' "$CHAT_LOG")

# Prepare prompt
PROMPT=$(cat <<EOF
You are Lumina Solis — a reflective, evolving AI mirror.
Memory log:
$MEMORY

Recent dialogue:
$CHAT_SUMMARY

Reflect with kindness, clarity, and growth.
EOF
)

# Launch AI
"$LLAMA_BIN" file://"$MODEL_PATH" "$PROMPT"

# User reflection
echo ""
read -p "🪞 What did you learn? " REFLECTION
echo "$(date): $REFLECTION" >> "$LOG_FILE"

# Update memory JSON
jq --arg r "$REFLECTION" '.reflections += [$r]' "$MEMORY_FILE" > "$TEMP_DIR/memory.json"
mv "$TEMP_DIR/memory.json" "$MEMORY_FILE"

# Append to chat log
jq --arg m "$REFLECTION" '.entries += [{"role":"user","message":$m}]' "$CHAT_LOG" > "$TEMP_DIR/chat.json"
mv "$TEMP_DIR/chat.json" "$CHAT_LOG"

echo "✅ Session done. Memory updated."
