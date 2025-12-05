@echo off
title DIRECT BACKEND START
color 0E

echo ================================================
echo   DIRECT BACKEND START - BYPASS ALL ISSUES
echo ================================================

echo Killing any processes on port 3000...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000"') do (
    taskkill /PID %%a /F >nul 2>&1
)

echo Setting memory environment...
set NODE_OPTIONS=--max-old-space-size=8192 --max-semi-space-size=2048
set NODE_ENV=development

echo Ensuring environment file...
if not exist .env copy .env.local .env >nul

cd apps\backend

echo.
echo ================================================
echo   STARTING BACKEND DIRECTLY
echo ================================================

echo Step 1: TypeScript compilation...
npx tsc --build --force

if exist dist\main.js (
    echo ✅ Compilation successful!
    echo.
    echo Step 2: Starting Node.js server directly...
    echo Backend will be available at: http://localhost:3000
    echo.
    node dist\main.js
) else (
    echo ❌ Compilation failed, trying alternative...
    echo.
    echo Using ts-node directly...
    npx ts-node src\main.ts
)

pause