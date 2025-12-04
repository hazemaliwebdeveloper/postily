@echo off
cls
echo.
echo ========================================
echo    POZMIXAL - QUICK START LAUNCHER
echo ========================================
echo.
echo This script will start your complete
echo Pozmixal application locally
echo.
echo Required:
echo - Node.js 20+
echo - Docker Desktop
echo - pnpm package manager
echo.
pause

echo.
echo [1/6] Setting up environment...
if not exist ".env.local" (
    echo Copying environment configuration...
    copy "COMPLETE_POZMIXAL_ENV.local" ".env.local" > nul
    copy "COMPLETE_POZMIXAL_ENV.local" ".env" > nul
    echo ✓ Environment files created
) else (
    echo ✓ Environment files already exist
)

echo.
echo [2/6] Starting Docker services...
docker compose -f docker-compose.dev.yaml up -d
if errorlevel 1 (
    echo ❌ Docker failed to start
    echo Please ensure Docker Desktop is running
    pause
    exit /b 1
)
echo ✓ PostgreSQL and Redis started

echo.
echo [3/6] Installing dependencies...
echo This may take a few minutes on first run...
pnpm install --silent
if errorlevel 1 (
    echo ❌ Dependencies installation failed
    pause
    exit /b 1
)
echo ✓ Dependencies installed

echo.
echo [4/6] Setting up database...
pnpm run prisma-db-push > nul 2>&1
if errorlevel 1 (
    echo ⚠️ Database setup had issues (continuing anyway)
) else (
    echo ✓ Database schema applied
)

echo.
echo [5/6] Starting Pozmixal Backend...
start "Pozmixal Backend" cmd /k "echo 🚀 Starting Pozmixal Backend... && echo. && node FINAL_ERROR_FREE_BACKEND.js"

echo.
echo [6/6] Waiting and starting Frontend...
timeout /t 8 /nobreak > nul
start "Pozmixal Frontend" cmd /k "echo 🌐 Starting Pozmixal Frontend... && echo. && pnpm --filter ./apps/frontend run dev"

echo.
echo ========================================
echo      POZMIXAL STARTUP COMPLETE!
echo ========================================
echo.
echo ✅ Backend:  http://localhost:3000
echo ✅ Frontend: http://localhost:4200
echo ✅ PgAdmin:  http://localhost:8081
echo ✅ Redis UI: http://localhost:5540
echo.
echo 📋 Default Login:
echo    Email: admin@pozmixal.com
echo    Password: admin123
echo.
echo ⏱️ Please wait 2-3 minutes for frontend compilation
echo 🌐 Then open: http://localhost:4200
echo.
echo ❓ Need help? Check ULTIMATE_LOCAL_SETUP_GUIDE.md
echo.
pause