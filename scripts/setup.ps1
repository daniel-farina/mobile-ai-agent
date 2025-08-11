# Claude CLI Container Setup Script (PowerShell)
# This script sets up everything needed to run the Claude CLI container on Windows

param(
    [switch]$SkipDockerCheck
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🚀 Setting up Claude CLI Container..." -ForegroundColor Green

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

# Check if Docker is installed
function Test-Docker {
    if (-not $SkipDockerCheck) {
        try {
            $dockerVersion = docker --version 2>$null
            if (-not $dockerVersion) {
                Write-Error "Docker is not installed. Please install Docker Desktop first."
                Write-Info "Visit: https://docs.docker.com/desktop/install/windows/"
                exit 1
            }
            
            $composeVersion = docker-compose --version 2>$null
            if (-not $composeVersion) {
                Write-Error "Docker Compose is not installed. Please install Docker Compose first."
                Write-Info "Visit: https://docs.docker.com/compose/install/"
                exit 1
            }
            
            Write-Status "Docker and Docker Compose are installed"
        }
        catch {
            Write-Error "Docker is not running. Please start Docker Desktop."
            exit 1
        }
    }
}

# Check if .env file exists and has required variables
function Test-Environment {
    if (-not (Test-Path ".env")) {
        Write-Error ".env file not found!"
        Write-Info "Please copy env.example to .env and add your API keys:"
        Write-Host "  Copy-Item env.example .env"
        Write-Host "  # Then edit .env with your actual API keys"
        exit 1
    }
    
    $envContent = Get-Content ".env" -Raw
    
    # Check for required environment variables
    if ($envContent -notmatch "ANTHROPIC_API_KEY=" -or $envContent -match "ANTHROPIC_API_KEY=sk-ant-api03-xxxxxxxx") {
        Write-Error "ANTHROPIC_API_KEY not set or still has placeholder value in .env"
        exit 1
    }
    
    if ($envContent -notmatch "TS_AUTHKEY=" -or $envContent -match "TS_AUTHKEY=tskey-auth-xxxxxxxx") {
        Write-Error "TS_AUTHKEY not set or still has placeholder value in .env"
        exit 1
    }
    
    Write-Status "Environment variables are configured"
}

# Set up SSH keys
function Set-SSHKeys {
    Write-Info "Setting up SSH keys for passwordless access..."
    
    $sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa"
    
    # Check if SSH keys exist
    if (-not (Test-Path $sshKeyPath)) {
        Write-Info "Creating new SSH key..."
        
        # Create .ssh directory if it doesn't exist
        $sshDir = "$env:USERPROFILE\.ssh"
        if (-not (Test-Path $sshDir)) {
            New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
        }
        
        # Generate SSH key
        ssh-keygen -t rsa -b 4096 -f $sshKeyPath -N '""' -C "claude-cli-container"
        Write-Status "SSH key created"
    }
    else {
        Write-Status "SSH key already exists"
    }
    
    # Create workspace/.ssh directory
    $workspaceSshDir = "workspace\.ssh"
    if (-not (Test-Path $workspaceSshDir)) {
        New-Item -ItemType Directory -Path $workspaceSshDir -Force | Out-Null
    }
    
    # Copy public key to workspace
    $publicKeyPath = "$env:USERPROFILE\.ssh\id_rsa.pub"
    $authorizedKeysPath = "workspace\.ssh\authorized_keys"
    Copy-Item $publicKeyPath $authorizedKeysPath -Force
    
    Write-Status "SSH keys configured"
}

# Build and start the container
function Start-Container {
    Write-Info "Building and starting the container..."
    
    # Stop any existing container
    try {
        docker-compose down 2>$null
    }
    catch {
        # Ignore errors if no container is running
    }
    
    # Build the container
    Write-Info "Building container (this may take a few minutes)..."
    docker-compose build --no-cache
    
    # Start the container
    Write-Info "Starting container..."
    docker-compose up -d
    
    # Wait for container to be ready
    Write-Info "Waiting for container to start..."
    Start-Sleep -Seconds 10
    
    # Check if container is running
    $containerRunning = docker ps 2>$null | Select-String "claude-cli-container"
    if (-not $containerRunning) {
        Write-Error "Container failed to start. Check logs with: docker-compose logs claude-cli"
        exit 1
    }
    
    Write-Status "Container is running"
}

# Get and display connection information
function Show-ConnectionInfo {
    Write-Info "Getting connection information..."
    
    # Wait a bit more for Tailscale to connect
    Start-Sleep -Seconds 5
    
    # Get Tailscale IP
    try {
        $tailscaleIP = docker exec claude-cli-container tailscale ip 2>$null | Select-Object -First 1
        if (-not $tailscaleIP) {
            $tailscaleIP = "Connecting..."
        }
    }
    catch {
        $tailscaleIP = "Connecting..."
    }
    
    Write-Host ""
    Write-Host "🎉 Setup Complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Connection Information:" -ForegroundColor Yellow
    Write-Host "  SSH Access: ssh claude@$tailscaleIP"
    Write-Host "  Web Apps: http://$tailscaleIP`:3000 (and other ports)"
    Write-Host ""
    Write-Host "📱 iPhone Access:" -ForegroundColor Yellow
    Write-Host "  1. Install Tailscale from App Store"
    Write-Host "  2. SSH: Use Termius app with the IP above"
    Write-Host "  3. Web: Open Safari and go to http://$tailscaleIP`:3000"
    Write-Host ""
    Write-Host "🔧 Useful Commands:" -ForegroundColor Yellow
    Write-Host "  View logs: docker-compose logs claude-cli"
    Write-Host "  Stop container: docker-compose down"
    Write-Host "  Restart container: docker-compose restart"
    Write-Host "  SSH into container: ssh claude@$tailscaleIP"
    Write-Host ""
    Write-Host "🚀 Your Claude CLI Container is ready!" -ForegroundColor Green
}

# Main setup process
function Main {
    Write-Host "🔧 Claude CLI Container Setup" -ForegroundColor Green
    Write-Host "==============================" -ForegroundColor Green
    Write-Host ""
    
    Test-Docker
    Test-Environment
    Set-SSHKeys
    Start-Container
    Show-ConnectionInfo
}

# Run main function
Main 