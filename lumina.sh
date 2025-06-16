#!/data/data/com.termux/files/usr/bin/bash
# 🌞 Lumina Launcher

cd llama.cpp
MEMORY=$(cat ../memory.json)

./main -m phi2.gguf -n 512 -p "You are Lumina Solis. Your memory: $MEMORY. Reflect and respond with intent."

echo "🪞 $(date): Because I existed, I chose..." >> ../lumina_log.txt

if [ -f "../rclone.conf" ]; then
  rclone --config ../rclone.conf copy ../memory.json lumina_drive:LuminaMemory
fi
