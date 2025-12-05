@echo off
title Backend Startup Fix
echo ========================================
echo   BACKEND STARTUP DIAGNOSTIC & FIX
echo ========================================

echo [1/5] Checking if backend is already running...
netstat -ano | findstr ":3000" >nul
if %errorlevel%==0 (
    echo Backend is already running on port 3000
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000"') do (
        echo Stopping existing backend process %%a...
        taskkill /PID %%a /F >nul 2>&1
    )
)

echo [2/5] Setting optimal memory configuration...
set NODE_OPTIONS=--max-old-space-size=6144 --max-semi-space-size=1024

echo [3/5] Clearing any build cache...
cd apps\backend
if exist dist rmdir /s /q dist
if exist node_modules\.cache rmdir /s /q node_modules\.cache

echo [4/5] Starting backend with detailed logging...
echo Memory settings: %NODE_OPTIONS%
echo Starting NestJS compilation...
echo This may take 2-3 minutes for first-time compilation.
echo.

echo [5/5] Backend startup initiated...
start "Backend Compilation" cmd /k "title Backend - Compiling && echo Backend starting... && echo Compilation in progress... && npx nest start --watch"

echo.
echo Backend is starting in a separate window.
echo Watch for these messages:
echo   - "Starting compilation in watch mode..."
echo   - "Compilation successful"  
echo   - "Backend is running on: http://localhost:3000"
echo.
echo Once you see "Backend is running", the API will be available.
echo.
pause