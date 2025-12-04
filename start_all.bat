@echo off
cd /d c:\Users\it\Downloads\pozmixal\postily
title POZMIXAL - Development Server
color 0A

cls
echo.
echo =========================================================
echo        POZMIXAL - Full Stack Development Server
echo =========================================================
echo.
echo Starting all services:
echo   - Frontend (Next.js)    - Port 4200
echo   - Backend (NestJS)      - Port 3000
echo   - Workers, Cron, Ext    - Background
echo.
echo Increasing Node.js heap memory...
set NODE_OPTIONS=--max-old-space-size=4096
echo.
echo Starting services...
echo.

pnpm run dev