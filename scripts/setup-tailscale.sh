#!/bin/bash

# Tailscale Setup Script for Mobile AI Agent
# This script checks Tailscale status and configures access

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

echo "🔗 Tailscale Setup for Mobile AI Agent"
echo "======================================"
echo ""

# Check if Tailscale is installed on host
print_info "Checking Tailscale installation on host machine..."

if ! command -v tailscale &> /dev/null; then
    print_error "Tailscale is not installed on the host machine"
    echo ""
    echo "To install Tailscale:"
    echo "  macOS: brew install tailscale"
    echo "  Ubuntu: curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.gpg | sudo apt-key add -"
    echo "  Visit: https://tailscale.com/download"
    echo ""
    exit 1
fi

print_status "Tailscale is installed on host machine"

# Check if Tailscale is running on host
print_info "Checking Tailscale connection on host machine..."

HOST_TAILSCALE_IP=$(tailscale ip 2>/dev/null || echo "")

if [ -z "$HOST_TAILSCALE_IP" ]; then
    print_warning "Tailscale is not connected on host machine"
    echo ""
    echo "To connect Tailscale:"
    echo "  1. Run: tailscale up"
    echo "  2. Follow the authentication process"
    echo "  3. Run this script again"
    echo ""
    # Don't exit, continue to write config with null values
    HOST_TAILSCALE_IP=""
else
    print_status "Host machine Tailscale IP: $HOST_TAILSCALE_IP"
fi

print_status "Host machine Tailscale IP: $HOST_TAILSCALE_IP"

# Check if container is running
print_info "Checking container status..."

if ! docker ps | grep -q claude-cli-container; then
    print_error "Container is not running. Start it first with: docker-compose up -d"
    exit 1
fi

print_status "Container is running"

# Check container's Tailscale status
print_info "Checking container's Tailscale status..."

CONTAINER_TAILSCALE_IP=$(docker exec claude-cli-container tailscale ip 2>/dev/null || echo "")

if [ -z "$CONTAINER_TAILSCALE_IP" ]; then
    print_warning "Container's Tailscale is not connected"
    echo ""
    echo "Container Tailscale Status:"
    docker exec claude-cli-container tailscale status
    echo ""
    echo "To fix this:"
    echo "  1. Make sure TS_AUTHKEY is set in your .env file"
    echo "  2. Restart the container: docker-compose restart"
    echo "  3. Check container logs: docker-compose logs claude-cli"
    echo ""
else
    print_status "Container Tailscale IP: $CONTAINER_TAILSCALE_IP"
fi

# Update config file with Tailscale information
CONFIG_FILE="workspace/tailscale-config.json"
CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create config JSON
cat > "$CONFIG_FILE" << EOF
{
  "hostIP": "$HOST_TAILSCALE_IP",
  "containerIP": "$CONTAINER_TAILSCALE_IP",
  "status": "$([ -n "$CONTAINER_TAILSCALE_IP" ] && echo "connected" || echo "host_only")",
  "lastUpdated": "$CURRENT_TIME",
  "setupComplete": true,
  "accessUrls": {
    "welcomeApp": "http://$HOST_TAILSCALE_IP:5300",
    "reactApp": "http://$HOST_TAILSCALE_IP:5301",
    "flaskApp": "http://$HOST_TAILSCALE_IP:5500",
    "djangoApp": "http://$HOST_TAILSCALE_IP:5800"
  },
  "sshAccess": {
    "host": "ssh claude@$HOST_TAILSCALE_IP -p 5222",
    "container": "ssh claude@$CONTAINER_TAILSCALE_IP"
  }
}
EOF

print_status "Tailscale configuration saved to $CONFIG_FILE"

echo ""
echo "🎉 Tailscale Setup Complete!"
echo ""
echo "📱 Mobile Access Information:"
echo "  Host Machine IP: $HOST_TAILSCALE_IP"
echo "  Container IP: $CONTAINER_TAILSCALE_IP"
echo ""
echo "🌐 Access URLs:"
echo "  Welcome App: http://$HOST_TAILSCALE_IP:5300"
echo "  React Apps: http://$HOST_TAILSCALE_IP:5301"
echo "  Flask Apps: http://$HOST_TAILSCALE_IP:5500"
echo "  Django Apps: http://$HOST_TAILSCALE_IP:5800"
echo ""
echo "🔐 SSH Access:"
echo "  From mobile: ssh claude@$HOST_TAILSCALE_IP -p 5222"
echo "  From any device: ssh claude@$CONTAINER_TAILSCALE_IP"
echo ""
echo "📋 Quick Commands:"
echo "  Check host status: tailscale status"
echo "  Check container status: docker exec claude-cli-container tailscale status"
echo "  View container logs: docker-compose logs claude-cli"
echo "  View config: cat $CONFIG_FILE"
echo ""
