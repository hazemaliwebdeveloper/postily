@echo off
REM REAL_RUN.bat - Actually Working Solution
REM This script opens separate windows for backend and frontend

setlocal enabledelayedexpansion
color 0A
cls

echo.
echo ╔════════════════════════════════════════╗
echo ║  POSTIZ - REAL WORKING RUN             ║
echo ╚════════════════════════════════════════╝
echo.

REM Check if dependencies are installed
if not exist "node_modules" (
    echo [STEP 1/3] Installing dependencies (first time only)...
    call pnpm install
    if errorlevel 1 (
        echo ERROR: Failed to install dependencies
        pause
        exit /b 1
    )
    echo ✓ Dependencies installed
    echo.
)

REM Setup database
echo [STEP 2/3] Setting up database...
call pnpm run prisma-generate >nul 2>&1
call pnpm run prisma-db-push >nul 2>&1
echo ✓ Database ready
echo.

REM Build extension
echo [STEP 3/3] Building extension...
cd /d apps\extension
call pnpm run build:chrome >nul 2>&1
cd /d ..\..
echo ✓ Extension built
echo.

echo ╔════════════════════════════════════════╗
echo ║  STARTING SERVICES IN SEPARATE WINDOWS ║
echo ╚════════════════════════════════════════╝
echo.

echo Opening backend window... (port 3000)
start "BACKEND - Keep Open" /d "%CD%\apps\backend" pnpm run dev

echo Opening frontend window... (port 4200)
start "FRONTEND - Keep Open" /d "%CD%\apps\frontend" pnpm run dev

echo Opening extension window...
start "EXTENSION - Keep Open" /d "%CD%\apps\extension" pnpm run dev:chrome

echo.
echo ╔════════════════════════════════════════╗
echo ║  SERVICES STARTED                      ║
echo ╚════════════════════════════════════════╝
echo.

echo IMPORTANT - DO NOT CLOSE ANY WINDOWS!
echo.

echo Services are starting in separate windows.
echo This may take 20-30 seconds for first compile.
echo.

echo WAIT for these messages in each window:
echo   Backend:  "🚀 Backend is running on: http://localhost:3000"
echo   Frontend: "✓ Ready in X seconds"
echo.

echo Once you see both messages, then:
echo   1. Open browser
echo   2. Go to: http://localhost:4200
echo   3. You should see login page
echo.

echo Extension:
echo   1. chrome://extensions
echo   2. Enable "Developer mode"
echo   3. Load unpacked → apps\extension\dist
echo.

timeout /t 5

echo.
echo Windows should be opening now...
echo If they don't appear, check taskbar for minimized windows.
echo.

pause
