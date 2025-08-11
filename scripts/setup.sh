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
        print_info "Please copy env.example to .env and add your API keys:"
        echo "  cp env.example .env"
        echo "  # Then edit .env with your actual API keys"
        exit 1
    fi
    
    # Check for required environment variables
    if ! grep -q "ANTHROPIC_API_KEY=" .env || grep -q "ANTHROPIC_API_KEY=sk-ant-api03-xxxxxxxx" .env; then
        print_error "ANTHROPIC_API_KEY not set or still has placeholder value in .env"
        exit 1
    fi
    
    if ! grep -q "TS_AUTHKEY=" .env || grep -q "TS_AUTHKEY=tskey-auth-xxxxxxxx" .env; then
        print_error "TS_AUTHKEY not set or still has placeholder value in .env"
        exit 1
    fi
    
    print_status "Environment variables are configured"
}

# Set up SSH keys
setup_ssh_keys() {
    print_info "Setting up SSH keys for passwordless access..."
    
    # Check if SSH keys exist
    if [ ! -f ~/.ssh/id_rsa ]; then
        print_info "Creating new SSH key..."
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -C "claude-cli-container"
        print_status "SSH key created"
    else
        print_status "SSH key already exists"
    fi
    
    # Create workspace/.ssh directory
    mkdir -p workspace/.ssh
    
    # Copy public key to workspace
    cp ~/.ssh/id_rsa.pub workspace/.ssh/authorized_keys
    chmod 600 workspace/.ssh/authorized_keys
    
    # Create SSH host keys directory
    mkdir -p ssh-host-keys
    
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
    
    # Get local IP address
    LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
    
    # Get Docker container IP
    DOCKER_IP=$(docker inspect claude-cli-container | grep '"IPAddress"' | head -1 | awk -F'"' '{print $4}')
    
    # Get Tailscale IP
    TAILSCALE_IP=$(docker exec claude-cli-container tailscale ip 2>/dev/null | head -1 || echo "Connecting...")
    
    # Get Tailscale status
    TAILSCALE_STATUS=$(docker exec claude-cli-container tailscale status 2>/dev/null | head -1 || echo "Not connected")
    
    # Get host machine Tailscale IP
    HOST_TAILSCALE_IP=$(tailscale ip 2>/dev/null || echo "Not connected")
    
    echo ""
    echo "🎉 Setup Complete!"
    echo ""
    echo "📋 Connection Information:"
    echo ""
    echo "🌐 Local Access (from this machine):"
    echo "  SSH: ssh claude@localhost -p 5222"
    echo "  Web Apps: http://localhost:5300 (Welcome App)"
    echo "            http://localhost:5301 (React/Node.js)"
    echo "            http://localhost:5500 (Flask)"
    echo "            http://localhost:5800 (Django)"
    echo ""
    echo "🐳 Docker Network Access:"
    echo "  SSH: ssh claude@$DOCKER_IP"
    echo "  Web Apps: http://$DOCKER_IP:3000 (Welcome App)"
    echo "            http://$DOCKER_IP:3001 (React/Node.js)"
    echo "            http://$DOCKER_IP:5000 (Flask)"
    echo "            http://$DOCKER_IP:8000 (Django)"
    echo ""
    echo "🔗 Tailscale Network Access (for mobile/remote):"
    echo "  Host Machine IP: $HOST_TAILSCALE_IP"
    echo "  Container Status: $TAILSCALE_STATUS"
    if [ "$TAILSCALE_IP" != "Connecting..." ]; then
        echo "  Container IP: $TAILSCALE_IP"
        echo "  SSH: ssh claude@$HOST_TAILSCALE_IP -p 5222"
        echo "  Web Apps: http://$HOST_TAILSCALE_IP:5300 (Welcome App)"
        echo "            http://$HOST_TAILSCALE_IP:5301 (React/Node.js)"
        echo "            http://$HOST_TAILSCALE_IP:5500 (Flask)"
        echo "            http://$HOST_TAILSCALE_IP:5800 (Django)"
    else
        echo "  ⏳ Container Tailscale is connecting... (check logs: docker-compose logs claude-cli)"
    fi
    echo ""
    echo "📱 Mobile Access:"
    echo "  1. Install Tailscale from App Store"
    echo "  2. SSH: Use Termius app with the host IP above"
    echo "  3. Web: Open Safari and go to http://$HOST_TAILSCALE_IP:5300"
    echo ""
    echo "🔧 Useful Commands:"
    echo "  View logs: docker-compose logs claude-cli"
    echo "  Stop container: docker-compose down"
    echo "  Restart container: docker-compose restart"
    echo "  Check Tailscale: ./scripts/setup-tailscale.sh"
    echo "  SSH into container: ssh claude@localhost -p 5222"
    echo ""
    echo "🚀 Your Claude CLI Container is ready!"
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