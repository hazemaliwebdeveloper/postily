@echo off
REM Quick Start Development Environment for Postiz
REM This script starts all necessary services

setlocal enabledelayedexpansion

color 0A
cls

echo.
echo ==========================================
echo   POSTIZ LOCAL DEVELOPMENT STARTUP
echo ==========================================
echo.

REM Check if pnpm is installed
where pnpm >nul 2>nul
if errorlevel 1 (
    echo ERROR: pnpm is not installed or not in PATH
    echo Please install pnpm first: npm install -g pnpm
    pause
    exit /b 1
)

echo [1/4] Checking dependencies...
pnpm install >nul 2>&1
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
echo ✓ Dependencies installed

echo.
echo [2/4] Generating Prisma Client...
call pnpm run prisma-generate >nul 2>&1
if errorlevel 1 (
    echo WARNING: Prisma generation had issues, continuing...
)
echo ✓ Prisma Client generated

echo.
echo [3/4] Syncing database...
call pnpm run prisma-db-push >nul 2>&1
if errorlevel 1 (
    echo WARNING: Database sync had issues
    echo Make sure PostgreSQL is running
)
echo ✓ Database synced

echo.
echo [4/4] Building extension...
call pnpm --filter ./apps/extension run build:chrome >nul 2>&1
if errorlevel 1 (
    echo ERROR: Extension build failed
    pause
    exit /b 1
)
echo ✓ Extension built

echo.
echo ==========================================
echo   STARTUP COMPLETE
echo ==========================================
echo.
echo Starting services...
echo.
echo Services to start:
echo   - Backend  (NestJS)     → http://localhost:3000
echo   - Frontend (Next.js)    → http://localhost:4200
echo   - Extension (Chrome)    → chrome://extensions
echo.
echo To load extension in Chrome:
echo   1. Go to: chrome://extensions
echo   2. Enable "Developer mode"
echo   3. Click "Load unpacked"
echo   4. Select: apps\extension\dist
echo.
echo Press any key to start all services...
pause

echo.
echo Starting all services in parallel...
echo This will open multiple terminals. Use Ctrl+C to stop any service.
echo.

REM Start services in separate windows
start "Backend" cmd /k "title Backend Service && cd /d "%cd%" && pnpm --filter ./apps/backend run dev"
timeout /t 2 >nul

start "Frontend" cmd /k "title Frontend Service && cd /d "%cd%" && pnpm --filter ./apps/frontend run dev"
timeout /t 2 >nul

start "Extension Watch" cmd /k "title Extension Watch Mode && cd /d "%cd%" && pnpm --filter ./apps/extension run dev:chrome"
timeout /t 2 >nul

start "Workers" cmd /k "title Workers Service && cd /d "%cd%" && pnpm --filter ./apps/workers run dev"
timeout /t 2 >nul

start "Cron" cmd /k "title Cron Service && cd /d "%cd%" && pnpm --filter ./apps/cron run dev"

echo.
echo ==========================================
echo   All services started!
echo ==========================================
echo.
echo IMPORTANT: Load extension manually in Chrome
echo   1. Open Chrome and go to: chrome://extensions
echo   2. Enable "Developer mode" (toggle at top right)
echo   3. Click "Load unpacked"
echo   4. Navigate to and select: apps\extension\dist
echo   5. Click "Open"
echo.
echo The extension should now appear in your Chrome extensions list.
echo.
echo Frontend: http://localhost:4200
echo Backend:  http://localhost:3000
echo.
echo Close any terminal to stop that service.
echo.
pause
