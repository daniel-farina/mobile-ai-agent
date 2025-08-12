# Projects Directory

This directory contains all your development projects managed by PM2.

## 🚀 **Quick Start**

### **Creating a New React App:**
```bash
cd /home/claude/workspace/projects
npx create-react-app my-react-app
cd my-react-app
pm2 start npm --name "my-react-app" -- start
```

### **Creating a New Flask App:**
```bash
cd /home/claude/workspace/projects
mkdir my-flask-app
cd my-flask-app
# Create app.py and requirements.txt
pm2 start app.py --name "my-flask-app" --interpreter python3
```

### **Creating a New Next.js App:**
```bash
cd /home/claude/workspace/projects
npx create-next-app@latest my-next-app
cd my-next-app
pm2 start npm --name "my-next-app" -- run dev
```

### **Creating a New Django App:**
```bash
cd /home/claude/workspace/projects
django-admin startproject my-django-app
cd my-django-app
pm2 start manage.py --name "my-django-app" -- runserver 0.0.0.0:8000
```

## 📁 **Project Structure**

Each project should follow this structure:
```
project-name/
├── README.md              # Project documentation
├── package.json           # Node.js dependencies (if applicable)
├── requirements.txt       # Python dependencies (if applicable)
├── .env.example          # Environment variables template
├── src/                  # Source code
├── public/               # Static files (for web apps)
└── tests/                # Test files
```

## 🔧 **PM2 Management**

### **View All Running Apps:**
```bash
pm2 list
```

### **Monitor Apps:**
```bash
pm2 monit
```

### **View Logs:**
```bash
pm2 logs
pm2 logs app-name
```

### **Restart App:**
```bash
pm2 restart app-name
```

### **Stop App:**
```bash
pm2 stop app-name
```

### **Delete App:**
```bash
pm2 delete app-name
```

## 🌐 **Access Your Apps**

### **Local Access:**
- React/Node.js: `http://localhost:5300`
- Flask: `http://localhost:5500`
- Django: `http://localhost:5800`

### **Mobile Access (via Tailscale):**
- React/Node.js: `http://[tailscale-ip]:5300`
- Flask: `http://[tailscale-ip]:5500`
- Django: `http://[tailscale-ip]:5800`

## 📱 **Mobile Development Tips**

1. **Always bind to 0.0.0.0** for external access
2. **Test on mobile devices** regularly
3. **Use responsive design** principles
4. **Optimize for touch interactions**
5. **Ensure fast loading times**

## 🔒 **Security Notes**

- Never commit API keys or secrets
- Use environment variables for configuration
- Keep dependencies updated
- Follow security best practices for your framework

## 📚 **Useful Commands**

```bash
# Check container status
docker ps | grep claude-cli-container

# SSH into container
ssh claude@localhost

# View container logs
docker-compose logs claude-cli

# Check Tailscale status
docker exec claude-cli-container tailscale status
```
