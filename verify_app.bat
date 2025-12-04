@echo off
echo.
echo ==================================================
echo Verifying Application Status
echo ==================================================
echo.
echo Checking Frontend on port 4200...
netstat -ano | find "4200" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Status: [SUCCESS] Frontend is running!
    echo.
    echo Open your browser and go to:
    echo   http://localhost:4200
    echo.
) else (
    echo Status: [INITIALIZING] Waiting for frontend...
    echo Please wait a moment and refresh your browser.
    echo.
)

echo ==================================================
