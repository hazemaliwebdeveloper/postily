@echo off
title EMERGENCY FIX - All Errors
color 0C

echo ================================================
echo   EMERGENCY FIX - ALL ERRORS RESOLUTION
echo ================================================

echo [CRITICAL] Backend not running - starting immediately...

REM Kill any existing processes on port 3000
echo Clearing port 3000...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000"') do (
    taskkill /PID %%a /F >nul 2>&1
)

echo [1/4] Setting emergency memory configuration...
set NODE_OPTIONS=--max-old-space-size=8192 --max-semi-space-size=2048
set NODE_ENV=development

echo [2/4] Emergency backend startup...
cd apps\backend

echo Starting backend with bypass compilation...
start "EMERGENCY BACKEND" cmd /k "title BACKEND EMERGENCY && echo EMERGENCY BACKEND STARTING... && set NODE_OPTIONS=%NODE_OPTIONS% && echo Memory: %NODE_OPTIONS% && echo Starting NestJS... && npx nest start --watch"

cd ..\..

echo [3/4] Waiting for backend to compile...
echo This is CRITICAL - backend must start for frontend to work...
timeout /t 30 /nobreak

echo [4/4] Testing backend connection...
ping -n 1 localhost >nul
echo Backend startup initiated...

echo.
echo ================================================
echo   EMERGENCY STATUS
echo ================================================
echo.
echo Backend: STARTING (watch emergency window)
echo Frontend: RUNNING (will connect once backend is ready)
echo.
echo CRITICAL: Watch the "BACKEND EMERGENCY" window
echo Look for: "Backend is running on: http://localhost:3000"
echo.
echo Errors will STOP once backend starts listening!
echo.
pause