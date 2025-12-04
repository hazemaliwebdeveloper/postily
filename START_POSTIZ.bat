@echo off
cls
color 0A
title POZMIXAL - Application Launcher

echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                                                           ║
echo ║              🚀 POZMIXAL Application Startup 🚀             ║
echo ║                                                           ║
echo ║     All Premium Features Enabled (LOCAL DEVELOPMENT)     ║
echo ║                                                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.

REM Navigate to project root
cd /d c:\Users\it\Downloads\pozmixal\postily

echo [1] Checking dependencies...
timeout /t 2 /nobreak >nul

REM Check if node_modules exists
if not exist "node_modules" (
    echo [!] Installing dependencies...
    call pnpm install
    echo [✓] Dependencies installed
) else (
    echo [✓] Dependencies already installed
)

echo.
echo [2] Starting frontend server on port 4200...
echo.
echo Setting Node.js memory: 4GB
set NODE_OPTIONS=--max-old-space-size=4096

REM Navigate to frontend
cd apps\frontend

echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                                                           ║
echo ║          Frontend starting... (30-45 seconds)             ║
echo ║                                                           ║
echo ║   Once ready, open your browser:                         ║
echo ║   → http://localhost:4200                                ║
echo ║                                                           ║
echo ║   Features enabled:                                       ║
echo ║   ✓ All Premium Tiers                                     ║
echo ║   ✓ Teams Management                                      ║
echo ║   ✓ Webhooks & Auto Post                                  ║
echo ║   ✓ Sets & Signatures                                     ║
echo ║   ✓ Public API                                            ║
echo ║                                                           ║
echo ║   Press Ctrl+C to stop                                    ║
echo ║                                                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.

REM Start development server
call pnpm run dev

pause