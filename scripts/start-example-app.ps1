# Start Example App Script (PowerShell)
# This script starts the example web app in the Claude CLI container

Write-Host "🚀 Starting Claude CLI Container Example App..." -ForegroundColor Green

# Check if container is running
$containerRunning = docker ps 2>$null | Select-String "claude-cli-container"
if (-not $containerRunning) {
    Write-Host "❌ Container is not running. Please start it first:" -ForegroundColor Red
    Write-Host "   docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

# Get Tailscale IP
try {
    $tailscaleIP = docker exec claude-cli-container tailscale ip 2>$null | Select-Object -First 1
    if (-not $tailscaleIP) {
        Write-Host "❌ Could not get Tailscale IP. Container may not be fully started." -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "❌ Could not get Tailscale IP. Container may not be fully started." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Container is running" -ForegroundColor Green
Write-Host "🌐 Tailscale IP: $tailscaleIP" -ForegroundColor Cyan

# Start the example app
Write-Host "📦 Installing dependencies and starting example app..." -ForegroundColor Yellow
docker exec -d claude-cli-container bash -c "cd /home/claude/workspace/example-app && npm install --silent && npm start"

Write-Host ""
Write-Host "🎉 Example app is starting!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 Access URLs:" -ForegroundColor Yellow
Write-Host "   Local: http://localhost:3000"
Write-Host "   iPhone: http://$tailscaleIP`:3000"
Write-Host ""
Write-Host "🔗 API Endpoints:" -ForegroundColor Yellow
Write-Host "   Status: http://$tailscaleIP`:3000/api/status"
Write-Host "   Ports: http://$tailscaleIP`:3000/api/ports"
Write-Host ""
Write-Host "💡 To stop the app:" -ForegroundColor Cyan
Write-Host "   docker exec claude-cli-container pkill -f 'node app.js'" 