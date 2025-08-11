# Claude CLI Docker Container with Tailscale

A Docker container that runs Claude CLI (Anthropic's AI coding assistant) with SSH access and web app hosting capabilities, all accessible through Tailscale's private network.

## 🚀 What This Does

This project creates a **portable development environment** where you can:

- **Run Claude CLI** for AI-assisted coding
- **SSH into the container** from any device on your Tailscale network
- **Host web applications** (React, Node.js, Python, etc.) on exposed ports
- **Access web apps** from your iPhone, laptop, or any device via Tailscale's private IP
- **Persist all your work** across container restarts

## 🎯 Perfect For

- **Mobile development** - Code on your laptop, preview on your iPhone
- **Remote development** - Access your dev environment from anywhere
- **AI-assisted coding** - Use Claude CLI with persistent state
- **Web app prototyping** - Quickly build and test web applications
- **Teaching/learning** - Share development environments securely

## 📋 Prerequisites

- **Docker** and **Docker Compose** installed
- **Tailscale account** (free at [tailscale.com](https://tailscale.com))
- **Anthropic API key** (get from [console.anthropic.com](https://console.anthropic.com))

## 🛠️ Quick Setup

### 1. Clone and Configure

```bash
git clone <your-repo-url>
cd claude-docker
```

### 2. Set Up Environment Variables

Copy the example environment file and add your API keys:

```bash
cp env.example .env
```

Edit `.env` with your actual keys:

```bash
# Claude CLI Configuration
ANTHROPIC_API_KEY=sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Tailscale Configuration  
TS_AUTHKEY=tskey-auth-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 3. Run Setup Script

**On Linux/Mac:**
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

**On Windows:**
```powershell
.\scripts\setup.ps1
```

This script will:
- ✅ Check Docker installation
- ✅ Validate environment variables
- ✅ Set up SSH keys automatically
- ✅ Build and start the container
- ✅ Display connection information

## 🔗 How to Connect

### SSH Access
```bash
# From any device on your Tailscale network
ssh claude@100.64.246.92
# No password required! (Uses SSH keys)
```

### Web App Access
```bash
# Your web apps will be available at:
http://100.64.246.92:3000  # React/Node.js apps
http://100.64.246.92:5000  # Flask apps  
http://100.64.246.92:8000  # Django apps
```

## 📱 iPhone Access

### SSH from iPhone
1. Install **Termius** from App Store
2. Add new SSH connection:
   - Host: `100.64.246.92`
   - Username: `claude`
   - Authentication: SSH Key (import your private key)
3. Connect and start coding!

### Web App Access from iPhone
1. Open **Safari**
2. Navigate to: `http://100.64.246.92:3000`
3. Your web app loads instantly!

## 🎨 Example: Creating a Web App

### Step 1: SSH into Container
```bash
ssh claude@100.64.246.92
cd /home/claude/workspace
```

### Step 2: Create a React App
```bash
npx create-react-app my-app
cd my-app
npm start
```

### Step 3: Access from iPhone
Open Safari and go to: `http://100.64.246.92:3000`

**That's it!** Your React app is now accessible from your iPhone through Tailscale's secure network.

## 🎨 Example App

Try the included example web app to test your setup:

**On Linux/Mac:**
```bash
./scripts/start-example-app.sh
```

**On Windows:**
```powershell
.\scripts\start-example-app.ps1
```

This starts a beautiful example web app that demonstrates:
- ✅ Web app hosting in the container
- ✅ Mobile-responsive design
- ✅ API endpoints
- ✅ Tailscale network access

## 🔧 Available Ports

The container exposes these ports for web applications:

| Port | Framework | Example Use |
|------|-----------|-------------|
| 3000 | React/Next.js | `npm start` |
| 3001-3005 | Additional apps | Custom Node.js apps |
| 5000 | Flask | `python app.py` |
| 8000 | Django | `python manage.py runserver 0.0.0.0:8000` |
| 8080 | Alternative | Any web server |

## 📁 Project Structure

```
claude-docker/
├── Dockerfile                 # Container definition
├── docker-compose.yml         # Container orchestration
├── .env                       # Your API keys (not in git)
├── env.example               # Example environment file
├── scripts/                   # Setup and utility scripts
│   ├── setup.sh              # Linux/Mac setup script
│   ├── setup.ps1             # Windows setup script
│   ├── start-example-app.sh  # Start example app (Linux/Mac)
│   ├── start-example-app.ps1 # Start example app (Windows)
│   ├── setup-ssh-keys.sh     # SSH key setup (legacy)
│   ├── setup-ssh-keys.ps1    # SSH key setup (legacy)
│   └── README.md             # Scripts documentation
├── workspace/                # Your projects (persists!)
│   ├── .ssh/                 # SSH keys (persists!)
│   ├── example-app/          # Example web application
│   └── .gitkeep             # Keep directory in git
├── claude-config/            # Claude settings (persists!)
├── tailscale-config/         # Tailscale data (persists!)
├── README.md                 # This comprehensive guide
├── .gitignore               # Git ignore rules
├── .dockerignore            # Docker ignore rules
└── LICENSE                   # MIT License
```

## 🔄 Data Persistence

**Everything persists across restarts:**

- ✅ **Workspace files** - All your projects and code
- ✅ **Claude configuration** - Settings and preferences  
- ✅ **Tailscale configuration** - Network settings
- ✅ **Installed packages** - npm, pip packages
- ✅ **SSH keys** - If mounted from host

**Your data is safe!** Container restarts, updates, and rebuilds won't lose your work.

### How Persistence Works

The container uses Docker volumes to persist data:

- `./workspace:/home/claude/workspace` - Your projects and code
- `./claude-config:/home/claude/.claude` - Claude CLI settings
- `./tailscale-config:/var/lib/tailscale` - Tailscale network data
- `./workspace/.ssh:/home/claude/.ssh:ro` - SSH keys for access

## 🛡️ Security

- **Private network only** - Accessible only via Tailscale
- **No public exposure** - No ports exposed to internet
- **Encrypted traffic** - All communication is encrypted
- **Access control** - Managed through Tailscale admin console
- **SSH key authentication** - No passwords required
- **Non-root user** - Container runs as `claude` user

## 🚀 Advanced Features

### Adding More Ports
```bash
# Edit docker-compose.yml and add:
ports:
  - "4000:4000"  # Your custom port

# Restart container
docker-compose down && docker-compose up -d
```

### Database Persistence
```yaml
# Add to docker-compose.yml volumes:
- ./postgres-data:/var/lib/postgresql/data
- ./redis-data:/data
```

### File Transfer
```bash
# From iPhone to container
scp file.txt claude@100.64.246.92:/home/claude/workspace/

# From container to iPhone  
scp claude@100.64.246.92:/home/claude/workspace/file.txt ./
```

## 📱 Mobile Development Workflow

### Complete Mobile Development Setup

1. **Install Tailscale on iPhone**
   - Download from App Store
   - Sign in with your account
   - Connect to your network

2. **SSH Access from iPhone**
   - Install Termius (SSH client)
   - Add connection to container IP
   - Import your SSH private key
   - Connect and start coding

3. **Web App Development**
   - SSH into container from laptop
   - Create/develop your web app
   - Start app on any exposed port
   - Access from iPhone browser instantly

4. **Real-time Testing**
   - Make changes on laptop
   - See updates immediately on iPhone
   - Test mobile responsiveness
   - Debug mobile-specific issues

### Mobile-Specific Tips

- **Use port 3000** for React apps (most common)
- **Bind to 0.0.0.0** in your apps for external access
- **Test on both Safari and Chrome** on iPhone
- **Use responsive design** for mobile-first development
- **Enable mobile debugging** in browser dev tools

## 🔍 Troubleshooting

### Container Won't Start
```bash
# Check logs
docker-compose logs claude-cli

# Rebuild if needed
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Can't Access Web Apps
```bash
# Check if app is running
docker exec claude-cli-container netstat -tlnp

# Check Tailscale status
docker exec claude-cli-container tailscale status

# Verify port exposure
docker port claude-cli-container
```

### SSH Connection Issues
```bash
# Check container status
docker ps

# Verify Tailscale IP
docker exec claude-cli-container tailscale ip

# Test SSH locally first
ssh claude@localhost -p 2222
```

### API Key Issues
```bash
# Test Claude CLI
docker exec claude-cli-container claude --help

# Check environment variable
docker exec claude-cli-container env | grep ANTHROPIC_API_KEY
```

### Tailscale Issues
```bash
# Check Tailscale status
docker exec claude-cli-container tailscale status

# Restart Tailscale
docker exec claude-cli-container tailscale down
docker exec claude-cli-container tailscale up --authkey=$TS_AUTHKEY
```

## 🔧 Configuration Details

### Docker Compose Configuration

The `docker-compose.yml` file configures:

- **Port mappings**: SSH (2222) and web app ports (3000-3005, 5000, 8000, 8080)
- **Volume mounts**: Persistent storage for workspace, config, and Tailscale data
- **Environment variables**: API keys passed to the container
- **Network capabilities**: Required for Tailscale networking

### Container Features

- **Ubuntu 22.04** base image
- **Node.js 18** (LTS) for modern JavaScript support
- **SSH server** for remote access
- **Claude CLI** pre-installed and configured
- **Tailscale** integrated for secure networking
- **Multiple web ports** exposed for app hosting

## 🔒 Security Considerations

### API Key Security
- **Never commit** `.env` files to version control
- **Use environment variables** instead of hardcoded keys
- **Rotate keys regularly** for production use
- **Monitor usage** through Anthropic and Tailscale dashboards

### Network Security
- **Private network only** - accessible only via Tailscale
- **No public exposure** - no ports exposed to internet
- **Encrypted traffic** - all communication is encrypted
- **Access control** - managed through Tailscale admin console

### Container Security
- **Non-root user** - container runs as `claude` user
- **Limited capabilities** - only necessary network permissions
- **Isolated environment** - containerized from host system

## 🔄 Updates and Maintenance

### Updating the Container
```bash
# Pull latest changes
git pull

# Rebuild container
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Updating Dependencies
```bash
# Update Node.js packages
docker exec claude-cli-container npm update -g

# Update Python packages
docker exec claude-cli-container pip install --upgrade pip
```

### Regular Maintenance
```bash
# Clean up Docker
docker system prune -f

# Check for updates
docker-compose pull
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- [Anthropic](https://anthropic.com) for Claude CLI
- [Tailscale](https://tailscale.com) for secure networking
- [Docker](https://docker.com) for containerization

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review container logs: `docker-compose logs claude-cli`
3. Verify your Tailscale and Anthropic API keys are correct
4. Ensure Docker has sufficient resources (CPU, memory, disk)

---

**Happy coding with Claude! 🚀📱** 