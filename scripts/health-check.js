#!/usr/bin/env node

const https = require('https');
const http = require('http');
const { createConnection } = require('net');

// Color codes for terminal output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function checkEnvVariable(name, description) {
  const value = process.env[name];
  if (value) {
    log(`✓ ${description}: ${value}`, 'green');
    return true;
  } else {
    log(`✗ ${description} (${name}) not set`, 'red');
    return false;
  }
}

async function checkPortOpen(host, port, name) {
  return new Promise((resolve) => {
    const socket = createConnection({
      host,
      port,
      timeout: 3000
    });

    socket.on('connect', () => {
      log(`✓ ${name} port ${port} is open`, 'green');
      socket.destroy();
      resolve(true);
    });

    socket.on('timeout', () => {
      log(`✗ ${name} port ${port} timeout`, 'red');
      socket.destroy();
      resolve(false);
    });

    socket.on('error', (err) => {
      log(`✗ ${name} port ${port} error: ${err.message}`, 'red');
      resolve(false);
    });
  });
}

function makeRequest(url, method = 'GET', timeout = 5000) {
  return new Promise((resolve) => {
    const protocol = url.startsWith('https') ? https : http;
    const urlObj = new URL(url);

    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port,
      path: urlObj.pathname + urlObj.search,
      method: method,
      timeout: timeout,
      headers: {
        'Accept': 'application/json'
      }
    };

    const request = protocol.request(options, (response) => {
      let data = '';
      response.on('data', chunk => data += chunk);
      response.on('end', () => {
        resolve({
          status: response.statusCode,
          statusText: response.statusMessage,
          headers: response.headers
        });
      });
    });

    request.on('timeout', () => {
      request.destroy();
      resolve({ error: 'Timeout', status: null });
    });

    request.on('error', (error) => {
      resolve({ error: error.message, status: null });
    });

    request.end();
  });
}

async function checkBackendHealth() {
  log('\n=== Backend Health Check ===', 'cyan');
  
  const backendUrl = process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:3000';
  
  log(`Checking backend at: ${backendUrl}`);
  
  try {
    const response = await makeRequest(`${backendUrl}/health`);
    if (response.error) {
      log(`✗ Backend unreachable: ${response.error}`, 'red');
      return false;
    }
    
    if (response.status === 200 || response.status === 404) {
      log(`✓ Backend is responding (${response.status})`, 'green');
      return true;
    } else {
      log(`✗ Backend returned error status: ${response.status}`, 'red');
      return false;
    }
  } catch (error) {
    log(`✗ Backend check failed: ${error.message}`, 'red');
    return false;
  }
}

async function checkCORSConfiguration() {
  log('\n=== CORS Configuration Check ===', 'cyan');
  
  const frontendUrl = process.env.FRONTEND_URL;
  const backendUrl = process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:3000';
  
  if (!frontendUrl) {
    log(`✗ FRONTEND_URL not set - CORS will fail`, 'red');
    return false;
  }
  
  log(`Frontend URL: ${frontendUrl}`);
  log(`Backend URL: ${backendUrl}`);
  
  // Extract origin from frontend URL
  const frontendOrigin = new URL(frontendUrl).origin;
  log(`Allowed CORS origin: ${frontendOrigin}`, 'yellow');
  
  return true;
}

async function checkDatabaseConnection() {
  log('\n=== Database Connection Check ===', 'cyan');
  
  const databaseUrl = process.env.DATABASE_URL;
  
  if (!databaseUrl) {
    log(`✗ DATABASE_URL not set`, 'red');
    return false;
  }
  
  try {
    const url = new URL(databaseUrl);
    const host = url.hostname;
    const port = url.port || 5432;
    
    log(`Database: ${host}:${port}`);
    
    const isOpen = await checkPortOpen(host, port, 'PostgreSQL');
    return isOpen;
  } catch (error) {
    log(`✗ Invalid DATABASE_URL: ${error.message}`, 'red');
    return false;
  }
}

async function checkRedisConnection() {
  log('\n=== Redis Connection Check ===', 'cyan');
  
  const redisUrl = process.env.REDIS_URL;
  
  if (!redisUrl) {
    log(`✓ REDIS_URL not set - MockRedis will be used (development mode)`, 'yellow');
    return true;
  }
  
  try {
    const url = new URL(redisUrl);
    const host = url.hostname;
    const port = url.port || 6379;
    
    log(`Redis: ${host}:${port}`);
    
    const isOpen = await checkPortOpen(host, port, 'Redis');
    if (!isOpen) {
      log(`⚠ Redis not available - MockRedis will be used`, 'yellow');
      return true;
    }
    return true;
  } catch (error) {
    log(`✗ Invalid REDIS_URL: ${error.message}`, 'red');
    return false;
  }
}

async function runAllChecks() {
  log('\n╔════════════════════════════════════════════════╗', 'blue');
  log('║      POZMIXAL Health Check Script              ║', 'blue');
  log('╚════════════════════════════════════════════════╝\n', 'blue');
  
  log('=== Environment Variables ===', 'cyan');
  checkEnvVariable('FRONTEND_URL', 'Frontend URL');
  checkEnvVariable('NEXT_PUBLIC_BACKEND_URL', 'Backend URL');
  checkEnvVariable('DATABASE_URL', 'Database URL');
  checkEnvVariable('JWT_SECRET', 'JWT Secret');
  
  const checks = [
    await checkBackendHealth(),
    await checkCORSConfiguration(),
    await checkDatabaseConnection(),
    await checkRedisConnection()
  ];
  
  log('\n=== Summary ===', 'cyan');
  const passed = checks.filter(c => c).length;
  const total = checks.length;
  
  log(`Passed: ${passed}/${total}`, passed === total ? 'green' : 'yellow');
  
  if (passed === total) {
    log('\n✓ All checks passed! Your Pozmixal setup is ready.', 'green');
  } else {
    log('\n✗ Some checks failed. See details above.', 'red');
    log('\nFor help, check TROUBLESHOOTING.md', 'yellow');
  }
  
  process.exit(passed === total ? 0 : 1);
}

// Load environment variables from .env file
const dotenv = require('dotenv');
const fs = require('fs');

if (fs.existsSync('.env')) {
  const result = dotenv.config();
  if (result.error) {
    log(`Warning: Could not load .env file: ${result.error.message}`, 'yellow');
  }
}

runAllChecks().catch(error => {
  log(`\n✗ Health check failed: ${error.message}`, 'red');
  process.exit(1);
});
