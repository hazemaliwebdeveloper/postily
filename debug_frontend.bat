@echo off
setlocal enabledelayedexpansion
cd /d c:\Users\it\Downloads\pozmixal\postily\apps\frontend

echo Debug: Checking environment
echo.
echo Current directory: %cd%
echo.
echo Checking .env file...
if exist ..\..\..env (
    echo .env found
) else (
    echo .env NOT found!
)
echo.
echo Running: pnpm run dev
echo =====================================================
echo.

pnpm run dev
