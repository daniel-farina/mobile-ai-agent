# Scripts

This folder contains automation scripts for the Claude CLI Container.

## 📋 Available Scripts

### Setup Scripts

#### `setup.sh` (Linux/Mac)
Comprehensive setup script that:
- ✅ Checks Docker installation
- ✅ Validates environment variables
- ✅ Sets up SSH keys automatically
- ✅ Builds and starts the container
- ✅ Displays connection information

**Usage:**
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

#### `setup.ps1` (Windows)
PowerShell version of the setup script with the same functionality.

**Usage:**
```powershell
.\scripts\setup.ps1
```

### Example App Scripts

#### `start-example-app.sh` (Linux/Mac)
Starts the included example web application to test your setup.

**Usage:**
```bash
chmod +x scripts/start-example-app.sh
./scripts/start-example-app.sh
```

#### `start-example-app.ps1` (Windows)
PowerShell version for starting the example app.

**Usage:**
```powershell
.\scripts\start-example-app.ps1
```

### SSH Key Scripts

#### `setup-ssh-keys.sh` (Linux/Mac)
Legacy script for SSH key setup (now integrated into main setup script).

#### `setup-ssh-keys.ps1` (Windows)
Legacy PowerShell script for SSH key setup (now integrated into main setup script).

## 🚀 Quick Start

1. **Configure environment variables:**
   ```bash
   cp ../env.example ../.env
   # Edit .env with your API keys
   ```

2. **Run setup script:**
   ```bash
   # Linux/Mac
   chmod +x setup.sh && ./setup.sh
   
   # Windows
   .\setup.ps1
   ```

3. **Start example app (optional):**
   ```bash
   # Linux/Mac
   chmod +x start-example-app.sh && ./start-example-app.sh
   
   # Windows
   .\start-example-app.ps1
   ```

## 🔧 Script Features

- **Error handling** - Scripts exit on errors with helpful messages
- **Validation** - Checks prerequisites and configuration
- **Colored output** - Easy to read status messages
- **Cross-platform** - Works on Windows, Linux, and macOS
- **Automated** - Minimal manual intervention required

## 📝 Requirements

- Docker and Docker Compose installed
- `.env` file configured with API keys
- Internet connection for container build 