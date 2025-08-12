#!/bin/bash

# Mobile AI Agent - Development Tool Aliases

# Basic aliases
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"
alias ..="cd .."
alias ...="cd ../.."

# Colored output
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias diff="diff --color=auto"
alias ip="ip -color=auto"

# Git shortcuts
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline"
alias gd="git diff"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gpl="git pull"
alias gst="git stash"
alias gstp="git stash pop"

# PM2 shortcuts
alias pm2-status="pm2 list"
alias pm2-monitor="pm2 monit"
alias pm2-logs="pm2 logs"
alias pm2-restart="pm2 restart"
alias pm2-stop="pm2 stop"
alias pm2-start="pm2 start"

# Claude shortcuts
alias claude-start="claude --dangerously-skip-permissions"
alias bash-shell="exec bash"

# Network tools
alias myip="curl -s ifconfig.me"
alias ports="netstat -tulpn"
alias ping="ping -c 4"

# System tools
alias df="df -h"
alias du="du -h"
alias free="free -h"
alias top="htop"

# Development tools
alias node="node --version && echo 'Node.js is ready'"
alias npm="npm --version && echo 'npm is ready'"
alias python="python3 --version && echo 'Python is ready'"
alias pip="pip3 --version && echo 'pip is ready'"

# Container shortcuts
alias docker-ps="docker ps"
alias docker-logs="docker logs"
alias docker-exec="docker exec -it"

# Quick access to common directories
alias workspace="cd /home/claude/workspace"
alias projects="cd /home/claude/workspace/projects"
alias config="cd /home/claude/.claude"

echo "🚀 Mobile AI Agent aliases loaded!"
echo "📋 Available shortcuts: g, gs, ga, gc, gp, pm2-status, claude-start, etc."
