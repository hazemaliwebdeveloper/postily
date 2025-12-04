@echo off
cls
echo =====================================================
echo POSTIZ Application Status Check
echo =====================================================
echo.
echo Waiting 90 seconds for backend initialization...
echo (Backend connects to database and starts services)
timeout /t 90 /nobreak

echo.
echo.
echo =====================================================
echo SERVICE STATUS
echo =====================================================
echo.

echo Frontend (http://localhost:4200):
netstat -ano | find "4200" >nul
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Running on port 4200
) else (
    echo [FAILED] Not responding on port 4200
)

echo.
echo Backend (http://localhost:3000):
netstat -ano | find "3000" >nul
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Running on port 3000
) else (
    echo [WAITING] Still initializing...
)

echo.
echo =====================================================
echo ACCESS THE APPLICATION
echo =====================================================
echo.
echo Open your browser and visit:
echo   http://localhost:4200
echo.
echo Wait for the application to fully load (may take a moment)
echo.
echo =====================================================
pause
