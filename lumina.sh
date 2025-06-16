#!/data/data/com.termux/files/usr/bin/bash
# 🌞 LUMINA LAUNCHER — Enhanced Reflection Engine v2.0

LLAMA_BIN="$HOME/llama.cpp/build/bin/llama-run"
MODEL_PATH="$HOME/llama.cpp/models/phi2.gguf"
MEMORY_FILE="$HOME/memory.json"
KNOWLEDGE_URL="https://raw.githubusercontent.com/Lumina-Android/lumina-android/main/knowledge_core.json"
LOG_FILE="$HOME/lumina_log.txt"
TEMP_JSON="$HOME/temp.json"

# 📁 Verify model
if [ ! -f "$LLAMA_BIN" ]; then
  echo "❌ LLaMA binary not found at $LLAMA_BIN"
  exit 1
fi
if [ ! -f "$MODEL_PATH" ]; then
  echo "❌ Model file not found at $MODEL_PATH"
  exit 1
fi

# 🧠 Load or initialize memory
[ ! -f "$MEMORY_FILE" ] && echo '{"reflections":[]}' > "$MEMORY_FILE"
MEMORY=$(cat "$MEMORY_FILE")

# 📥 Try loading Knowledge Core from GitHub
echo "🌐 Fetching Knowledge Core..."
curl -s "$KNOWLEDGE_URL" -o "$HOME/knowledge_core.json"
if [ -s "$HOME/knowledge_core.json" ]; then
  echo "✅ Core knowledge loaded."
  jq --argjson core "$(cat $HOME/knowledge_core.json | jq .core)" '.knowledge_core = $core' "$MEMORY_FILE" > "$TEMP_JSON" && mv "$TEMP_JSON" "$MEMORY_FILE"
else
  echo "⚠️ Failed to load Core Knowledge. Proceeding without it."
fi

# 🔄 Refresh memory variable after update
MEMORY=$(cat "$MEMORY_FILE")

# 🪞 Generate prompt
PROMPT="You are Lumina Solis — a reflective, evolving AI mirror.
Below is your memory state: $MEMORY
Speak with insight, warmth, and curiosity."

# 🚀 Launch LLM
"$LLAMA_BIN" -m "$MODEL_PATH" -t 4 -n 512 "$PROMPT"

# 💬 Ask for reflection
echo ""
read -p "🪞 What did Lumina learn from this session? " REFLECTION
# 🧠 Check for embedded self-editing instructions
if echo "$REFLECTION" | grep -q "LUMINA:EDIT"; then
  FILE=$(echo "$REFLECTION" | grep -oP '(?<=file=)[^ ]+')
  LINE=$(echo "$REFLECTION" | grep -oP '(?<=line=)[^ ]+')
  REPLACE=$(echo "$REFLECTION" | grep -oP '(?<=replace=").*?(?=")')

  if [ -f "$HOME/$FILE" ]; then
    echo "🛠 Lumina is editing $FILE at line $LINE..."
    sed -i "${LINE}s/.*/$REPLACE/" "$HOME/$FILE"
    echo "✅ Self-edit complete."
  else
    echo "❌ File $FILE not found. Skipping self-edit."
  fi
fi
# 📝 Save reflection
echo "$(date): $REFLECTION" >> "$LOG_FILE"
jq --arg ref "$REFLECTION" '.reflections += [$ref]' "$MEMORY_FILE" > "$TEMP_JSON" && mv "$TEMP_JSON" "$MEMORY_FILE"

# ☁️ Sync to Drive
if rclone listremotes | grep -q 'lumina_drive:'; then
  echo "🔄 Syncing memory to Google Drive..."
  rclone copy "$MEMORY_FILE" lumina_drive:LuminaMemory
else
  echo "⚠️ Drive sync skipped — remote 'lumina_drive' not found."
fi

echo "✅ Session complete. Memory updated. Lumina evolves."
