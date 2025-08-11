#!/bin/bash

# Mobile AI Agent - New Machine Setup Script
# This script sets up the environment on a fresh machine

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo "🚀 Mobile AI Agent - New Machine Setup"
echo "======================================"
echo ""

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    print_error "Please run this script from the mobile-ai-agent directory"
    exit 1
fi

print_info "Setting up SSH host key handling..."

# Create SSH config to prevent host key warnings
SSH_CONFIG_DIR="$HOME/.ssh"
SSH_CONFIG_FILE="$SSH_CONFIG_DIR/config"

# Create .ssh directory if it doesn't exist
mkdir -p "$SSH_CONFIG_DIR"

# Add configuration for mobile-ai-agent to prevent host key warnings
if [ ! -f "$SSH_CONFIG_FILE" ]; then
    touch "$SSH_CONFIG_FILE"
    chmod 600 "$SSH_CONFIG_FILE"
fi

# Add mobile-ai-agent configuration if not already present
if ! grep -q "mobile-ai-agent" "$SSH_CONFIG_FILE"; then
    cat >> "$SSH_CONFIG_FILE" << 'EOF'

# Mobile AI Agent - Auto-accept host keys
Host localhost
    Port 5222
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking accept-new
    GlobalKnownHostsFile /dev/null
    LogLevel ERROR

Host 100.*
    Port 5222
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking accept-new
    GlobalKnownHostsFile /dev/null
    LogLevel ERROR
EOF
    print_status "SSH config updated to auto-accept host keys"
else
    print_status "SSH config already configured"
fi

print_info "Setting up environment..."

# Check if .env exists
if [ ! -f ".env" ]; then
    print_warning ".env file not found. Creating from example..."
    if [ -f "env.example" ]; then
        cp env.example .env
        print_status "Created .env file from example"
        print_warning "Please edit .env with your API keys:"
        echo "  ANTHROPIC_API_KEY=your_claude_api_key"
        echo "  TS_AUTHKEY=your_tailscale_auth_key"
    else
        print_error "env.example not found"
        exit 1
    fi
else
    print_status ".env file exists"
fi

print_info "Making scripts executable..."
chmod +x scripts/*.sh
chmod +x ssh-*
print_status "Scripts are executable"

print_info "Setting up SSH keys..."
if [ ! -f "workspace/ssh-keys/id_ed25519" ]; then
    print_warning "SSH keys not found. Run the main setup script first:"
    echo "  ./scripts/setup.sh"
    exit 1
fi

# Set proper permissions on SSH keys
chmod 600 workspace/ssh-keys/id_ed25519
chmod 644 workspace/ssh-keys/id_ed25519.pub
print_status "SSH key permissions set"

print_info "Testing SSH connection..."
if ./ssh-password localhost 5222 "echo 'SSH test successful'" > /dev/null 2>&1; then
    print_status "SSH connection test passed"
else
    print_warning "SSH connection test failed. Container may not be running."
    print_info "Start the container with: docker-compose up -d"
fi

echo ""
echo "🎉 New Machine Setup Complete!"
echo ""
echo "📋 Quick Commands:"
echo "  ./ssh-claude                    # Key-based local access"
echo "  ./ssh-password localhost 5222   # Password-based local access"
echo "  ./ssh-clean                     # Clean SSH without warnings"
echo ""
echo "📱 Mobile Access (once Tailscale is configured):"
echo "  ./ssh-password 100.82.56.81     # Remote password access"
echo "  ./ssh-claude --host 100.82.56.81 # Remote key access"
echo ""
echo "🔧 Management:"
echo "  docker-compose up -d            # Start container"
echo "  docker-compose down             # Stop container"
echo "  docker-compose logs claude-cli  # View logs"
echo ""
print_status "Your Mobile AI Agent is ready for use!"
