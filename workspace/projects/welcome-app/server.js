const express = require('express');
const pm2 = require('pm2');
const path = require('path');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// PM2 connection
pm2.connect((err) => {
  if (err) {
    console.error('Error connecting to PM2:', err);
    process.exit(1);
  }
  console.log('Connected to PM2');
});

// Routes
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// API Routes
app.get('/api/status', (req, res) => {
  pm2.list((err, list) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({ apps: list });
  });
});

app.get('/api/system', (req, res) => {
  const systemInfo = {
    hostname: os.hostname(),
    platform: os.platform(),
    arch: os.arch(),
    uptime: os.uptime(),
    totalMem: os.totalmem(),
    freeMem: os.freemem(),
    cpus: os.cpus().length,
    loadAvg: os.loadavg()
  };
  res.json(systemInfo);
});

app.post('/api/pm2/action', (req, res) => {
  const { action, appName } = req.body;
  
  switch (action) {
    case 'start':
      pm2.start(appName, (err) => {
        if (err) res.status(500).json({ error: err.message });
        else res.json({ success: true, message: `Started ${appName}` });
      });
      break;
    case 'stop':
      pm2.stop(appName, (err) => {
        if (err) res.status(500).json({ error: err.message });
        else res.json({ success: true, message: `Stopped ${appName}` });
      });
      break;
    case 'restart':
      pm2.restart(appName, (err) => {
        if (err) res.status(500).json({ error: err.message });
        else res.json({ success: true, message: `Restarted ${appName}` });
      });
      break;
    case 'delete':
      pm2.delete(appName, (err) => {
        if (err) res.status(500).json({ error: err.message });
        else res.json({ success: true, message: `Deleted ${appName}` });
      });
      break;
    case 'logs':
      pm2.logs(appName, { lines: 50 }, (err, logs) => {
        if (err) res.status(500).json({ error: err.message });
        else res.json({ logs });
      });
      break;
    default:
      res.status(400).json({ error: 'Invalid action' });
  }
});

app.get('/api/ports', (req, res) => {
  const ports = {
    welcome: 3000,
    react: 3000,
    nextjs: 3002,
    express: 3001,
    flask: 5000,
    django: 8000
  };
  res.json(ports);
});

app.get('/api/tailscale', (req, res) => {
  const fs = require('fs');
  const path = require('path');
  const { exec } = require('child_process');
  
  // Try to read from config file first
  const configPath = path.join(__dirname, '../../tailscale-config.json');
  
  try {
    if (fs.existsSync(configPath)) {
      const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      
      // If config has valid data, use it
      if (config.setupComplete && config.hostIP) {
        res.json({
          available: true,
          message: config.status === 'connected' ? 'Tailscale connected' : 'Host connected, container connecting',
          hostIP: config.hostIP,
          containerIP: config.containerIP
        });
        return;
      }
    }
  } catch (error) {
    console.log('Error reading config file:', error.message);
  }
  
  // Fallback to real-time check
  exec('which tailscale', (err, stdout) => {
    if (err) {
      res.json({ 
        available: false, 
        message: 'Tailscale not found on host machine',
        hostIP: null,
        containerIP: null
      });
      return;
    }
    
    // Get host machine's Tailscale IP
    exec('tailscale ip', (err, hostIP) => {
      if (err) {
        res.json({ 
          available: true, 
          message: 'Tailscale found but not connected',
          hostIP: null,
          containerIP: null
        });
        return;
      }
      
      // Get container's Tailscale IP
      exec('docker exec claude-cli-container tailscale ip', (err, containerIP) => {
        res.json({ 
          available: true, 
          message: 'Tailscale connected',
          hostIP: hostIP.trim(),
          containerIP: err ? null : containerIP.trim()
        });
      });
    });
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Welcome App running on port ${PORT}`);
  console.log(`📱 Access via: http://localhost:${PORT + 2300} (mapped port)`);
  console.log(`🔧 PM2 Management Interface ready`);
});
