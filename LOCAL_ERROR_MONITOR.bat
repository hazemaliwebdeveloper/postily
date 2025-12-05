@echo off
title POZMIXAL ERROR MONITOR
color 0E

echo ================================================
echo   POZMIXAL LOCAL ERROR MONITORING
echo   Real-time Error Detection & Solutions
echo ================================================

echo Starting comprehensive error monitoring...
echo Monitor this window while testing your application
echo.

:monitor_loop
cls
echo ================================================
echo   🔍 REAL-TIME ERROR MONITOR
echo ================================================
echo Last updated: %date% %time%
echo.

echo 🟢 SERVICE STATUS:
echo ================
netstat -ano | findstr ":3000" >nul 2>&1 && (
    echo ✅ Backend: Running on port 3000
) || (
    echo ❌ Backend: NOT RUNNING
    echo   ➤ Solution: Run LOCAL_APPLICATION_STARTUP.bat
)

netstat -ano | findstr ":4200" >nul 2>&1 && (
    echo ✅ Frontend: Running on port 4200  
) || (
    echo ❌ Frontend: NOT RUNNING
    echo   ➤ Solution: Run LOCAL_APPLICATION_STARTUP.bat
)

docker exec pozmixal-postgres pg_isready -U pozmixal-local >nul 2>&1 && (
    echo ✅ Database: PostgreSQL ready
) || (
    echo ❌ Database: PostgreSQL not ready
    echo   ➤ Solution: docker compose -f docker-compose.dev.yaml up -d
)

docker exec pozmixal-redis redis-cli ping >nul 2>&1 && (
    echo ✅ Cache: Redis ready
) || (
    echo ❌ Cache: Redis not ready  
    echo   ➤ Solution: docker compose -f docker-compose.dev.yaml up -d
)

echo.
echo 🌐 CONNECTIVITY TESTS:
echo ======================
curl -s -I http://localhost:3000 | find "HTTP" >nul 2>&1 && (
    echo ✅ Backend API: Responding
) || (
    echo ❌ Backend API: Not responding
    echo   ➤ Check BACKEND window for compilation errors
)

curl -s -I http://localhost:4200 | find "HTTP" >nul 2>&1 && (
    echo ✅ Frontend: Responding
) || (
    echo ❌ Frontend: Not responding
    echo   ➤ Check FRONTEND window for build errors
)

echo.
echo 🧪 API ENDPOINT TESTS:
echo =====================
for /f %%i in ('curl -s -o nul -w "%%{http_code}" http://localhost:3000/user/self 2^>nul') do set api_status=%%i
if "%api_status%"=="401" (
    echo ✅ /user/self: Working (401 Unauthorized - correct)
) else if "%api_status%"=="000" (
    echo ❌ /user/self: Connection refused
    echo   ➤ Backend not ready or crashed
) else (
    echo ✅ /user/self: Status %api_status%
)

echo.
echo 📊 MEMORY USAGE:
echo ================
for /f "tokens=*" %%i in ('wmic process where "name='node.exe'" get WorkingSetSize /value 2^>nul ^| find "="') do (
    for /f "tokens=2 delims==" %%j in ("%%i") do (
        if not "%%j"=="" (
            set /a mem_mb=%%j/1024/1024 >nul 2>&1
            if defined mem_mb echo Node.js process: !mem_mb! MB
        )
    )
)

echo.
echo 🔍 COMMON ISSUES MONITOR:
echo =========================
echo ❌ If you see "ERR_CONNECTION_REFUSED":
echo   ➤ Backend is not running - check compilation
echo.
echo ❌ If you see "Failed to fetch":  
echo   ➤ API endpoint issues - check backend logs
echo.
echo ❌ If you see React DOM errors:
echo   ➤ Should be FIXED - patches already applied
echo.
echo ❌ If you see SASS warnings:
echo   ➤ Should be FIXED - syntax updated to modern @use
echo.
echo 🎯 TESTING CHECKLIST:
echo ====================
echo [ ] Application loads at http://localhost:4200
echo [ ] No console errors in browser (F12)
echo [ ] User can register/login
echo [ ] API calls succeed (not connection refused)
echo [ ] No React DOM compatibility errors
echo [ ] No SASS deprecation warnings
echo [ ] All social media integrations load
echo [ ] File uploads work (if testing)
echo [ ] Database operations succeed
echo.
echo ⏰ Auto-refresh in 10 seconds... (Press Ctrl+C to stop)
timeout /t 10 /nobreak >nul
goto monitor_loop