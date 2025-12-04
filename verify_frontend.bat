@echo off
echo Waiting 30 seconds for frontend to start...
timeout /t 30 /nobreak

echo.
echo Checking if frontend is running on port 4200...
netstat -ano | find "4200" >nul
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Frontend is listening on port 4200!
    echo.
    echo =================================================
    echo OPEN YOUR BROWSER:
    echo =================================================
    echo.
    echo http://localhost:4200
    echo.
    echo The frontend should load in a few seconds.
    echo.
) else (
    echo [ERROR] Frontend is not responding on port 4200
    echo Possible reasons:
    echo  - Port 4200 is blocked by firewall
    echo  - Node.js crash during startup
    echo  - Dependencies not installed
    echo.
)
