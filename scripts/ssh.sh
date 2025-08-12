#!/bin/bash

# Mobile AI Agent - SSH Connection Script
# This script provides easy SSH access using only repository SSH keys

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SSH_KEY="$PROJECT_ROOT/workspace/ssh-keys/id_ed25519"

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ SSH key not found: $SSH_KEY"
    echo "Run the setup script first: ./scripts/setup.sh"
    exit 1
fi

# Set proper permissions on SSH key
chmod 600 "$SSH_KEY"

# Default values
HOST="localhost"
PORT="22"
USER="claude"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)
            HOST="$2"
            shift 2
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        --user)
            USER="$2"
            shift 2
            ;;
        --help|-h)
            echo "Mobile AI Agent - SSH Connection Script"
            echo ""
            echo "Usage: $0 [OPTIONS] [SSH_COMMAND]"
            echo ""
            echo "Options:"
            echo "  --host HOST     SSH host (default: localhost)"
            echo "  --port PORT     SSH port (default: 22)"
            echo "  --user USER     SSH user (default: claude)"
            echo "  --help, -h      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Connect to local container"
            echo "  $0 --host 100.82.56.81               # Connect via Tailscale"
            echo "  $0 'pm2 status'                      # Run command and exit"
            echo "  $0 --host 100.82.56.81 'whoami'      # Run command on remote host"
            echo ""
            echo "SSH Key: $SSH_KEY"
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

print_info "Connecting to Mobile AI Agent..."
print_info "Host: $HOST:$PORT"
print_info "User: $USER"
print_info "SSH Key: $SSH_KEY"
echo ""

# Build SSH command with automatic host key acceptance and no warnings
SSH_CMD="ssh -i '$SSH_KEY' -p $PORT -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o GlobalKnownHostsFile=/dev/null $USER@$HOST"

# If additional arguments provided, run command and exit
if [ $# -gt 0 ]; then
    print_info "Running command: $*"
    eval "$SSH_CMD" "$@"
else
    print_info "Starting interactive session..."
    print_success "Claude CLI will auto-launch with full project context!"
    echo ""
    eval "$SSH_CMD"
fi
