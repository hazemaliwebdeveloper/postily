@echo off
setlocal enabledelayedexpansion
cd /d c:\Users\it\Downloads\pozmixal\postily

echo.
echo =====================================================
echo   POSTIZ - Starting Application Stack
echo =====================================================
echo.
echo Increasing Node.js heap memory for backend...
set NODE_OPTIONS=--max-old-space-size=4096
echo NODE_OPTIONS set to: %NODE_OPTIONS%
echo.
echo Starting all services on:
echo   - Frontend: http://localhost:4200
echo   - Backend: http://localhost:3000
echo   - Workers, Cron, Extension: Background services
echo.
echo Press Ctrl+C to stop all services
echo =====================================================
echo.

pnpm run dev
