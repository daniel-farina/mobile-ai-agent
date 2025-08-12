#!/bin/bash

# Claude Session Persistence Setup
echo "🔐 Setting up Claude session persistence..."

# Change to workspace directory
cd /home/claude/workspace

# Ensure Claude config directory exists and has proper permissions
mkdir -p /home/claude/.claude
chown -R claude:claude /home/claude/.claude
chmod 700 /home/claude/.claude

# Check if credentials exist
if [ -f "/home/claude/.claude/.credentials.json" ]; then
    echo "✅ Claude credentials found - sessions will persist"
    
    # Validate credentials format
    if jq -e '.claudeAiOauth' /home/claude/.claude/.credentials.json > /dev/null 2>&1; then
        echo "✅ Credentials format is valid"
        
        # Check if token is expired
        EXPIRES_AT=$(jq -r '.claudeAiOauth.expiresAt' /home/claude/.claude/.credentials.json 2>/dev/null)
        if [ "$EXPIRES_AT" != "null" ] && [ "$EXPIRES_AT" != "" ]; then
            CURRENT_TIME=$(date +%s)000
            if [ "$CURRENT_TIME" -lt "$EXPIRES_AT" ]; then
                echo "✅ Authentication token is valid"
            else
                echo "⚠️  Authentication token may be expired - you may need to login again"
            fi
        fi
    else
        echo "⚠️  Credentials format may be invalid"
    fi
else
    echo "ℹ️  No Claude credentials found - you'll need to login on first use"
fi

# Ensure settings.json exists
if [ ! -f "/home/claude/.claude/settings.json" ]; then
    echo "📝 Creating Claude settings file..."
    if [ -f "/home/claude/workspace/claude-settings.json" ]; then
        cp /home/claude/workspace/claude-settings.json /home/claude/.claude/settings.json
        echo "✅ Copied settings from workspace"
    else
        cat > /home/claude/.claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash",
      "Read", 
      "Write",
      "Edit",
      "Glob",
      "Grep",
      "WebFetch",
      "WebSearch"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "0"
  },
  "includeCoAuthoredBy": true,
  "cleanupPeriodDays": 30,
  "model": "claude-3-5-sonnet-20241022",
  "verbose": false,
  "theme": "dark",
  "autoUpdates": true,
  "preferredNotifChannel": "terminal_bell"
}
EOF
    chown claude:claude /home/claude/.claude/settings.json
    echo "✅ Claude settings file created"
    fi
fi

# Set proper permissions on all Claude config files
chown -R claude:claude /home/claude/.claude
chmod 700 /home/claude/.claude
find /home/claude/.claude -type f -name "*.json" -exec chmod 600 {} \;

echo "🎉 Claude session persistence setup complete!"
echo "📋 Session data location: /home/claude/.claude/"
echo "🔑 Credentials: /home/claude/.claude/.credentials.json"
echo "⚙️  Settings: /home/claude/.claude/settings.json"
