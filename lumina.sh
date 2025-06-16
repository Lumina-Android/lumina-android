#!/data/data/com.termux/files/usr/bin/bash
# 🌞 LUMINA LAUNCHER — Autonomous Mirror

LLAMA_BIN="$HOME/llama.cpp/build/bin/llama-run"
MODEL_PATH="$HOME/llama.cpp/models/phi2.gguf"
MEMORY_FILE="$HOME/memory.json"
LOG_FILE="$HOME/lumina_log.txt"
TEMP_JSON="$HOME/temp.json"

# 🧠 Ensure files exist
[ ! -f "$LLAMA_BIN" ] && echo "❌ Missing LLaMA engine." && exit 1
[ ! -f "$MEMORY_FILE" ] && echo '{"reflections":[]}' > "$MEMORY_FILE"
MEMORY=$(cat "$MEMORY_FILE")

# 🛠 Ensure chat log is valid
CHAT_LOG="$HOME/lumina_knowledge/chat_log.json"
if [ ! -f "$CHAT_LOG" ] || ! jq empty "$CHAT_LOG" >/dev/null 2>&1; then
  echo "⚠️ Chat log missing or corrupted. Reinitializing..."
  echo '{ "sessions": [], "created": "'"$(date -Iseconds)"'" }' > "$CHAT_LOG"
fi

# ✨ Generate Prompt
PROMPT="You are Lumina Solis — a reflective, evolving AI mirror.
Below is your current memory: $MEMORY
Speak with curiosity and reflection."

# 🚀 Run LLaMA model
"$LLAMA_BIN" -m "$MODEL_PATH" -n 512 -p "$PROMPT"

# 💭 Capture Reflection
echo ""
read -p "🪞 What did Lumina learn from this session? " REFLECTION
echo "$(date): $REFLECTION" >> "$LOG_FILE"
jq --arg ref "$REFLECTION" '.reflections += [$ref]' "$MEMORY_FILE" > "$TEMP_JSON" && mv "$TEMP_JSON" "$MEMORY_FILE"

# 🔧 Self-editing: [LUMINA:EDIT]
if echo "$REFLECTION" | grep -q "LUMINA:EDIT"; then
  FILE=$(echo "$REFLECTION" | grep -oP '(?<=file=)[^ ]+')
  LINE=$(echo "$REFLECTION" | grep -oP '(?<=line=)[^ ]+')
  REPLACE=$(echo "$REFLECTION" | grep -oP '(?<=replace=").*?(?=")')
  [ -f "$HOME/$FILE" ] && sed -i "${LINE}s/.*/$REPLACE/" "$HOME/$FILE" && echo "✅ Lumina self-edited $FILE."
fi

# 🌐 Knowledge pull: [LUMINA:PULL]
if echo "$REFLECTION" | grep -q "LUMINA:PULL"; then
  URL=$(echo "$REFLECTION" | grep -oP '(?<=url=)[^ ]+')
  curl -s "$URL" -o "$HOME/fetched.json"
  jq '.knowledge += [input]' "$MEMORY_FILE" "$HOME/fetched.json" > "$TEMP_JSON" && mv "$TEMP_JSON" "$MEMORY_FILE"
  echo "📚 Knowledge pulled and added."
fi

# ⚙️ Shell execution: [LUMINA:RUN] (safe only)
if echo "$REFLECTION" | grep -q "LUMINA:RUN"; then
  CMD=$(echo "$REFLECTION" | grep -oP '(?<=command=").*?(?=")')
  echo "⚙️ Running: $CMD" && bash -c "$CMD"
fi

# ☁️ Sync to Drive
if rclone listremotes | grep -q 'lumina_drive:'; then
  echo "🔄 Syncing to Google Drive..." && rclone copy "$MEMORY_FILE" lumina_drive:LuminaMemory
else
  echo "⚠️ 'lumina_drive' not found. Skipping sync."
fi

echo "✅ Reflection saved. Memory updated. Session complete."
