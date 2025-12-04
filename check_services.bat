@echo off
setlocal
echo Waiting 60 seconds for services to fully start...
timeout /t 60 /nobreak

echo.
echo Checking Frontend on port 4200...
netstat -ano | find "4200" >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Frontend port 4200 is listening
) else (
    echo [ERROR] Frontend port 4200 is not listening
)

echo.
echo Checking Backend on port 3000...
netstat -ano | find "3000" >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Backend port 3000 is listening
) else (
    echo [ERROR] Backend port 3000 is not listening
)

echo.
echo =====================================================
echo.
echo Application URLs:
echo   Frontend: http://localhost:4200
echo   Backend:  http://localhost:3000
echo.
echo =====================================================
echo.
pause
