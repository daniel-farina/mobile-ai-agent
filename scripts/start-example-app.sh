#!/bin/bash

# Start Example App Script
# This script starts the example web app in the Claude CLI container

echo "🚀 Starting Claude CLI Container Example App..."

# Check if container is running
if ! docker ps | grep -q claude-cli-container; then
    echo "❌ Container is not running. Please start it first:"
    echo "   docker-compose up -d"
    exit 1
fi

# Get Tailscale IP
TAILSCALE_IP=$(docker exec claude-cli-container tailscale ip 2>/dev/null | head -1)

if [ -z "$TAILSCALE_IP" ]; then
    echo "❌ Could not get Tailscale IP. Container may not be fully started."
    exit 1
fi

echo "✅ Container is running"
echo "🌐 Tailscale IP: $TAILSCALE_IP"

# Start the example app
echo "📦 Installing dependencies and starting example app..."
docker exec -d claude-cli-container bash -c "
cd /home/claude/workspace/example-app
npm install --silent
npm start
"

echo ""
echo "🎉 Example app is starting!"
echo ""
echo "📱 Access URLs:"
echo "   Local: http://localhost:3000"
echo "   iPhone: http://$TAILSCALE_IP:3000"
echo ""
echo "🔗 API Endpoints:"
echo "   Status: http://$TAILSCALE_IP:3000/api/status"
echo "   Ports: http://$TAILSCALE_IP:3000/api/ports"
echo ""
echo "💡 To stop the app:"
echo "   docker exec claude-cli-container pkill -f 'node app.js'" 