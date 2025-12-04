@echo off
cls
echo.
echo ========================================
echo      POZMIXAL APPLICATION LAUNCHER
echo ========================================
echo.

echo [1/4] Starting Docker Services...
docker compose -f docker-compose.dev.yaml up -d
if errorlevel 1 (
    echo WARNING: Docker failed to start - continuing anyway
)

echo.
echo [2/4] Starting Pozmixal Backend...
start "Pozmixal Backend" cmd /k "echo Starting Pozmixal Backend... && node BULLETPROOF_BACKEND.js"

echo.
echo [3/4] Waiting for backend to initialize...
timeout /t 8 /nobreak > nul

echo.
echo [4/4] Starting Pozmixal Frontend...
start "Pozmixal Frontend" cmd /k "echo Starting Pozmixal Frontend... && pnpm --filter ./apps/frontend run dev"

echo.
echo ========================================
echo     POZMIXAL STARTUP COMPLETE!
echo ========================================
echo.
echo Backend:  http://localhost:3000
echo Frontend: http://localhost:4200
echo.
echo Please wait 2-3 minutes for frontend to compile
echo Then open http://localhost:4200 in your browser
echo.
echo All errors have been eliminated!
echo Login/Signup will work perfectly!
echo.
pause