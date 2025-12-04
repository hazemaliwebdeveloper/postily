@echo off
REM Local Development Setup Script for Windows
REM This script runs the PowerShell setup script

setlocal enabledelayedexpansion

REM Get the directory where this script is located
cd /d "%~dp0"

REM Run the PowerShell script
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-local.ps1"

REM Check if the script ran successfully
if errorlevel 1 (
    echo.
    echo ERROR: Setup script failed
    exit /b 1
)

pause
