@echo off
cls
echo.
echo Waiting 45 seconds for application to start...
echo.
timeout /t 45 /nobreak
echo.
echo.
echo ==================================================
echo Checking Services
echo ==================================================
echo.

echo Checking port 4200 (Frontend)...
netstat -ano | find "4200" >nul
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Frontend is running on port 4200!
    echo.
    echo OPEN YOUR BROWSER:
    echo   http://localhost:4200
    echo.
) else (
    echo [INFO] Frontend still initializing...
    echo Please wait and refresh your browser
    echo URL: http://localhost:4200
)

echo.
echo Checking port 3000 (Backend)...
netstat -ano | find "3000" >nul
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Backend is running on port 3000!
) else (
    echo [INFO] Backend still initializing...
)

echo.
echo ==================================================
