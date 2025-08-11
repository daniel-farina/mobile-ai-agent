module.exports = {
  apps: [
    {
      name: 'welcome-app',
      script: 'npm',
      args: 'start',
      cwd: './projects/welcome-app',
      env: {
        PORT: 3000,
        NODE_ENV: 'development'
      },
      watch: true,
      ignore_watch: ['node_modules'],
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M'
    },
    {
      name: 'react-example',
      script: 'npm',
      args: 'start',
      cwd: './projects/react-example',
      env: {
        PORT: 3001,
        NODE_ENV: 'development',
        BROWSER: 'none'
      },
      watch: true,
      ignore_watch: ['node_modules', 'build'],
      instances: 1,
      autorestart: true,
      max_memory_restart: '1G'
    },
    {
      name: 'flask-example',
      script: 'python3',
      args: 'app.py',
      cwd: './projects/flask-example',
      env: {
        FLASK_ENV: 'development',
        FLASK_APP: 'app.py',
        FLASK_DEBUG: '1'
      },
      watch: true,
      ignore_watch: ['__pycache__', 'venv'],
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M'
    },
    {
      name: 'django-example',
      script: 'python3',
      args: 'manage.py runserver 0.0.0.0:8000',
      cwd: './projects/django-example',
      env: {
        DJANGO_SETTINGS_MODULE: 'django_example.settings',
        DEBUG: 'True'
      },
      watch: true,
      ignore_watch: ['__pycache__', 'venv', 'migrations'],
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M'
    },
    {
      name: 'express-api',
      script: 'npm',
      args: 'run dev',
      cwd: './projects/express-api',
      env: {
        PORT: 3001,
        NODE_ENV: 'development'
      },
      watch: true,
      ignore_watch: ['node_modules'],
      instances: 1,
      autorestart: true,
      max_memory_restart: '1G'
    },
    {
      name: 'next-example',
      script: 'npm',
      args: 'run dev',
      cwd: './projects/next-example',
      env: {
        PORT: 3002,
        NODE_ENV: 'development'
      },
      watch: true,
      ignore_watch: ['node_modules', '.next'],
      instances: 1,
      autorestart: true,
      max_memory_restart: '1G'
    }
  ],

  deploy: {
    production: {
      user: 'claude',
      host: 'localhost',
      ref: 'origin/main',
      repo: 'git@github.com:user/repo.git',
      path: '/home/claude/workspace',
      'post-deploy': 'npm install && pm2 reload ecosystem.config.js --env production'
    }
  }
};
