@echo off
title Pozmixal - Working Startup
color 0B

echo ========================================
echo   POZMIXAL - WORKING STARTUP
echo ========================================
echo.

REM Copy environment configuration
echo [1/5] Setting up environment...
copy .env.local .env >nul
if not exist .env (
    echo ERROR: Could not create .env file
    pause
    exit /b 1
)

REM Set memory optimization
set NODE_OPTIONS=--max-old-space-size=4096 --max-semi-space-size=512
echo Memory configuration: %NODE_OPTIONS%

echo [2/5] Verifying Docker services...
docker compose -f docker-compose.dev.yaml up -d >nul

echo [3/5] Starting Backend (this may take 2-3 minutes)...
echo Backend will be available at: http://localhost:3000
start "Pozmixal Backend" cmd /k "title Pozmixal Backend && cd apps\backend && set NODE_OPTIONS=%NODE_OPTIONS% && pnpm run dev"

echo [4/5] Waiting for backend initialization...
timeout /t 20 /nobreak >nul

echo [5/5] Starting Frontend...
echo Frontend will be available at: http://localhost:4200
start "Pozmixal Frontend" cmd /k "title Pozmixal Frontend && cd apps\frontend && set NODE_OPTIONS=%NODE_OPTIONS% && pnpm run dev"

echo.
echo ========================================
echo   STARTUP COMPLETE
echo ========================================
echo.
echo Services are starting in separate windows:
echo.
echo Backend:  http://localhost:3000 (starting...)
echo Frontend: http://localhost:4200 (starting...)
echo.
echo Please wait 2-3 minutes for both services to fully initialize.
echo Check the opened windows for startup progress.
echo.
echo Once running, you can access the application at:
echo http://localhost:4200
echo.
pause