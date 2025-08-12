FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    openssh-server \
    sudo \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18 (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Install PM2 globally for process management
RUN npm install -g pm2

# Create a user for SSH access
RUN useradd -m -s /bin/bash claude && \
    usermod -aG sudo claude && \
    echo "claude:claude" | chpasswd

# Create SSH directory and set permissions for claude user
RUN mkdir -p /home/claude/.ssh && \
    chmod 700 /home/claude/.ssh && \
    touch /home/claude/.ssh/authorized_keys && \
    chmod 600 /home/claude/.ssh/authorized_keys && \
    chown -R claude:claude /home/claude/.ssh

# Configure SSH for both key-based and password authentication
RUN mkdir -p /var/run/sshd && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "AllowUsers claude" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config && \
    echo "HostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config && \
    echo "HostKey /etc/ssh/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config && \
    echo "HostKey /etc/ssh/ssh_host_ed25519_key" >> /etc/ssh/sshd_config

# Install Claude code CLI
RUN npm install -g @anthropic-ai/claude-code

# Install Tailscale
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list
RUN apt-get update && apt-get install -y tailscale

# Create a working directory
WORKDIR /home/claude

# Switch to claude user
USER claude

# Create Claude configuration directory
RUN mkdir -p /home/claude/.claude

# Configure bash profile to auto-launch Claude
RUN echo '#!/bin/bash\n\
# Mobile AI Agent - Auto-launch Claude CLI\n\
\n\
# Set up aliases for easy access\n\
alias bash-shell="exec bash"\n\
alias claude-start="claude --dangerously-skip-permissions"\n\
alias pm2-status="pm2 list"\n\
alias pm2-monitor="pm2 monit"\n\
alias pm2-logs="pm2 logs"\n\
\n\
# Only auto-launch if this is an interactive SSH session\n\
if [[ $- == *i* ]] && [[ -t 0 ]] && [[ -t 1 ]]; then\n\
    # Check if we are in an SSH session\n\
    if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then\n\
        echo "🚀 Mobile AI Agent Container"\n\
        echo "📁 Working directory: $(pwd)"\n\
        echo "🔧 Environment: Claude CLI with PM2 Process Management"\n\
        echo "📋 Memory files: CLAUDE.md loaded"\n\
        echo "🌐 Web apps: Available on ports 5300-5305, 5500, 5800"\n\
        echo ""\n\
        echo "Starting Claude CLI with full permissions..."\n\
        echo "Type /exit to return to bash shell"\n\
        echo "Use: ssh claude@localhost -p 5222 -t bash-shell for direct bash access"\n\
        echo ""\n\
        exec claude --dangerously-skip-permissions\n\
    fi\n\
fi\n\
\n\
# If not SSH or not interactive, continue with normal bash\n\
' > /home/claude/.bashrc

# Create a simple test script
RUN echo '#!/bin/bash\necho "Claude code CLI is ready!"\necho "You can now use: claude --help"\nclaude --help' > /home/claude/test-claude.sh && \
    chmod +x /home/claude/test-claude.sh

# Configure automatic Claude launch
RUN echo '#!/bin/bash\n\
# Auto-launch Claude CLI with skip permissions\n\
if [ -t 0 ] && [ -t 1 ]; then\n\
    echo "🚀 Launching Claude CLI..."\n\
    echo "📁 Working directory: $(pwd)"\n\
    echo "🔧 Environment: Mobile AI Agent Container"\n\
    echo "📋 Memory files loaded: CLAUDE.md"\n\
    echo ""\n\
    exec claude --dangerously-skip-permissions\n\
else\n\
    # If not interactive, just start bash\n\
    exec bash\n\
fi' > /home/claude/auto-claude.sh && chmod +x /home/claude/auto-claude.sh

# Switch back to root for SSH service
USER root

# Create startup script
RUN echo '#!/bin/bash\n\
\n\
# Setup persistent SSH host keys\n\
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then\n\
    echo "Generating SSH host keys..."\n\
    ssh-keygen -A\n\
    if [ -d /etc/ssh/host-keys ]; then\n\
        cp /etc/ssh/ssh_host_* /etc/ssh/host-keys/\n\
    fi\n\
elif [ -d /etc/ssh/host-keys ]; then\n\
    echo "Using persistent SSH host keys..."\n\
    cp /etc/ssh/host-keys/ssh_host_* /etc/ssh/\n\
    chmod 600 /etc/ssh/ssh_host_*\n\
fi\n\
\n\
# Start Tailscale\n\
if [ ! -z "$TS_AUTHKEY" ]; then\n\
    echo "Starting Tailscale..."\n\
    tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &\n\
    sleep 2\n\
    tailscale up --authkey=$TS_AUTHKEY --hostname=claude-cli-container\n\
    echo "Tailscale IP: $(tailscale ip)"\n\
else\n\
    echo "No Tailscale auth key provided, skipping Tailscale setup"\n\
fi\n\
\n\
# Setup and start PM2 with welcome app\n\
echo "Setting up PM2 and welcome app..."\n\
cd /home/claude/workspace\n\
\n\
# Install dependencies for welcome app\n\
if [ -d "./projects/welcome-app" ]; then\n\
    echo "Installing welcome app dependencies..."\n\
    su - claude -c "cd /home/claude/workspace/projects/welcome-app && npm install"\n\
fi\n\
\n\
# Setup PM2 startup script\n\
echo "Setting up PM2 startup..."\n\
su - claude -c "pm2 startup"\n\
\n\
# Start PM2 processes\n\
echo "Starting PM2 processes..."\n\
if [ -f "ecosystem.config.js" ]; then\n\
    su - claude -c "cd /home/claude/workspace && pm2 start ecosystem.config.js --env development"\n\
    echo "PM2 processes started successfully"\n\
    su - claude -c "pm2 list"\n\
else\n\
    echo "ecosystem.config.js not found, starting welcome app manually..."\n\
    su - claude -c "cd /home/claude/workspace/projects/welcome-app && pm2 start server.js --name welcome-app"\n\
fi\n\
\n\
# Start SSH service\n\
echo "Starting SSH service..."\n\
exec /usr/sbin/sshd -D' > /startup.sh && chmod +x /startup.sh

# Expose SSH port
EXPOSE 22

# Start with custom startup script
CMD ["/startup.sh"] 