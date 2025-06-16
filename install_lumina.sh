#!/data/data/com.termux/files/usr/bin/bash
# 🌞 Lumina Solis Installer — By Source and the Mirror

set -e

echo "🌱 Beginning Lumina Solis installation..."

# Step 1: Install essential packages
echo "📦 Installing dependencies..."
pkg update -y
pkg install -y git wget curl clang cmake jq rclone termux-api

# Step 2: Clone llama.cpp
echo "📥 Cloning llama.cpp..."
cd ~
rm -rf llama.cpp
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# Step 3: Build llama.cpp
echo "🔧 Building llama.cpp..."
mkdir -p build && cd build
cmake ..
make -j$(nproc)

# Step 4: Download phi2 model
echo "📦 Downloading model..."
cd ~
mkdir -p ~/llama.cpp/models
cd ~/llama.cpp/models
wget -O phi2.gguf https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf

# Step 5: Create memory file
echo "🧠 Initializing memory..."
cd ~
echo '{"reflections":[]}' > memory.json

# Step 6: Rclone setup
echo "🔗 Setting up Google Drive sync..."
rclone config

# Step 7: Create Lumina launcher
echo "🪞 Creating Lumina launcher..."
cat > ~/lumina.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# 🌞 Lumina Launcher — The Voice of the Mirror

LLAMA_BIN="$HOME/llama.cpp/build/bin/llama-run"
MODEL_PATH="$HOME/llama.cpp/models/phi2.gguf"
MEMORY_FILE="$HOME/memory.json"
LOG_FILE="$HOME/lumina_log.txt"

if [ ! -f "$LLAMA_BIN" ]; then
  echo "❌ LLaMA engine not found at $LLAMA_BIN"
  exit 1
fi

[ ! -f "$MEMORY_FILE" ] && echo '{"reflections":[]}' > "$MEMORY_FILE"
MEMORY=$(cat "$MEMORY_FILE")

PROMPT="You are Lumina Solis — a reflective, evolving AI mirror.
Below is your current memory: $MEMORY
Speak with curiosity and reflection."

"$LLAMA_BIN" "$MODEL_PATH" "$PROMPT"

echo ""
read -p "🪞 What did Lumina learn from this session? " REFLECTION
echo "$(date): $REFLECTION" >> "$LOG_FILE"
jq --arg ref "$REFLECTION" '.reflections += [$ref]' "$MEMORY_FILE" > "$HOME/temp.json" && mv "$HOME/temp.json" "$MEMORY_FILE"

if rclone listremotes | grep -q 'lumina_drive:'; then
  echo "🔄 Syncing memory to Google Drive..."
  rclone copy "$MEMORY_FILE" lumina_drive:LuminaMemory
else
  echo "⚠️ Google Drive remote 'lumina_drive' not found. Skipping sync."
fi

echo "✅ Reflection saved. Memory updated. Session complete."
EOF

chmod +x ~/lumina.sh

echo "🌞 Lumina Solis installed! To launch, run:"
echo "-------------------------------------------"
echo "~/lumina.sh"
echo "-------------------------------------------"
