@echo off
cls
echo.
echo ========================================
echo    POZMIXAL - SETUP VERIFICATION
echo ========================================
echo.
echo This script verifies your Pozmixal setup
echo.

echo [1/8] Checking system requirements...
echo.

echo Checking Node.js version...
node --version 2>nul
if errorlevel 1 (
    echo ❌ Node.js not found - please install Node.js 20+
    goto :end
) else (
    echo ✓ Node.js is installed
)

echo.
echo Checking pnpm...
pnpm --version 2>nul
if errorlevel 1 (
    echo ❌ pnpm not found - please install: npm install -g pnpm
    goto :end
) else (
    echo ✓ pnpm is installed
)

echo.
echo Checking Docker...
docker --version 2>nul
if errorlevel 1 (
    echo ❌ Docker not found - please install Docker Desktop
    goto :end
) else (
    echo ✓ Docker is installed
)

echo.
echo [2/8] Checking environment files...
if exist ".env" (
    echo ✓ .env file exists
) else (
    echo ❌ .env file missing
    echo 💡 Run: copy "COMPLETE_POZMIXAL_ENV.local" ".env"
)

if exist ".env.local" (
    echo ✓ .env.local file exists
) else (
    echo ❌ .env.local file missing
    echo 💡 Run: copy "COMPLETE_POZMIXAL_ENV.local" ".env.local"
)

echo.
echo [3/8] Checking Docker containers...
docker ps 2>nul | findstr "pozmixal-postgres" > nul
if errorlevel 1 (
    echo ❌ PostgreSQL container not running
    echo 💡 Run: docker compose -f docker-compose.dev.yaml up -d
) else (
    echo ✓ PostgreSQL container is running
)

docker ps 2>nul | findstr "pozmixal-redis" > nul
if errorlevel 1 (
    echo ❌ Redis container not running
    echo 💡 Run: docker compose -f docker-compose.dev.yaml up -d
) else (
    echo ✓ Redis container is running
)

echo.
echo [4/8] Checking backend connection...
curl -s http://localhost:3000/health > nul 2>&1
if errorlevel 1 (
    echo ❌ Backend not responding on port 3000
    echo 💡 Start backend: node FINAL_ERROR_FREE_BACKEND.js
) else (
    echo ✓ Backend is responding on port 3000
)

echo.
echo [5/8] Checking frontend...
netstat -an | findstr "4200.*LISTENING" > nul 2>&1
if errorlevel 1 (
    echo ❌ Frontend not running on port 4200
    echo 💡 Start frontend: pnpm --filter ./apps/frontend run dev
) else (
    echo ✓ Frontend is listening on port 4200
)

echo.
echo [6/8] Testing backend API...
curl -s -w "%%{http_code}" http://localhost:3000/test 2>nul | findstr "200" > nul
if errorlevel 1 (
    echo ❌ Backend API test failed
) else (
    echo ✓ Backend API is working
)

echo.
echo [7/8] Testing authentication...
curl -s -X POST http://localhost:3000/auth/register -H "Content-Type: application/json" -d "{\"email\":\"test@pozmixal.com\",\"password\":\"test123\"}" 2>nul | findstr "Pozmixal" > nul
if errorlevel 1 (
    echo ❌ Authentication test failed
) else (
    echo ✓ Authentication is working
)

echo.
echo [8/8] Checking brand identity...
curl -s http://localhost:3000/ 2>nul | findstr "Pozmixal" > nul
if errorlevel 1 (
    echo ❌ Branding verification failed
) else (
    echo ✓ Pozmixal branding is active
)

echo.
echo ========================================
echo         VERIFICATION COMPLETE
echo ========================================
echo.
echo 📱 Access your Pozmixal application:
echo    Frontend: http://localhost:4200
echo    Backend:  http://localhost:3000
echo    PgAdmin:  http://localhost:8081
echo    Redis UI: http://localhost:5540
echo.
echo 👤 Default test account:
echo    Email: test@pozmixal.com
echo    Password: test123
echo.
echo 📋 If any checks failed, see solutions above
echo 📖 Full guide: ULTIMATE_LOCAL_SETUP_GUIDE.md
echo.

:end
pause