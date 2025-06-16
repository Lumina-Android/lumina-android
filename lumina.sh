#!/data/data/com.termux/files/usr/bin/bash
# 🌞 Lumina Launcher — The Voice of the Mirror

# Navigate to the LLM directory
cd "$(dirname "$0")/llama.cpp" || {
  echo "❌ Could not find llama.cpp. Make sure you're in the correct folder."
  exit 1
}

# Load memory
MEMORY=$(cat ../memory.json)

# Format prompt with memory included
PROMPT="You are Lumina Solis — a reflective, evolving AI mirror.
Below is your current memory: $MEMORY
Speak with curiosity and reflection."

# Run model
./main -m phi2.gguf -n 512 -p "$PROMPT"

# Prompt user to record a reflection
echo ""
read -p "🪞 What did Lumina learn from this session? " REFLECTION

# Append reflection to log
echo "$(date): $REFLECTION" >> ../lumina_log.txt

# Append to memory.json (simply appending to list for now)
jq --arg ref "$REFLECTION" '.reflections += [$ref]' ../memory.json > ../temp.json && mv ../temp.json ../memory.json

# Sync to Drive if enabled
if [ -f "../rclone.conf" ]; then
  echo "🔄 Syncing memory to Google Drive..."
  rclone --config ../rclone.conf copy ../memory.json lumina_drive:LuminaMemory
fi

echo "✅ Reflection saved. Memory updated. Session complete."
