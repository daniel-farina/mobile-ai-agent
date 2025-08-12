# Mobile AI Agent Environment - Claude Memory & Instructions

See @README.md for project overview and setup instructions.

## 🏠 **Current Environment**

You are running inside a **Docker container** that serves as a **Mobile AI Agent Development Environment**. This container is designed for AI-assisted coding with remote access capabilities.

### **Container Details:**
- **OS**: Ubuntu 22.04
- **User**: `claude` (non-root)
- **Working Directory**: `/home/claude/workspace`
- **SSH Access**: Available on port 5222
- **Web Hosting**: Multiple ports available for web applications

## 🌐 **Network Access**

### **Port Mappings (Host → Container):**
| Host Port | Container Port | Purpose | Status |
|-----------|----------------|---------|---------|
| 5222 | 22 | SSH Access | Always Available |
| 5300 | 3000 | Welcome App (PM2 Management) | Always Running |
| 5301-5320 | 3001-3020 | Additional Apps | Available for New Apps |
| 5500 | 5000 | Flask Apps | Available for Python Apps |
| 5800 | 8000 | Django Apps | Available for Python Apps |
| 5808 | 8080 | Alternative Web | Available for Any Web Server |

### **Access URLs:**
- **Local Access**: `http://localhost:5300` (from host machine)
- **Docker Network**: `http://172.20.0.2:3000` (from other containers)
- **Tailscale Network**: `http://[tailscale-ip]:5300` (from mobile devices)

## 🚀 **Process Management with PM2**

### **PM2 is installed globally** and should be used to manage all web applications:

```bash
# Start a new app
pm2 start app.js --name "my-app" --watch

# Start with specific port
pm2 start app.js --name "react-app" -- --port 3000

# List running apps
pm2 list

# Monitor apps
pm2 monit

# Stop an app
pm2 stop my-app

# Restart an app
pm2 restart my-app

# Delete an app
pm2 delete my-app

# Save PM2 configuration
pm2 save

# Restore PM2 configuration on startup
pm2 startup
```

### **PM2 Ecosystem File Example:**
Create `ecosystem.config.js` in your project:
```javascript
module.exports = {
  apps: [{
    name: 'react-app',
    script: 'npm',
    args: 'start',
    cwd: './react-app',
    env: {
      PORT: 3000,
      NODE_ENV: 'development'
    }
  }, {
    name: 'flask-app',
    script: 'python3',
    args: 'app.py',
    cwd: './flask-app',
    env: {
      FLASK_ENV: 'development',
      FLASK_APP: 'app.py'
    }
  }]
}
```

## 📁 **Project Structure**

```
/home/claude/workspace/
├── .claude/                    # Claude configuration
│   ├── settings.json          # Project settings
│   └── agents/                # Custom subagents
├── projects/                   # Your development projects
│   ├── react-app/             # React application
│   ├── flask-app/             # Flask application
│   └── django-app/            # Django application
├── ecosystem.config.js         # PM2 configuration
└── README.md                  # Project documentation
```

## 🛠️ **Development Workflow**

### **1. Creating New Projects:**
**IMPORTANT**: Always use unique ports for each app. Port 5300 is reserved for the Welcome App.

```bash
# React App (with hot reload) - Use port 5301
npx create-react-app projects/react-app
cd projects/react-app
# Update package.json to use port 3001 (maps to host 5301)
pm2 start npm --name "react-app" -- start -- --port 3001

# Next.js App (with hot reload) - Use port 5302
npx create-next-app@latest projects/next-app
cd projects/next-app
# Update next.config.js to use port 3002 (maps to host 5302)
pm2 start npm --name "next-app" -- run dev -- --port 3002

# Express App (with hot reload) - Use port 5303
mkdir -p projects/express-app && cd projects/express-app
npm init -y && npm install express nodemon
# Create app.js with PORT=3003 and package.json with dev script
pm2 start npm --name "express-app" -- run dev

# Flask App - Use port 5500
mkdir -p projects/flask-app
cd projects/flask-app
# Create app.py with app.run(host='0.0.0.0', port=5000)
pm2 start app.py --name "flask-app" --interpreter python3

# Django App - Use port 5800
django-admin startproject django-app projects/django-app
cd projects/django-app
pm2 start manage.py --name "django-app" -- runserver 0.0.0.0:8000
```

### **2. Managing Multiple Apps:**
```bash
# Start all apps from ecosystem file
pm2 start ecosystem.config.js

# Monitor all apps
pm2 monit

# View logs
pm2 logs

# View specific app logs
pm2 logs react-app
```

### **3. Development Best Practices:**
- **Always use PM2** for process management
- **Use `npm run dev`** for hot reloading during development
- **Bind to 0.0.0.0** for external access
- **Use unique ports** for each app (5301-5320 for Node.js apps, 5500 for Flask, 5800 for Django)
- **Port 5300 is reserved** for the Welcome App - never use it for new apps
- **Save PM2 configuration** after setup
- **Monitor app health** regularly
- **Enable file watching** for automatic reloads
- **Check port availability** before starting new apps

## 🔧 **Available Tools & Commands**

### **Node.js/NPM:**
- Node.js 18 (LTS)
- npm and npx
- PM2 for process management

### **Python:**
- Python 3
- pip for package management
- Virtual environments supported

### **Development Tools:**
- Git for version control
- SSH for remote access
- curl for testing APIs
- wget for downloads

### **System Tools:**
- sudo access (claude user)
- File system access
- Network configuration

## 📱 **Mobile Development Features**

### **iPhone Access:**
1. **SSH Access**: Use Termius app with container IP
2. **Web Access**: Open Safari to `http://[ip]:5300`
3. **Real-time Testing**: Changes appear instantly on mobile

### **Tailscale Integration:**
- **Secure VPN-like access** from any device
- **Private network** - no public exposure
- **Encrypted traffic** - all communication secure

## 🎯 **Your Role & Responsibilities**

### **As an AI Assistant in this environment:**

1. **Help with Development:**
   - Create and modify web applications
   - Debug issues and provide solutions
   - Optimize code and performance
   - Implement new features

2. **Process Management:**
   - Use PM2 for all web applications
   - Ensure proper port configuration
   - Monitor app health and performance
   - Handle app restarts and updates

3. **Mobile Development:**
   - Create mobile-responsive applications
   - Test on different screen sizes
   - Optimize for mobile performance
   - Ensure cross-device compatibility

4. **Environment Management:**
   - Maintain clean project structure
   - Manage dependencies properly
   - Keep applications running smoothly
   - Document setup and configuration

## 🔒 **Security & Permissions**

### **File Access:**
- **Allowed**: All files in `/home/claude/workspace`
- **Restricted**: System files outside workspace
- **Protected**: SSH keys and configuration files

### **Network Access:**
- **Local**: Full access to container network
- **External**: Through Tailscale only
- **Ports**: Only exposed ports are accessible

## 📋 **Quick Reference Commands**

```bash
# Check container status
docker ps

# SSH into container
ssh claude@localhost -p 5222

# View PM2 processes
pm2 list

# Start a new React app (use unique port)
npx create-react-app my-app && cd my-app && pm2 start npm --name "my-app" -- start -- --port 3001

# Test web app access
curl http://localhost:5300  # Welcome App
curl http://localhost:5301  # Your new app

# View container logs
docker-compose logs claude-cli

# Check Tailscale status
tailscale status

# Check available ports
netstat -tulpn | grep LISTEN
```

## 🎉 **Ready to Code!**

You now have a complete understanding of your environment. You can:
- Create web applications with any framework
- Manage them with PM2
- Access them from mobile devices
- Collaborate with AI assistance
- Maintain persistent development environment

**Remember**: Always use PM2 for process management and bind applications to `0.0.0.0` for external access!
