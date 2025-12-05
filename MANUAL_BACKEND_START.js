// Manual Backend Startup Script
// This bypasses NestJS CLI compilation issues

const { spawn } = require('child_process');
const path = require('path');

console.log('🚀 MANUAL BACKEND STARTUP');
console.log('=========================');

// Set optimal memory configuration
process.env.NODE_OPTIONS = '--max-old-space-size=6144 --max-semi-space-size=1024';

console.log('Memory settings:', process.env.NODE_OPTIONS);
console.log('Working directory:', process.cwd());
console.log('Starting backend compilation...');

// Start the backend with detailed logging
const backend = spawn('npx', ['nest', 'start', '--watch'], {
  cwd: path.join(__dirname, 'apps', 'backend'),
  env: { ...process.env },
  stdio: ['inherit', 'pipe', 'pipe']
});

let compilationComplete = false;
let serverStarted = false;

backend.stdout.on('data', (data) => {
  const output = data.toString();
  console.log('📤 STDOUT:', output);
  
  if (output.includes('Compilation successful')) {
    compilationComplete = true;
    console.log('✅ COMPILATION COMPLETE!');
  }
  
  if (output.includes('Backend is running on') || output.includes('listening on')) {
    serverStarted = true;
    console.log('🎉 BACKEND STARTED SUCCESSFULLY!');
    console.log('API available at: http://localhost:3000');
    
    // Test the endpoint
    setTimeout(() => {
      console.log('Testing /user/self endpoint...');
      const http = require('http');
      const req = http.request('http://localhost:3000/user/self', (res) => {
        console.log('✅ Endpoint test status:', res.statusCode);
      });
      req.on('error', (err) => {
        console.log('⚠️ Endpoint test failed (expected - needs auth):', err.code);
      });
      req.end();
    }, 2000);
  }
});

backend.stderr.on('data', (data) => {
  const error = data.toString();
  console.log('📥 STDERR:', error);
  
  if (error.includes('Error:') || error.includes('Failed')) {
    console.log('❌ COMPILATION ERROR DETECTED');
  }
});

backend.on('close', (code) => {
  console.log('Backend process exited with code:', code);
  if (!serverStarted) {
    console.log('❌ Backend failed to start properly');
  }
});

backend.on('error', (err) => {
  console.error('❌ Backend startup error:', err);
});

// Timeout after 5 minutes
setTimeout(() => {
  if (!serverStarted) {
    console.log('⏰ Backend startup timeout (5 minutes)');
    console.log('Killing process and trying alternative approach...');
    backend.kill();
  }
}, 300000);

console.log('⏳ Waiting for backend compilation...');
console.log('This may take 2-5 minutes for first-time compilation.');
console.log('Watch for "Backend is running on" message.');