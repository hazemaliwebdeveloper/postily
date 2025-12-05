@echo off
REM Quick Start - Postiz Application
REM This script handles everything needed to run the app

setlocal enabledelayedexpansion
color 0A
cls

echo.
echo ╔══════════════════════════════════════════╗
echo ║   POSTIZ - START APPLICATION             ║
echo ╚══════════════════════════════════════════╝
echo.

REM Step 1: Install if needed
echo [STEP 1/4] Checking dependencies...
if not exist "node_modules" (
    echo Installing dependencies...
    call pnpm install
) else (
    echo ✓ Dependencies already installed
)

echo.
echo [STEP 2/4] Setting up database...
call pnpm run prisma-generate >nul 2>&1
call pnpm run prisma-db-push >nul 2>&1
echo ✓ Database ready

echo.
echo [STEP 3/4] Building extension...
call cd apps\extension
call pnpm run build:chrome >nul 2>&1
call cd ..\..
echo ✓ Extension built

echo.
echo ╔══════════════════════════════════════════╗
echo ║   STARTING SERVICES                      ║
echo ╚══════════════════════════════════════════╝
echo.

REM Start backend
echo [*] Starting Backend (port 3000)...
start "Backend" cmd /k "cd /d "%cd%\apps\backend" && pnpm run dev"
timeout /t 3 >nul

REM Start frontend
echo [*] Starting Frontend (port 4200)...
start "Frontend" cmd /k "cd /d "%cd%\apps\frontend" && pnpm run dev"
timeout /t 3 >nul

REM Start extension watch
echo [*] Starting Extension (watch mode)...
start "Extension" cmd /k "cd /d "%cd%\apps\extension" && pnpm run dev:chrome"
timeout /t 3 >nul

echo.
echo ╔══════════════════════════════════════════╗
echo ║   APPLICATION RUNNING                    ║
echo ╚══════════════════════════════════════════╝
echo.

echo URLs:
echo   Frontend: http://localhost:4200
echo   Backend:  http://localhost:3000
echo.

echo Next: Load extension in Chrome
echo   1. Open Chrome
echo   2. Go to: chrome://extensions
echo   3. Enable "Developer mode" (top right)
echo   4. Click "Load unpacked"
echo   5. Select: apps\extension\dist
echo   6. Click "Open"
echo.

echo Servers will continue running in separate windows.
echo Close any window to stop that service.
echo.
pause
