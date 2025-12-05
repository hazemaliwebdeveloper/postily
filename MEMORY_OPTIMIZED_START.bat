@echo off
title Pozmixal Memory Optimized Startup
color 0A

echo.
echo ========================================
echo  POZMIXAL - MEMORY OPTIMIZED STARTUP
echo ========================================
echo.

REM Check system memory
echo [1/8] Checking system memory...
for /f "tokens=2 delims==" %%i in ('wmic OS get TotalVisibleMemorySize /value') do set /a mem=%%i/1024
echo System RAM: %mem% MB
echo.

REM Set optimal memory configuration based on available RAM
if %mem% GEQ 16384 (
    echo High-memory system detected: Allocating 8GB to Node.js
    set NODE_OPTIONS=--max-old-space-size=8192 --max-semi-space-size=1024 --expose-gc
) else if %mem% GEQ 8192 (
    echo Medium-memory system detected: Allocating 4GB to Node.js
    set NODE_OPTIONS=--max-old-space-size=4096 --max-semi-space-size=512
) else (
    echo Low-memory system detected: Allocating 2GB to Node.js
    set NODE_OPTIONS=--max-old-space-size=2048 --max-semi-space-size=256
)

echo Memory configuration: %NODE_OPTIONS%
echo.

echo [2/8] Checking Docker Desktop...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running. Please start Docker Desktop.
    echo Press any key to open Docker Desktop...
    pause >nul
    start "" "Docker Desktop"
    echo Waiting for Docker to start...
    timeout /t 30 /nobreak >nul
)
echo Docker is ready.
echo.

echo [3/8] Stopping any existing containers...
docker compose -f docker-compose.dev.yaml down >nul 2>&1
echo.

echo [4/8] Starting optimized Docker containers...
docker compose -f docker-compose.dev.yaml up -d
if errorlevel 1 (
    echo ERROR: Failed to start containers. Check Docker Desktop.
    pause
    exit /b 1
)
echo.

echo [5/8] Waiting for databases to initialize...
timeout /t 15 /nobreak >nul
echo.

echo [6/8] Installing dependencies with memory optimization...
set npm_config_cache=.npm-cache
pnpm install --no-frozen-lockfile
if errorlevel 1 (
    echo ERROR: Failed to install dependencies.
    pause
    exit /b 1
)
echo.

echo [7/8] Setting up database...
echo Generating Prisma client...
pnpm run prisma-generate
if errorlevel 1 (
    echo ERROR: Failed to generate Prisma client.
    pause
    exit /b 1
)

echo Pushing database schema...
pnpm run prisma-db-push
if errorlevel 1 (
    echo WARNING: Database push failed. This might be normal for first run.
)
echo.

echo [8/8] Starting application with memory optimization...
echo.
echo ========================================
echo  APPLICATION STARTING
echo ========================================
echo.
echo Memory settings: %NODE_OPTIONS%
echo Frontend: http://localhost:4200
echo Backend:  http://localhost:3000
echo.
echo Press Ctrl+C to stop all services
echo.

REM Start the application
pnpm run dev

echo.
echo Application stopped. Press any key to exit...
pause >nul