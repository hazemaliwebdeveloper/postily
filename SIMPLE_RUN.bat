@echo off
REM SIMPLE RUN - Start Postiz Application

setlocal enabledelayedexpansion
color 0A
cls

echo.
echo ╔══════════════════════════════════════════╗
echo ║   POSTIZ - SIMPLE START                  ║
echo ╚══════════════════════════════════════════╝
echo.

REM Check if already running
tasklist /FI "WINDOWTITLE eq *Backend*" 2>NUL | find /I /N "cmd.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo ✓ Services already running
    echo.
    echo Go to: http://localhost:4200
    echo.
    pause
    exit /b 0
)

REM Install dependencies if needed
if not exist "node_modules" (
    echo Installing dependencies (first time only)...
    call pnpm install
    if errorlevel 1 (
        echo ERROR: Failed to install
        pause
        exit /b 1
    )
    echo ✓ Dependencies installed
    echo.
)

REM Setup database
echo Preparing database...
call pnpm run prisma-generate >nul 2>&1
call pnpm run prisma-db-push >nul 2>&1
echo ✓ Database ready
echo.

REM Build extension
echo Building extension...
cd apps\extension
call pnpm run build:chrome >nul 2>&1
cd ..\..
echo ✓ Extension built
echo.

echo ═══════════════════════════════════════════
echo   STARTING SERVICES - DO NOT CLOSE WINDOWS
echo ═══════════════════════════════════════════
echo.

REM Start backend in new window (keep window open)
echo [*] Starting Backend (port 3000)...
start "Backend - Keep Open" cmd /k "cd /d "%cd%\apps\backend" && pnpm run dev"
ping localhost -n 3 >nul

REM Start frontend in new window (keep window open)
echo [*] Starting Frontend (port 4200)...
start "Frontend - Keep Open" cmd /k "cd /d "%cd%\apps\frontend" && pnpm run dev"
ping localhost -n 3 >nul

REM Start extension in new window (keep window open)
echo [*] Starting Extension...
start "Extension - Keep Open" cmd /k "cd /d "%cd%\apps\extension" && pnpm run dev:chrome"
ping localhost -n 3 >nul

echo.
echo ═══════════════════════════════════════════
echo   SERVICES STARTING
echo ═══════════════════════════════════════════
echo.
echo WAIT 10-15 seconds for services to fully start...
echo.
echo Then:
echo 1. Open browser: http://localhost:4200
echo 2. You should see the Postiz login page
echo.
echo DO NOT close the terminal windows!
echo Services will keep running in the background.
echo.
echo To load extension in Chrome:
echo   1. Go to: chrome://extensions
echo   2. Enable "Developer mode"
echo   3. Click "Load unpacked"
echo   4. Select: apps\extension\dist
echo   5. Done!
echo.
echo ═══════════════════════════════════════════
echo.
pause
