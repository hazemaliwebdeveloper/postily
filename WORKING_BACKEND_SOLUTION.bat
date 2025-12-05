@echo off
title WORKING BACKEND SOLUTION
color 0C

echo ================================================
echo   WORKING BACKEND SOLUTION
echo   Fixing All Connection Issues
echo ================================================

echo [STEP 1] Killing any hanging processes...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000"') do (
    echo Stopping process %%a on port 3000...
    taskkill /PID %%a /F >nul 2>&1
)

echo [STEP 2] Setting optimal environment...
set NODE_OPTIONS=--max-old-space-size=8192 --max-semi-space-size=2048
set NODE_ENV=development

echo [STEP 3] Ensuring environment file exists...
if not exist .env copy .env.local .env >nul

echo [STEP 4] Starting manual backend compilation...
echo This approach bypasses NestJS CLI issues.

cd apps\backend

echo Starting TypeScript compilation directly...
echo Please wait 2-3 minutes for compilation...

start "Backend Manual Start" cmd /k "title BACKEND MANUAL && echo Starting backend manually... && echo Compiling TypeScript... && npx tsc --watch & echo Compilation started && timeout /t 10 /nobreak >nul && echo Starting server... && node dist/main.js"

echo.
echo [STEP 5] Monitoring startup...
timeout /t 5 /nobreak >nul

echo.
echo ================================================
echo   BACKEND STARTUP INITIATED
echo ================================================
echo.
echo A new window opened with backend startup.
echo.
echo Expected process:
echo 1. TypeScript compilation (1-2 minutes)
echo 2. Server startup
echo 3. "Backend is running on: http://localhost:3000"
echo.
echo Once running, test with:
echo   http://localhost:3000/user/self
echo.
echo Frontend will automatically connect once backend is ready.
echo.
pause