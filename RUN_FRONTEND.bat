@echo off
setlocal enabledelayedexpansion
cd /d c:\Users\it\Downloads\pozmixal\postily\apps\frontend
echo.
echo Starting Frontend on port 4200...
echo Do NOT close this window!
echo.
echo Waiting for startup messages...
echo.
pnpm run dev
pause
