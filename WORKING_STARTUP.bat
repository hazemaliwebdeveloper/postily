@echo off
title Pozmixal - WORKING STARTUP
color 0A

echo ========================================
echo   POZMIXAL - WORKING STARTUP
echo ========================================

REM Ensure .env file exists
if not exist .env (
    echo Setting up environment...
    copy .env.local .env >nul
)

REM Set memory limits
set NODE_OPTIONS=--max-old-space-size=6144

echo Docker services status:
docker compose -f docker-compose.dev.yaml up -d

echo.
echo Starting Backend (NestJS)...
start "Pozmixal Backend" cmd /k "title Backend - Pozmixal && echo Starting backend... && cd apps\backend && set NODE_OPTIONS=--max-old-space-size=4096 && npx nest start --watch"

echo.
echo Waiting 20 seconds for backend to compile...
timeout /t 20 /nobreak

echo.
echo Starting Frontend (Next.js)...
start "Pozmixal Frontend" cmd /k "title Frontend - Pozmixal && echo Starting frontend... && cd apps\frontend && set NODE_OPTIONS=--max-old-space-size=4096 && npx next dev -p 4200"

echo.
echo ========================================
echo   STARTUP INITIATED
echo ========================================
echo.
echo Backend:  http://localhost:3000 (compiling...)
echo Frontend: http://localhost:4200 (starting...)
echo.
echo Services are starting in separate windows.
echo Please wait 3-5 minutes for both to fully initialize.
echo.
echo Check the opened windows for progress and any errors.
echo Once both show "ready" messages, your app will be accessible!
echo.
pause