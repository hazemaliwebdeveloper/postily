// PM2 Production Configuration
// Optimized for production deployment with clustering and monitoring

module.exports = {
  apps: [
    {
      name: 'pozmixal-frontend',
      script: './apps/frontend/server.js',
      cwd: '/app',
      instances: 'max', // Use all CPU cores
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        NODE_OPTIONS: '--max-old-space-size=4096'
      },
      max_memory_restart: '2G',
      min_uptime: '10s',
      max_restarts: 5,
      autorestart: true,
      watch: false,
      log_file: '/app/logs/frontend-combined.log',
      out_file: '/app/logs/frontend-out.log',
      error_file: '/app/logs/frontend-error.log',
      merge_logs: true,
      time: true
    },
    {
      name: 'pozmixal-backend',
      script: './apps/backend/dist/main.js',
      cwd: '/app',
      instances: 2, // Backend clustering
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
        NODE_OPTIONS: '--max-old-space-size=6144'
      },
      max_memory_restart: '4G',
      min_uptime: '10s',
      max_restarts: 5,
      autorestart: true,
      watch: false,
      log_file: '/app/logs/backend-combined.log',
      out_file: '/app/logs/backend-out.log',
      error_file: '/app/logs/backend-error.log',
      merge_logs: true,
      time: true
    },
    {
      name: 'pozmixal-workers',
      script: './apps/workers/dist/main.js',
      cwd: '/app',
      instances: 1, // Single worker instance
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        NODE_OPTIONS: '--max-old-space-size=2048'
      },
      max_memory_restart: '1G',
      min_uptime: '10s',
      max_restarts: 5,
      autorestart: true,
      watch: false,
      log_file: '/app/logs/workers-combined.log',
      out_file: '/app/logs/workers-out.log',
      error_file: '/app/logs/workers-error.log',
      merge_logs: true,
      time: true
    },
    {
      name: 'pozmixal-cron',
      script: './apps/cron/dist/main.js',
      cwd: '/app',
      instances: 1, // Single cron instance
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        NODE_OPTIONS: '--max-old-space-size=1024'
      },
      max_memory_restart: '512M',
      min_uptime: '10s',
      max_restarts: 5,
      autorestart: true,
      watch: false,
      cron_restart: '0 4 * * *', // Restart daily at 4 AM
      log_file: '/app/logs/cron-combined.log',
      out_file: '/app/logs/cron-out.log',
      error_file: '/app/logs/cron-error.log',
      merge_logs: true,
      time: true
    }
  ],

  // Deployment configuration
  deploy: {
    production: {
      user: 'deploy',
      host: ['pozmixal.com'],
      ref: 'origin/main',
      repo: 'git@github.com:yourusername/pozmixal.git',
      path: '/var/www/pozmixal',
      'post-deploy': 'pnpm install --prod && pm2 reload ecosystem.config.js --env production',
      env: {
        NODE_ENV: 'production'
      }
    }
  }
};