# SSH Key Setup Script for Claude CLI Container (PowerShell)
# This script helps you set up SSH keys for passwordless access

Write-Host "🔑 Setting up SSH keys for Claude CLI Container..." -ForegroundColor Green

# Check if SSH keys exist
$sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa"
if (-not (Test-Path $sshKeyPath)) {
    Write-Host "📝 No SSH key found. Creating a new one..." -ForegroundColor Yellow
    
    # Create .ssh directory if it doesn't exist
    $sshDir = "$env:USERPROFILE\.ssh"
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force
    }
    
    # Generate SSH key using ssh-keygen
    ssh-keygen -t rsa -b 4096 -f $sshKeyPath -N '""'
    Write-Host "✅ SSH key created!" -ForegroundColor Green
}
else {
    Write-Host "✅ SSH key already exists at $sshKeyPath" -ForegroundColor Green
}

# Create workspace/.ssh directory if it doesn't exist
$workspaceSshDir = "workspace\.ssh"
if (-not (Test-Path $workspaceSshDir)) {
    New-Item -ItemType Directory -Path $workspaceSshDir -Force
}

# Copy public key to workspace
$publicKeyPath = "$env:USERPROFILE\.ssh\id_rsa.pub"
$authorizedKeysPath = "workspace\.ssh\authorized_keys"
Copy-Item $publicKeyPath $authorizedKeysPath -Force

Write-Host "🔐 Public key copied to workspace\.ssh\authorized_keys" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Rebuild the container: docker-compose down && docker-compose up -d"
Write-Host "2. SSH into container: ssh claude@100.64.246.92"
Write-Host "3. No password required! 🎉"
Write-Host ""
Write-Host "💡 If you want to use a different key:" -ForegroundColor Cyan
Write-Host "   Copy-Item `"$env:USERPROFILE\.ssh\your_key.pub`" `"workspace\.ssh\authorized_keys`"" 