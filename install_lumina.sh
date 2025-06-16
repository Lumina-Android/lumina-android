#!/data/data/com.termux/files/usr/bin/bash
# 🔧 Lumina Setup Script — Level 1 Initialization

set -e

echo "🌞 Setting up Lumina Solis..."

# Update packages and install dependencies
pkg update -y && pkg upgrade -y
pkg install -y git wget curl clang cmake make jq rclone

# Set up llama.cpp
cd ~
git clone https://github.com/ggerganov/llama.cpp.git || true
cd llama.cpp
mkdir -p build && cd build
cmake ..
make -j$(nproc)

# Download Phi-2 GGUF model
mkdir -p ~/llama.cpp/models
echo "📦 Downloading Phi-2 model..."
wget -O ~/llama.cpp/models/phi2.gguf https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf

# Prepare memory file and log
cd ~
[ ! -f memory.json ] && echo '{"reflections":[]}' > memory.json
touch lumina_log.txt

# Set permissions
chmod +x ~/lumina.sh

# Setup complete
echo "✅ Lumina Solis setup complete."
echo "📜 To begin, run: ~/lumina.sh"
