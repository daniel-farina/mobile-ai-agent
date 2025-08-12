#!/bin/bash

# PM2 Startup Script for Mobile AI Agent
echo "🚀 Starting PM2 and Welcome App..."

# Change to workspace directory
cd /home/claude/workspace

# Install dependencies for welcome app if needed
if [ -d "./projects/welcome-app" ]; then
    echo "📦 Installing welcome app dependencies..."
    cd ./projects/welcome-app
    npm install
    cd /home/claude/workspace
fi

# Setup PM2 startup script (for system boot)
echo "⚙️  Setting up PM2 startup..."
pm2 startup

# Start PM2 processes
echo "🔄 Starting PM2 processes..."
if [ -f "ecosystem.config.js" ]; then
    pm2 start ecosystem.config.js --env development
    echo "✅ PM2 processes started successfully"
    pm2 list
else
    echo "⚠️  ecosystem.config.js not found, starting welcome app manually..."
    cd ./projects/welcome-app
    pm2 start server.js --name welcome-app
    cd /home/claude/workspace
fi

# Save PM2 configuration
pm2 save

echo "🎉 PM2 startup complete!"
echo "📊 Current PM2 status:"
pm2 list
