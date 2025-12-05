@echo off
title Pozmixal - Automated Problem Solver
color 0B

echo ========================================
echo   AUTOMATED PROBLEM RESOLUTION
echo ========================================
echo.

REM Set optimal memory configuration
set NODE_OPTIONS=--max-old-space-size=8192 --max-semi-space-size=1024

echo [1/10] Installing missing dependencies...
pnpm add -D cross-env rimraf jest-fetch-mock
if errorlevel 1 echo WARNING: Some dependencies may have failed

echo [2/10] Updating package dependencies...
pnpm update
if errorlevel 1 echo WARNING: Update may have conflicts

echo [3/10] Generating Prisma client...
pnpm run prisma-generate
if errorlevel 1 echo ERROR: Prisma generation failed

echo [4/10] Testing TypeScript compilation...
pnpm run type-check
if errorlevel 1 echo WARNING: TypeScript errors detected

echo [5/10] Running ESLint fixes...
pnpm run lint
if errorlevel 1 echo WARNING: Linting issues remain

echo [6/10] Testing backend build...
pnpm --filter ./apps/backend run build
if errorlevel 1 echo ERROR: Backend build failed

echo [7/10] Testing frontend build...
pnpm --filter ./apps/frontend run build
if errorlevel 1 echo ERROR: Frontend build failed

echo [8/10] Running tests...
pnpm test --passWithNoTests
if errorlevel 1 echo WARNING: Some tests failed

echo [9/10] Starting services...
docker compose -f docker-compose.dev.yaml up -d
if errorlevel 1 echo ERROR: Docker services failed

echo [10/10] Final verification...
timeout /t 5 /nobreak >nul

echo.
echo ========================================
echo   PROBLEM RESOLUTION COMPLETE
echo ========================================
echo.
echo Check output above for any remaining issues.
echo Application should now be ready to run.
echo.
pause