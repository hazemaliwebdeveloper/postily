@echo off
REM Verification script - Check if all services are running

color 0A
cls

echo.
echo ============================================
echo   POSTIZ - VERIFICATION CHECK
echo ============================================
echo.

REM Check backend
echo [*] Checking Backend (http://localhost:3000)...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3000/health' -TimeoutSec 2 -ErrorAction Stop; if ($response.StatusCode -eq 200) { Write-Host '✓ Backend is running' -ForegroundColor Green } } catch { Write-Host '✗ Backend is NOT running' -ForegroundColor Red }"

echo.

REM Check frontend
echo [*] Checking Frontend (http://localhost:4200)...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:4200' -TimeoutSec 2 -ErrorAction Stop; if ($response.StatusCode -eq 200) { Write-Host '✓ Frontend is running' -ForegroundColor Green } } catch { Write-Host '✗ Frontend is NOT running' -ForegroundColor Red }"

echo.

REM Check extension dist
echo [*] Checking Extension build...
if exist "apps\extension\dist\manifest.json" (
    echo ✓ Extension is built
) else (
    echo ✗ Extension is NOT built
    echo Building now...
    cd /d apps\extension
    call pnpm run build:chrome
    cd /d ..\..
)

echo.
echo ============================================
echo   SUMMARY
echo ============================================
echo.
echo Frontend: http://localhost:4200
echo Backend:  http://localhost:3000
echo Extension: chrome://extensions (Load unpacked from apps\extension\dist)
echo.
pause
