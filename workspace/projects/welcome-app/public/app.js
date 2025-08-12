// Welcome App - PM2 Management Interface
class WelcomeApp {
    constructor() {
        this.refreshInterval = null;
        this.init();
    }

    init() {
        this.loadData();
        this.startAutoRefresh();
    }

    async loadData() {
        try {
            await Promise.all([
                this.loadApps(),
                this.loadSystemInfo(),
                this.loadPorts(),
                this.loadTailscaleInfo()
            ]);
        } catch (error) {
            console.error('Error loading data:', error);
        }
    }

    async loadApps() {
        try {
            const response = await fetch('/api/status');
            const data = await response.json();
            this.renderApps(data.apps || []);
        } catch (error) {
            document.getElementById('apps-container').innerHTML = 
                '<div class="error">Error loading applications</div>';
        }
    }

    async loadSystemInfo() {
        try {
            const response = await fetch('/api/system');
            const data = await response.json();
            this.renderSystemInfo(data);
        } catch (error) {
            document.getElementById('system-container').innerHTML = 
                '<div class="error">Error loading system info</div>';
        }
    }

    async loadPorts() {
        try {
            const response = await fetch('/api/ports');
            const data = await response.json();
            this.renderPorts(data);
        } catch (error) {
            document.getElementById('ports-container').innerHTML = 
                '<div class="error">Error loading port info</div>';
        }
    }

    async loadTailscaleInfo() {
        try {
            const response = await fetch('/api/tailscale');
            const data = await response.json();
            this.renderTailscaleInfo(data);
        } catch (error) {
            document.getElementById('tailscale-container').innerHTML = 
                '<div class="error">Error loading Tailscale info</div>';
        }
    }

    renderApps(apps) {
        const container = document.getElementById('apps-container');
        
        // Filter to show only running apps (excluding welcome-app)
        const runningApps = apps.filter(app => 
            app.pm2_env.status === 'online' && app.name !== 'welcome-app'
        );
        
        if (runningApps.length === 0) {
            container.innerHTML = `
                <div class="app-item">
                    <h4>📱 No Additional Apps Running</h4>
                    <div class="app-stats">
                        <span>Status: Ready for new apps</span>
                    </div>
                    <div class="app-actions">
                        <span style="color: #ccc; font-size: 0.9em;">Use Quick Actions below to create new apps</span>
                    </div>
                </div>
            `;
            return;
        }

        const appsHtml = runningApps.map(app => {
            const statusIcon = '🟢';
            
            // Determine the port based on app name or default to 5301
            let port = 5301;
            if (app.name.includes('react') || app.name.includes('next')) {
                port = 5301;
            } else if (app.name.includes('express') || app.name.includes('api')) {
                port = 5302;
            } else if (app.name.includes('flask')) {
                port = 5500;
            } else if (app.name.includes('django')) {
                port = 5800;
            }
            
            return `
                <div class="app-item">
                    <h4>${statusIcon} ${app.name}</h4>
                    <div class="app-stats">
                        <span>Status: ${app.pm2_env.status}</span>
                        <span>CPU: ${app.monit.cpu}%</span>
                        <span>Memory: ${this.formatBytes(app.monit.memory)}</span>
                    </div>
                    <div class="app-actions">
                        <a href="http://localhost:${port}" class="btn btn-logs" target="_blank">Open App</a>
                        <button class="btn btn-stop" onclick="welcomeApp.pm2Action('stop', '${app.name}')">Stop</button>
                        <button class="btn btn-restart" onclick="welcomeApp.pm2Action('restart', '${app.name}')">Restart</button>
                        <button class="btn btn-logs" onclick="welcomeApp.pm2Action('logs', '${app.name}')">Logs</button>
                        <button class="btn btn-delete" onclick="welcomeApp.pm2Action('delete', '${app.name}')">Delete</button>
                    </div>
                </div>
            `;
        }).join('');

        container.innerHTML = appsHtml;
    }

    renderSystemInfo(info) {
        const container = document.getElementById('system-container');
        
        const uptime = this.formatUptime(info.uptime);
        const memoryUsage = ((info.totalMem - info.freeMem) / info.totalMem * 100).toFixed(1);
        
        container.innerHTML = `
            <div class="system-info">
                <div class="info-item">
                    <div class="info-label">Hostname</div>
                    <div class="info-value">${info.hostname}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Platform</div>
                    <div class="info-value">${info.platform}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Uptime</div>
                    <div class="info-value">${uptime}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Memory Usage</div>
                    <div class="info-value">${memoryUsage}%</div>
                </div>
                <div class="info-item">
                    <div class="info-label">CPU Cores</div>
                    <div class="info-value">${info.cpus}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Load Average</div>
                    <div class="info-value">${info.loadAvg[0].toFixed(2)}</div>
                </div>
            </div>
        `;
    }

    renderPorts(ports) {
        const container = document.getElementById('ports-container');
        
        container.innerHTML = `
            <div class="app-item">
                <h4>🚀 Welcome App (Always Running)</h4>
                <div class="app-stats">
                    <span>Container: 3000</span>
                    <span>Host: 5300</span>
                </div>
                <div class="app-actions">
                    <a href="http://localhost:5300" class="btn btn-logs" target="_blank">Open</a>
                </div>
            </div>
            
            <div class="app-item">
                <h4>📱 Additional Apps (5301-5320)</h4>
                <div class="app-stats">
                    <span>Container: 3001-3020</span>
                    <span>Host: 5301-5320</span>
                </div>
                <div class="app-actions">
                    <span style="color: #ccc; font-size: 0.9em;">Available for new Node.js/React/Next.js apps</span>
                </div>
            </div>
            
            <div class="app-item">
                <h4>🐍 Python Apps</h4>
                <div class="app-stats">
                    <span>Flask: 5500 (container: 5000)</span>
                    <span>Django: 5800 (container: 8000)</span>
                </div>
                <div class="app-actions">
                    <span style="color: #ccc; font-size: 0.9em;">Available for Python web applications</span>
                </div>
            </div>
            
            <div class="app-item">
                <h4>🌐 Alternative Web (5808)</h4>
                <div class="app-stats">
                    <span>Container: 8080</span>
                    <span>Host: 5808</span>
                </div>
                <div class="app-actions">
                    <span style="color: #ccc; font-size: 0.9em;">Available for any web server</span>
                </div>
            </div>
        `;
    }

    renderTailscaleInfo(info) {
        const container = document.getElementById('tailscale-container');
        
        if (!info.available) {
            container.innerHTML = `
                <div class="app-item stopped">
                    <h4>🔴 Tailscale Not Available</h4>
                    <div class="app-stats">
                        <span>Status: Not installed</span>
                    </div>
                    <div class="app-actions">
                        <a href="https://tailscale.com/download" class="btn btn-start" target="_blank">Install Tailscale</a>
                    </div>
                </div>
            `;
            return;
        }

        if (!info.hostIP) {
            container.innerHTML = `
                <div class="app-item stopped">
                    <h4>🟡 Tailscale Not Connected</h4>
                    <div class="app-stats">
                        <span>Status: Found but not connected</span>
                    </div>
                    <div class="app-actions">
                        <button class="btn btn-start" onclick="welcomeApp.connectTailscale()">Connect</button>
                    </div>
                </div>
            `;
            return;
        }

        const statusClass = info.containerIP ? '' : 'stopped';
        const statusIcon = info.containerIP ? '🟢' : '🟡';

        container.innerHTML = `
            <div class="app-item ${statusClass}">
                <h4>${statusIcon} Tailscale Connected</h4>
                <div class="app-stats">
                    <span><strong>Host IP:</strong> ${info.hostIP}</span>
                </div>
                <div class="app-actions">
                    <button class="btn btn-start" onclick="welcomeApp.copyIP('${info.hostIP}')">Copy IP</button>
                </div>
                <div style="margin-top: 10px; padding: 10px; background: rgba(255,255,255,0.1); border-radius: 5px; font-size: 0.9em;">
                    <strong>📱 Mobile Access:</strong><br>
                    SSH: <code>ssh claude@${info.hostIP}</code><br>
                    Web: <code>http://${info.hostIP}:5300</code>
                </div>
            </div>
        `;
    }

    async pm2Action(action, appName) {
        try {
            const response = await fetch('/api/pm2/action', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ action, appName })
            });

            const result = await response.json();
            
            if (result.success) {
                this.showNotification(result.message, 'success');
                setTimeout(() => this.loadData(), 1000);
            } else {
                this.showNotification(result.error, 'error');
            }
        } catch (error) {
            this.showNotification('Error performing action', 'error');
        }
    }

    showNotification(message, type) {
        const notification = document.createElement('div');
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: ${type === 'success' ? '#4CAF50' : '#f44336'};
            color: white;
            padding: 15px 20px;
            border-radius: 5px;
            z-index: 1000;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        `;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, 3000);
    }

    startAutoRefresh() {
        this.refreshInterval = setInterval(() => {
            this.loadData();
        }, 5000); // Refresh every 5 seconds
    }

    stopAutoRefresh() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }
    }

    formatBytes(bytes) {
        if (bytes === 0) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }

    formatUptime(seconds) {
        const days = Math.floor(seconds / 86400);
        const hours = Math.floor((seconds % 86400) / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        
        if (days > 0) return `${days}d ${hours}h ${minutes}m`;
        if (hours > 0) return `${hours}h ${minutes}m`;
        return `${minutes}m`;
    }

    copyIP(ip) {
        navigator.clipboard.writeText(ip).then(() => {
            this.showNotification(`IP ${ip} copied to clipboard!`, 'success');
        }).catch(() => {
            this.showNotification('Failed to copy IP', 'error');
        });
    }
}

// Global functions for quick actions
function pm2Monitor() {
    // This would open PM2 monitor in a new window
    window.open('http://localhost:5300', '_blank');
}

function pm2Logs() {
    // This would show PM2 logs
    alert('PM2 logs functionality - implement as needed');
}

function createReactApp() {
    // This would trigger React app creation
    if (confirm('Create a new React app?')) {
        // Implementation would go here
        alert('React app creation - implement as needed');
    }
}

// Initialize the app
const welcomeApp = new WelcomeApp();

// Global function for refresh button
function loadData() {
    welcomeApp.loadData();
}
