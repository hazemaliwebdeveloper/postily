@echo off
REM POZMIXAL - Quick Start Launcher (Windows Batch)
REM This batch file provides a simple menu for starting the application

setlocal enabledelayedexpansion
cd /d "%~dp0"

:menu
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        POZMIXAL - LOCAL DEVELOPMENT LAUNCHER                  ║
echo ║     Enterprise Social Media Orchestration Platform            ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Select an option:
echo.
echo   [1] Quick Start (Full Setup - First Time)
echo   [2] Start Application (Docker + Dev Servers)
echo   [3] Start Docker Only (PostgreSQL + Redis)
echo   [4] View Backend Logs
echo   [5] View Frontend Logs
echo   [6] Stop All Services
echo   [7] Database Management (pgAdmin)
echo   [8] Redis Management (RedisInsight)
echo   [9] Open Application in Browser
echo   [0] Exit
echo.
set /p choice="Enter your choice (0-9): "

if "%choice%"=="1" goto quick_start
if "%choice%"=="2" goto start_app
if "%choice%"=="3" goto start_docker
if "%choice%"=="4" goto backend_logs
if "%choice%"=="5" goto frontend_logs
if "%choice%"=="6" goto stop_services
if "%choice%"=="7" goto pgadmin
if "%choice%"=="8" goto redisinsight
if "%choice%"=="9" goto open_browser
if "%choice%"=="0" goto end

echo Invalid choice! Press any key to continue...
pause > nul
goto menu

:quick_start
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        Starting Full Setup (First Time Setup)                 ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Check prerequisites
echo [*] Checking prerequisites...
node --version > nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js not found! Please install Node.js 22+
    pause
    goto menu
)
echo [OK] Node.js found

pnpm --version > nul 2>&1
if errorlevel 1 (
    echo [ERROR] pnpm not found! Installing...
    npm install -g pnpm
)
echo [OK] pnpm found

docker --version > nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker not found! Please install Docker Desktop
    pause
    goto menu
)
echo [OK] Docker found

REM Run PowerShell setup script
echo.
echo [*] Running setup script...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup-local.ps1"
goto menu

:start_app
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        Starting Pozmixal Application                           ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Check if Docker is running
docker ps > nul 2>&1
if errorlevel 1 (
    echo [WARNING] Docker is not running
    echo [*] Starting Docker containers...
    docker compose -f docker-compose.dev.yaml up -d
    timeout /t 5 /nobreak
)

echo [*] Starting development servers...
echo.
echo Services will be available at:
echo   Frontend:  http://localhost:4200
echo   Backend:   http://localhost:3000
echo   Database:  localhost:5432
echo   Redis:     localhost:6379
echo.
echo Press Ctrl+C to stop all services
echo.

pnpm run dev
goto menu

:start_docker
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        Starting Docker Services                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

docker compose -f docker-compose.dev.yaml up -d

if errorlevel 1 (
    echo [ERROR] Failed to start Docker services
    pause
    goto menu
)

echo.
echo [OK] Services started:
docker compose -f docker-compose.dev.yaml ps
echo.
echo Press any key to continue...
pause > nul
goto menu

:backend_logs
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        Backend Logs (Press Ctrl+C to stop)                    ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

pnpm run dev:backend
goto menu

:frontend_logs
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        Frontend Logs (Press Ctrl+C to stop)                   ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

pnpm run dev:frontend
goto menu

:stop_services
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        Stopping Services                                       ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

echo [*] Stopping Docker containers...
docker compose -f docker-compose.dev.yaml down

echo.
echo [OK] All services stopped
echo.
echo Press any key to continue...
pause > nul
goto menu

:pgadmin
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        pgAdmin (Database Management)                           ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Check if pgAdmin container is running
docker ps | findstr pgadmin > nul
if errorlevel 1 (
    echo [WARNING] pgAdmin is not running
    echo [*] Starting pgAdmin...
    docker compose -f docker-compose.dev.yaml up -d pozmixal-pg-admin
    timeout /t 3 /nobreak
)

echo.
echo [OK] Opening pgAdmin in browser...
echo URL: http://localhost:8081
echo Email: admin@admin.com
echo Password: admin
echo.

start http://localhost:8081
timeout /t 2 /nobreak

echo Press any key to continue...
pause > nul
goto menu

:redisinsight
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        RedisInsight (Cache Management)                         ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Check if RedisInsight container is running
docker ps | findstr redisinsight > nul
if errorlevel 1 (
    echo [WARNING] RedisInsight is not running
    echo [*] Starting RedisInsight...
    docker compose -f docker-compose.dev.yaml up -d pozmixal-redisinsight
    timeout /t 3 /nobreak
)

echo.
echo [OK] Opening RedisInsight in browser...
echo URL: http://localhost:8001
echo.

start http://localhost:8001
timeout /t 2 /nobreak

echo Press any key to continue...
pause > nul
goto menu

:open_browser
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        Opening Application in Browser                          ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

echo [*] Opening http://localhost:4200...
start http://localhost:4200

timeout /t 2 /nobreak
goto menu

:end
cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        Goodbye!                                                 ║
echo ║                                                                 ║
echo ║  For more information, see LOCAL_SETUP_COMPLETE.md             ║
echo ║                                                                 ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
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
