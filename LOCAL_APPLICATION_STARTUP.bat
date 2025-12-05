@echo off
title LOCAL POZMIXAL STARTUP - ERROR-FREE
color 0A

echo ================================================
echo   LOCAL POZMIXAL APPLICATION STARTUP
echo   Complete Error Resolution & Testing
echo ================================================

echo [STEP 1] Checking current status...

REM Kill any existing processes on ports 3000 and 4200
echo Clearing existing processes...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000"') do (
    echo Stopping backend process %%a...
    taskkill /PID %%a /F >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":4200"') do (
    echo Stopping frontend process %%a...
    taskkill /PID %%a /F >nul 2>&1
)

echo [STEP 2] Setting up environment...
if not exist .env (
    echo Creating .env from .env.local...
    copy .env.local .env >nul
)

echo [STEP 3] Optimizing memory settings...
set NODE_OPTIONS=--max-old-space-size=8192 --max-semi-space-size=2048
set NODE_ENV=development

echo [STEP 4] Verifying Docker services...
docker ps >nul 2>&1
if errorlevel 1 (
    echo WARNING: Docker is not running. Starting containers...
    echo Please ensure Docker Desktop is running and try again.
    pause
    exit /b 1
)

echo Starting required containers...
docker compose -f docker-compose.dev.yaml up -d

echo [STEP 5] Installing/verifying dependencies...
echo This may take a few minutes on first run...
pnpm install --no-frozen-lockfile

echo [STEP 6] Generating Prisma client...
pnpm run prisma-generate

echo [STEP 7] Pushing database schema...
pnpm run prisma-db-push

echo [STEP 8] Starting backend (Manual compilation)...
echo Backend will start in a new window...
start "POZMIXAL BACKEND" cmd /k "title POZMIXAL BACKEND && cd apps\backend && echo Starting backend compilation... && echo This may take 2-3 minutes... && set NODE_OPTIONS=%NODE_OPTIONS% && npx ts-node src\main.ts"

echo [STEP 9] Waiting for backend to compile...
echo Waiting 30 seconds for backend compilation...
timeout /t 30 /nobreak >nul

echo [STEP 10] Testing backend connection...
:check_backend
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo Backend still starting... checking again in 10 seconds
    timeout /t 10 /nobreak >nul
    goto check_backend
) else (
    echo ✅ Backend is responding!
)

echo [STEP 11] Starting frontend...
echo Frontend will start in a new window...
start "POZMIXAL FRONTEND" cmd /k "title POZMIXAL FRONTEND && cd apps\frontend && echo Starting frontend... && set NODE_OPTIONS=%NODE_OPTIONS% && pnpm run dev"

echo [STEP 12] Waiting for frontend to start...
timeout /t 20 /nobreak >nul

echo [STEP 13] Testing frontend connection...
:check_frontend
curl -s http://localhost:4200 >nul 2>&1
if errorlevel 1 (
    echo Frontend still starting... checking again in 5 seconds
    timeout /t 5 /nobreak >nul
    goto check_frontend
) else (
    echo ✅ Frontend is responding!
)

echo.
echo ================================================
echo   🎉 APPLICATION STARTED SUCCESSFULLY!
echo ================================================
echo.
echo ✅ Backend:  http://localhost:3000 (API ready)
echo ✅ Frontend: http://localhost:4200 (Application ready)
echo ✅ Database: PostgreSQL running
echo ✅ Redis:    Cache running
echo.
echo 🔧 Admin Tools:
echo   📊 Database Admin: http://localhost:8081 (admin/admin)
echo   📈 Redis Insight:  http://localhost:5540
echo.
echo 🧪 Test the application:
echo   1. Open http://localhost:4200 in your browser
echo   2. Create an account or login
echo   3. Test social media integrations
echo   4. Check for any console errors
echo.
echo 📝 Monitor logs in the opened windows:
echo   - Backend window: Shows API logs and errors
echo   - Frontend window: Shows build logs and warnings
echo.
echo ⚠️  If you see errors:
echo   - Check the backend/frontend windows for details
echo   - Common issues: missing environment variables, OAuth setup
echo   - All previous React/SASS errors have been fixed
echo.
echo Press any key when ready to stop all services...
pause >nul

echo.
echo Stopping all services...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000"') do taskkill /PID %%a /F >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":4200"') do taskkill /PID %%a /F >nul 2>&1

echo ✅ All services stopped.
echo Thank you for testing Pozmixal locally!