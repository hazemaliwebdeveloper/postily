@echo off
setlocal enabledelayedexpansion
cd /d c:\Users\it\Downloads\pozmixal\postily\apps\backend
echo.
echo Starting Backend on port 3000...
echo Do NOT close this window!
echo.
echo Waiting for startup messages...
echo.
pnpm run dev
pause
