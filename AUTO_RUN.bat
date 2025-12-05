@echo off
REM AUTO_RUN.bat - Fully Automated
REM Starts services and opens browser when ready

setlocal enabledelayedexpansion
color 0A
cls

echo.
echo ╔════════════════════════════════════════════════╗
echo ║  POSTIZ - FULLY AUTOMATED START                ║
echo ║  Everything starts automatically               ║
echo ╚════════════════════════════════════════════════╝
echo.

REM Step 1: Setup
echo [1/5] Checking dependencies...
if not exist "node_modules" (
    echo        Installing dependencies...
    call pnpm install
)
echo        ✓ Done
echo.

REM Step 2: Database
echo [2/5] Setting up database...
call pnpm run prisma-generate >nul 2>&1
call pnpm run prisma-db-push >nul 2>&1
echo        ✓ Done
echo.

REM Step 3: Extension
echo [3/5] Building extension...
cd /d apps\extension
call pnpm run build:chrome >nul 2>&1
cd /d ..\..
echo        ✓ Done
echo.

REM Step 4: Start services
echo [4/5] Starting services...
echo        • Backend (minimized)
start "" /min cmd /k "cd /d "%cd%\apps\backend" && pnpm run dev"
timeout /t 3 >nul

echo        • Frontend (minimized)
start "" /min cmd /k "cd /d "%cd%\apps\frontend" && pnpm run dev"
timeout /t 3 >nul

echo        • Extension (minimized)
start "" /min cmd /k "cd /d "%cd%\apps\extension" && pnpm run dev:chrome"
echo        ✓ All services started
echo.

REM Step 5: Wait for services
echo [5/5] Waiting for services to be ready...
echo.

REM Wait for backend
set /a counter=0
:wait_backend
cls
echo        Waiting for backend to start...
echo        Attempt: !counter!/60
timeout /t 2 >nul
set /a counter+=1
powershell -Command "try { $r = Invoke-WebRequest -Uri http://localhost:3000/health -TimeoutSec 1 -ErrorAction Stop; exit 0 } catch { exit 1 }" >nul 2>&1
if errorlevel 1 (
    if !counter! lss 60 goto wait_backend
    echo.
    echo ERROR: Backend failed to start
    echo Check minimized backend window for errors
    pause
    exit /b 1
)
echo        ✓ Backend ready!
echo.

REM Wait for frontend
set /a counter=0
:wait_frontend
echo        Waiting for frontend to start...
echo        Attempt: !counter!/60
timeout /t 2 >nul
set /a counter+=1
powershell -Command "try { $r = Invoke-WebRequest -Uri http://localhost:4200 -TimeoutSec 1 -ErrorAction Stop; exit 0 } catch { exit 1 }" >nul 2>&1
if errorlevel 1 (
    if !counter! lss 60 goto wait_frontend
    echo.
    echo ERROR: Frontend failed to start
    echo Check minimized frontend window for errors
    pause
    exit /b 1
)
echo        ✓ Frontend ready!
echo.

cls
echo.
echo ╔════════════════════════════════════════════════╗
echo ║  ✅ ALL SERVICES READY!                        ║
echo ║  Opening browser now...                        ║
echo ╚════════════════════════════════════════════════╝
echo.

REM Open browser
start http://localhost:4200
timeout /t 2 >nul

echo        ✓ Browser opened: http://localhost:4200
echo.
echo ════════════════════════════════════════════════
echo.
echo Services running:
echo   • Backend:   http://localhost:3000
echo   • Frontend:  http://localhost:4200
echo.
echo Load Extension in Chrome:
echo   1. chrome://extensions
echo   2. Enable Developer mode
echo   3. Load unpacked ^→ apps\extension\dist
echo.
echo Services are minimized in background.
echo Close the windows to stop services.
echo.
echo ════════════════════════════════════════════════
echo.
pause
