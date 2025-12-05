@echo off
title Simple Pozmixal Startup
echo ========================================
echo   SIMPLE POZMIXAL STARTUP
echo ========================================

REM Ensure environment file exists
if not exist .env copy .env.local .env

REM Set basic memory configuration
set NODE_OPTIONS=--max-old-space-size=4096

echo Starting services in separate windows...
echo.

echo Backend starting...
start "Backend" cmd /c "cd apps\backend && npx nest start --watch"

echo Waiting 15 seconds...
timeout /t 15 /nobreak >nul

echo Frontend starting...
start "Frontend" cmd /c "cd apps\frontend && npx next dev -p 4200"

echo.
echo Services started in separate windows.
echo Backend: http://localhost:3000
echo Frontend: http://localhost:4200
echo.
echo Wait 2-3 minutes for services to fully initialize.
pause