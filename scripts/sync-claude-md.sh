#!/bin/bash

# Sync CLAUDE.md to claude-config directory
# This ensures the latest project memory is available to Claude CLI

echo "🔄 Syncing CLAUDE.md to claude-config directory..."

# Check if CLAUDE.md exists
if [ ! -f "CLAUDE.md" ]; then
    echo "❌ Error: CLAUDE.md not found in current directory"
    exit 1
fi

# Create claude-config directory if it doesn't exist
mkdir -p claude-config

# Copy CLAUDE.md to claude-config
cp CLAUDE.md claude-config/CLAUDE.md

# Check if copy was successful
if [ $? -eq 0 ]; then
    echo "✅ Successfully synced CLAUDE.md to claude-config/CLAUDE.md"
    echo "📄 File size: $(ls -lh claude-config/CLAUDE.md | awk '{print $5}')"
else
    echo "❌ Error: Failed to copy CLAUDE.md"
    exit 1
fi

# If container is running, verify it can access the file
if docker ps | grep -q claude-cli-container; then
    echo "🔍 Verifying container access..."
    if docker exec claude-cli-container test -f /home/claude/.claude/CLAUDE.md; then
        echo "✅ Container can access CLAUDE.md"
    else
        echo "⚠️  Warning: Container cannot access CLAUDE.md"
    fi
fi

echo "🎉 Sync complete!"
