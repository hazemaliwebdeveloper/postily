@echo off
title Backend & Frontend Startup Fix
echo Starting Backend and Frontend with proper configuration...

REM Set memory limits
set NODE_OPTIONS=--max-old-space-size=4096 --max-semi-space-size=512

echo Checking environment file...
if not exist .env (
    echo Creating .env file from .env.local...
    copy .env.local .env
)

echo Starting Backend...
start "Backend" cmd /k "cd apps\backend && pnpm run dev"

echo Waiting for backend to initialize...
timeout /t 15 /nobreak >nul

echo Starting Frontend...
start "Frontend" cmd /k "cd apps\frontend && pnpm run dev"

echo Both services are starting...
echo Backend: http://localhost:3000
echo Frontend: http://localhost:4200
echo.
echo Check the opened windows for startup logs.
pause