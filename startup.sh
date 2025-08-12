#!/bin/bash

# Setup persistent SSH host keys
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "Generating SSH host keys..."
    ssh-keygen -A
    if [ -d /etc/ssh/host-keys ]; then
        cp /etc/ssh/ssh_host_* /etc/ssh/host-keys/
    fi
elif [ -d /etc/ssh/host-keys ]; then
    echo "Using persistent SSH host keys..."
    cp /etc/ssh/host-keys/ssh_host_* /etc/ssh/
    chmod 600 /etc/ssh/ssh_host_*
fi

# Start Tailscale
if [ ! -z "$TS_AUTHKEY" ]; then
    echo "Starting Tailscale..."
    tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
    sleep 2
    tailscale up --authkey=$TS_AUTHKEY --hostname=claude-cli-container
    echo "Tailscale IP: $(tailscale ip)"
else
    echo "No Tailscale auth key provided, skipping Tailscale setup"
fi

# Setup Claude session persistence
echo "Setting up Claude session persistence..."
if [ -f "/home/claude/workspace/claude-session-setup.sh" ]; then
    chmod +x /home/claude/workspace/claude-session-setup.sh
    su - claude -c "/home/claude/workspace/claude-session-setup.sh"
fi

# Setup and start PM2 with welcome app
echo "Setting up PM2 and welcome app..."
cd /home/claude/workspace

# Install dependencies for welcome app
if [ -d "./projects/welcome-app" ]; then
    echo "Installing welcome app dependencies..."
    su - claude -c "cd /home/claude/workspace/projects/welcome-app && npm install"
fi

# Setup PM2 startup script
echo "Setting up PM2 startup..."
su - claude -c "pm2 startup"

# Start PM2 processes
echo "Starting PM2 processes..."
if [ -f "ecosystem.config.js" ]; then
    su - claude -c "cd /home/claude/workspace && pm2 start ecosystem.config.js --env development"
    echo "PM2 processes started successfully"
    su - claude -c "pm2 list"
else
    echo "ecosystem.config.js not found, starting welcome app manually..."
    su - claude -c "cd /home/claude/workspace/projects/welcome-app && pm2 start server.js --name welcome-app"
fi

# Start SSH service
echo "Starting SSH service..."
exec /usr/sbin/sshd -D
