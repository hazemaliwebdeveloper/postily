@echo off
setlocal enabledelayedexpansion
cd /d c:\Users\it\Downloads\pozmixal\postily\apps\frontend

echo.
echo =====================================================
echo   POSTIZ Frontend - Development Server
echo =====================================================
echo.
echo Increasing Node.js heap memory...
set NODE_OPTIONS=--max-old-space-size=4096
echo Starting Next.js dev server on port 4200...
echo.
echo Once ready, open your browser:
echo   http://localhost:4200
echo.
echo =====================================================
echo.

call pnpm run dev
