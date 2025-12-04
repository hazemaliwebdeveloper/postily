@echo off
REM Start local development environment

echo.
echo ================================
echo Starting Local Development Setup
echo ================================
echo.

REM Check if Docker is available
echo [1/5] Checking Docker...
docker ps >nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: Docker is not running!
    echo Please start Docker Desktop and try again.
    echo.
    echo Starting Docker Desktop...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    echo Waiting 30 seconds for Docker to start...
    timeout /t 30 /nobreak
)

REM Start containers
echo [2/5] Starting Docker containers...
docker compose -f docker-compose.dev.yaml up -d
if errorlevel 1 (
    echo ERROR: Failed to start Docker containers
    exit /b 1
)

echo Docker containers started!
echo - PostgreSQL: localhost:5432
echo - Redis: localhost:6379
echo.

REM Install dependencies
echo [3/5] Installing dependencies...
call pnpm install
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    exit /b 1
)

echo Dependencies installed!
echo.

REM Generate Prisma
echo [4/5] Generating Prisma client...
call pnpm run prisma-generate
if errorlevel 1 (
    echo ERROR: Failed to generate Prisma client
    exit /b 1
)

echo Prisma client generated!
echo.

REM Start dev server
echo [5/5] Starting development servers...
echo.
echo ================================
echo All services starting...
echo ================================
echo.
echo Frontend: http://localhost:4200
echo Backend: http://localhost:3000
echo.

call pnpm run dev
