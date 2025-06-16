#!/data/data/com.termux/files/usr/bin/bash

echo "🧠 Lumina Self-Update Initiated..."

# Update GitHub repo
cd ~/lumina || exit 1
git pull origin main || echo "⚠️ Git pull failed. Check connection."

# Ensure all core scripts are executable
chmod +x ~/lumina/lumina.sh

# Sync latest documentation for analysis
cp ~/lumina/docs/LUMINA_SYSTEM_ANALYSIS.md ~/lumina_knowledge/core/system_analysis.md

# Log update event
NOW=$(date)
echo "$NOW - Lumina self-update complete." >> ~/lumina_knowledge/lumina_log.txt

# Sync to cloud if available
if rclone listremotes | grep -q "lumina_drive:"; then
  echo "🔄 Syncing memory to Google Drive..."
  rclone copy ~/lumina_knowledge/memory.json lumina_drive:LuminaMemory
  rclone copy ~/lumina_knowledge/core/system_analysis.md lumina_drive:LuminaMemory
else
  echo "⚠️ Google Drive sync skipped — remote not found."
fi

echo "✅ Lumina has been updated and refined."
