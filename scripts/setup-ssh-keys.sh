#!/bin/bash

# SSH Key Setup Script for Claude CLI Container
# This script helps you set up SSH keys for passwordless access

echo "🔑 Setting up SSH keys for Claude CLI Container..."

# Check if SSH keys exist
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "📝 No SSH key found. Creating a new one..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo "✅ SSH key created!"
else
    echo "✅ SSH key already exists at ~/.ssh/id_rsa"
fi

# Create .ssh directory in workspace if it doesn't exist
mkdir -p workspace/.ssh

# Copy public key to workspace
cp ~/.ssh/id_rsa.pub workspace/.ssh/authorized_keys

echo "🔐 Public key copied to workspace/.ssh/authorized_keys"
echo ""
echo "📋 Next steps:"
echo "1. Rebuild the container: docker-compose down && docker-compose up -d"
echo "2. SSH into container: ssh claude@100.64.246.92"
echo "3. No password required! 🎉"
echo ""
echo "💡 If you want to use a different key:"
echo "   cp ~/.ssh/your_key.pub workspace/.ssh/authorized_keys" 