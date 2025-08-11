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

# Create a user for SSH access
RUN useradd -m -s /bin/bash claude && \
    usermod -aG sudo claude

# Configure SSH for key-based authentication only
RUN mkdir -p /var/run/sshd && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "AllowUsers claude" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config

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

# Create a simple test script
RUN echo '#!/bin/bash\necho "Claude code CLI is ready!"\necho "You can now use: claude --help"\nclaude --help' > /home/claude/test-claude.sh && \
    chmod +x /home/claude/test-claude.sh

# Switch back to root for SSH service
USER root

# Create startup script
RUN echo '#!/bin/bash\n\
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
# Start SSH service\n\
echo "Starting SSH service..."\n\
exec /usr/sbin/sshd -D' > /startup.sh && chmod +x /startup.sh

# Expose SSH port
EXPOSE 22

# Start with custom startup script
CMD ["/startup.sh"] 