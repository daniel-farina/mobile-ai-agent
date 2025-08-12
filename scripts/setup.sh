#!/bin/bash

# Claude CLI Container Setup Script
# This script sets up everything needed to run the Claude CLI container

set -e  # Exit on any error

echo "🚀 Setting up Claude CLI Container..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        print_info "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        print_info "Visit: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    print_status "Docker and Docker Compose are installed"
}

# Check if .env file exists and has required variables
check_env() {
    if [ ! -f ".env" ]; then
        print_error ".env file not found!"
        print_info "Please copy env.example to .env and add your Tailscale auth key:"
        echo "  cp env.example .env"
        echo "  # Then edit .env with your Tailscale auth key"
        echo "  # Claude API key is optional - Claude CLI will prompt for login"
        exit 1
    fi
    
    # Check for Tailscale auth key (required for remote access)
    if ! grep -q "TS_AUTHKEY=" .env || grep -q "TS_AUTHKEY=tskey-auth-xxxxxxxx" .env; then
        print_error "TS_AUTHKEY not set or still has placeholder value in .env"
        print_info "Get your Tailscale auth key from: https://login.tailscale.com/admin/settings/keys"
        exit 1
    fi
    
    # Note: ANTHROPIC_API_KEY is optional - Claude CLI will prompt for login
    if grep -q "ANTHROPIC_API_KEY=sk-ant-api03-xxxxxxxx" .env; then
        print_info "Note: Claude API key not set - Claude CLI will prompt for login when first used"
    fi
    
    print_status "Environment variables are configured"
}

# Set up SSH keys
setup_ssh_keys() {
    print_info "Setting up SSH keys for passwordless access..."
    
    # Check if repository SSH keys exist, if not generate them
    if [ ! -f "workspace/ssh-keys/id_ed25519" ]; then
        print_info "Creating repository SSH keys..."
        mkdir -p workspace/ssh-keys
        ssh-keygen -t ed25519 -f workspace/ssh-keys/id_ed25519 -N "" -C "mobile-ai-agent@$(hostname)"
        cp workspace/ssh-keys/id_ed25519.pub workspace/ssh-keys/authorized_keys
        print_status "Repository SSH keys created"
    else
        print_status "Repository SSH keys already exist"
    fi
    
    # Set up SSH host key handling to prevent warnings
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
    Port 22
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking accept-new
    GlobalKnownHostsFile /dev/null
    LogLevel ERROR

Host 100.*
    Port 22
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking accept-new
    GlobalKnownHostsFile /dev/null
    LogLevel ERROR
EOF
        print_status "SSH config updated to auto-accept host keys"
    else
        print_status "SSH config already configured"
    fi
    
    # Create SSH host keys directory
    mkdir -p ssh-host-keys
    
    # Sync CLAUDE.md to claude-config directory
    print_info "Syncing CLAUDE.md to claude-config directory..."
    if [ -f "CLAUDE.md" ]; then
        mkdir -p claude-config
        cp CLAUDE.md claude-config/CLAUDE.md
        print_status "CLAUDE.md synced to claude-config directory"
    else
        print_warning "CLAUDE.md not found - skipping sync"
    fi
    
    print_status "SSH keys configured"
}

# Build and start the container
build_and_start() {
    print_info "Building and starting the container..."
    
    # Stop any existing container
    docker-compose down 2>/dev/null || true
    
    # Build the container
    print_info "Building container (this may take a few minutes)..."
    docker-compose build --no-cache
    
    # Start the container
    print_info "Starting container..."
    docker-compose up -d
    
    # Wait for container to be ready
    print_info "Waiting for container to start..."
    sleep 10
    
    # Check if container is running
    if ! docker ps | grep -q claude-cli-container; then
        print_error "Container failed to start. Check logs with: docker-compose logs claude-cli"
        exit 1
    fi
    
    print_status "Container is running"
}

# Get and display connection information
show_connection_info() {
    print_info "Getting connection information..."
    
    # Wait a bit more for Tailscale to connect
    sleep 5
    
    # Get host machine Tailscale IP (IPv4 only)
    HOST_TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "Not connected")
    
    # Get container Tailscale IP (IPv4 only)
    CONTAINER_TAILSCALE_IP=$(docker exec claude-cli-container tailscale ip -4 2>/dev/null | head -1 || echo "Connecting...")
    
    # Get Docker container IP
    DOCKER_IP=$(docker inspect claude-cli-container 2>/dev/null | grep '"IPAddress"' | head -1 | awk -F'"' '{print $4}' || echo "172.17.0.2")
    
    echo ""
    echo "🎉 Setup Complete!"
    echo ""
    echo "🔗 REMOTE ACCESS (Mobile/Remote Devices)"
    echo "========================================"
    if [ "$HOST_TAILSCALE_IP" != "Not connected" ]; then
        echo "✅ Tailscale Connected: $HOST_TAILSCALE_IP"
        echo ""
        echo "📱 SSH Access:"
        echo "  ssh claude@$HOST_TAILSCALE_IP"
        echo "  Password: claude"
        echo ""
        echo "🌐 Web Access:"
        echo "  Welcome App: http://$HOST_TAILSCALE_IP:5300"
        echo "  New Apps: http://$HOST_TAILSCALE_IP:5301-5320"
        echo ""
        echo "📱 Mobile Setup:"
        echo "  1. Install Tailscale from App Store"
        echo "  2. Install Termius SSH client"
        echo "  3. Connect to: ssh claude@$HOST_TAILSCALE_IP"
        echo "  4. Password: claude"
    else
        echo "❌ Tailscale Not Connected"
        echo "   Run: tailscale up"
        echo "   Then restart: docker-compose restart"
    fi
    
    echo ""
    echo "💻 LOCAL ACCESS (This Machine)"
    echo "=============================="
    echo "SSH: ./ssh-claude"
    echo "Web: http://localhost:5300"
    echo ""
    
    # Create access.txt file
    create_access_file "$HOST_TAILSCALE_IP" "$CONTAINER_TAILSCALE_IP" "$DOCKER_IP"
    
    echo "📄 Access details saved to: access.txt"
    echo ""
    echo "🔧 Quick Commands:"
    echo "  SSH: ./ssh-claude"
    echo "  Logs: docker-compose logs claude-cli"
    echo "  Stop: docker-compose down"
    echo "  Restart: docker-compose restart"
    echo ""
    echo "🚀 Your Claude CLI Container is ready!"
}

# Create access.txt file with connection details
create_access_file() {
    local HOST_IP="$1"
    local CONTAINER_IP="$2"
    local DOCKER_IP="$3"
    
    cat > access.txt << EOF
🚀 Mobile AI Agent - Access Information
=======================================

🔗 REMOTE ACCESS (Mobile/Remote Devices)
=======================================
Host IP: $HOST_IP
SSH: ssh claude@$HOST_IP
Password: claude

Web Apps:
- Welcome App: http://$HOST_IP:5300
- New Apps: http://$HOST_IP:5301-5320
- Flask Apps: http://$HOST_IP:5500
- Django Apps: http://$HOST_IP:5800

📱 Mobile Setup:
1. Install Tailscale from App Store
2. Install Termius SSH client
3. Connect to: ssh claude@$HOST_IP
4. Password: claude

💻 LOCAL ACCESS (This Machine)
==============================
SSH: ./ssh-claude
Web: http://localhost:5300

🐳 DOCKER NETWORK
=================
Container IP: $DOCKER_IP
SSH: ssh claude@$DOCKER_IP
Web: http://$DOCKER_IP:3000

🔧 USEFUL COMMANDS
==================
SSH Access:
  ./ssh-claude                    # Local SSH (key-based)
  ./ssh-password localhost        # Local SSH (password)
  ./ssh-clean                     # Clean SSH (no warnings)

Container Management:
  docker-compose logs claude-cli  # View logs
  docker-compose down             # Stop container
  docker-compose restart          # Restart container
  docker-compose up -d            # Start container

PM2 Management:
  ./ssh-claude "pm2 list"         # List apps
  ./ssh-claude "pm2 monitor"      # Monitor apps
  ./ssh-claude "pm2 logs"         # View logs

📄 Generated: $(date)
EOF
}

# Main setup process
main() {
    echo "🔧 Claude CLI Container Setup"
    echo "=============================="
    echo ""
    
    check_docker
    check_env
    setup_ssh_keys
    build_and_start
    show_connection_info
}

# Run main function
main "$@" 