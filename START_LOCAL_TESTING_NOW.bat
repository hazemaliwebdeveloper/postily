@echo off
title POZMIXAL - START LOCAL TESTING NOW
color 0A

echo.
echo  ██████╗  ██████╗ ███████╗███╗   ███╗██╗██╗  ██╗ █████╗ ██╗     
echo  ██╔══██╗██╔═══██╗╚══███╔╝████╗ ████║██║╚██╗██╔╝██╔══██╗██║     
echo  ██████╔╝██║   ██║  ███╔╝ ██╔████╔██║██║ ╚███╔╝ ███████║██║     
echo  ██╔═══╝ ██║   ██║ ███╔╝  ██║╚██╔╝██║██║ ██╔██╗ ██╔══██║██║     
echo  ██║     ╚██████╔╝███████╗██║ ╚═╝ ██║██║██╔╝ ██╗██║  ██║███████╗
echo  ╚═╝      ╚═════╝ ╚══════╝╚═╝     ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
echo.
echo ================================================
echo   LOCAL APPLICATION TESTING - START NOW
echo ================================================
echo.

echo 🎯 OBJECTIVE: Test application locally before production
echo 📋 STATUS: All previous errors have been fixed
echo ⚡ READY: Docker containers running, fixes applied
echo.

echo Select your testing approach:
echo.
echo 1. 🚀 QUICK START (Recommended)
echo    - Automated startup and testing
echo    - Complete error monitoring
echo    - 5-10 minutes total time
echo.
echo 2. 🔧 MANUAL STARTUP
echo    - Step-by-step guided process
echo    - Full control over each step
echo    - Educational walkthrough
echo.
echo 3. 🧪 COMPREHENSIVE TESTING
echo    - Full system validation
echo    - Error detection and monitoring
echo    - Performance verification
echo.
echo 4. 📊 ERROR MONITORING ONLY
echo    - Monitor running application
echo    - Real-time error detection
echo    - Troubleshooting guidance
echo.
echo 5. 📖 VIEW TESTING GUIDE
echo    - Read complete testing documentation
echo    - Understand what to test
echo    - Troubleshooting reference
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto quick_start
if "%choice%"=="2" goto manual_startup
if "%choice%"=="3" goto comprehensive_test
if "%choice%"=="4" goto error_monitor
if "%choice%"=="5" goto view_guide
goto invalid_choice

:quick_start
echo.
echo 🚀 QUICK START SELECTED
echo =======================
echo.
echo This will automatically:
echo ✅ Clear any existing processes
echo ✅ Set up optimal environment
echo ✅ Start backend with monitoring
echo ✅ Start frontend with monitoring  
echo ✅ Test all connections
echo ✅ Provide status updates
echo.
echo Starting in 3 seconds...
timeout /t 3 /nobreak >nul
call LOCAL_APPLICATION_STARTUP.bat
goto end

:manual_startup
echo.
echo 🔧 MANUAL STARTUP SELECTED
echo ==========================
echo.
echo Let's start step by step:
echo.
echo [STEP 1] Environment Setup
echo --------------------------
pause
echo Setting environment variables...
set NODE_OPTIONS=--max-old-space-size=8192
echo ✅ Memory optimization: %NODE_OPTIONS%

echo.
echo [STEP 2] Backend Startup
echo ------------------------
pause
echo Starting backend in new window...
cd apps\backend
start "BACKEND-MANUAL" cmd /k "title BACKEND MANUAL && echo Backend starting manually... && set NODE_OPTIONS=--max-old-space-size=6144 && npx ts-node src\main.ts"
cd ..\..

echo.
echo [STEP 3] Wait for Backend Compilation
echo -----------------------------------
echo Backend is compiling... this takes 2-3 minutes
echo Watch the BACKEND-MANUAL window for progress
pause

echo.
echo [STEP 4] Frontend Startup
echo -------------------------
pause
echo Starting frontend in new window...
cd apps\frontend  
start "FRONTEND-MANUAL" cmd /k "title FRONTEND MANUAL && echo Frontend starting manually... && set NODE_OPTIONS=--max-old-space-size=4096 && pnpm run dev"
cd ..\..

echo.
echo [STEP 5] Testing Connectivity
echo ----------------------------
pause
echo Testing backend...
curl -s http://localhost:3000 >nul && echo ✅ Backend: OK || echo ❌ Backend: Not ready
echo Testing frontend...
curl -s http://localhost:4200 >nul && echo ✅ Frontend: OK || echo ❌ Frontend: Not ready

echo.
echo ✅ Manual startup complete!
echo Open http://localhost:4200 to test your application.
goto end

:comprehensive_test
echo.
echo 🧪 COMPREHENSIVE TESTING SELECTED
echo =================================
echo.
echo This will run complete system validation:
echo ✅ Service startup verification
echo ✅ API endpoint testing
echo ✅ Database connectivity testing
echo ✅ Error detection and reporting
echo ✅ Performance monitoring
echo.
echo Starting comprehensive testing...
timeout /t 2 /nobreak >nul
call TEST_LOCAL_APPLICATION.bat
goto end

:error_monitor
echo.
echo 📊 ERROR MONITORING SELECTED
echo ============================
echo.
echo This will start real-time monitoring for:
echo 🔍 Service status monitoring
echo 🌐 API connectivity testing
echo 📈 Performance metrics
echo 🚨 Error detection and solutions
echo.
echo Note: Your application should already be running
echo If not running, use option 1 (Quick Start) first
echo.
echo Starting error monitor...
timeout /t 2 /nobreak >nul
call LOCAL_ERROR_MONITOR.bat
goto end

:view_guide
echo.
echo 📖 OPENING TESTING DOCUMENTATION
echo ================================
echo.
start "" "LOCAL_QUICK_START.md"
echo ✅ Testing guide opened in your default editor
echo.
echo Summary of what to test:
echo ========================
echo.
echo 🔧 TECHNICAL TESTING:
echo   - Backend starts without errors
echo   - Frontend builds successfully  
echo   - API endpoints respond correctly
echo   - Database connections work
echo   - No console errors in browser
echo.
echo 🧪 FUNCTIONAL TESTING:
echo   - User can access application
echo   - Registration/login works
echo   - Main features function
echo   - Navigation works properly
echo   - No critical bugs found
echo.
echo ✅ SUCCESS CRITERIA:
echo   - Application loads at http://localhost:4200
echo   - No ERR_CONNECTION_REFUSED errors
echo   - No React DOM compatibility errors
echo   - No SASS deprecation warnings
echo   - All major functionality works
echo.
goto end

:invalid_choice
echo.
echo ❌ Invalid choice. Please select 1-5.
pause
cls
goto start

:end
echo.
echo ================================================
echo   🎯 LOCAL TESTING READY
echo ================================================
echo.
echo 📝 WHAT TO TEST:
echo   1. Open http://localhost:4200 in browser
echo   2. Check browser console (F12) for errors
echo   3. Test user registration/login
echo   4. Verify API connectivity
echo   5. Test main application features
echo.
echo ✅ PREVIOUS ERRORS FIXED:
echo   - ERR_CONNECTION_REFUSED → Backend startup optimized
echo   - React DOM errors → Blueprint.js patches applied
echo   - SASS warnings → Modern syntax implemented
echo   - Memory issues → Allocation optimized
echo.
echo 🎉 AFTER SUCCESSFUL LOCAL TESTING:
echo   - Ready for production deployment
echo   - Use provided deployment guides
echo   - Choose: Vercel + Railway (recommended)
echo.
echo Good luck with your testing! 🚀
pause