@echo off
REM =============================================================================
REM POZMIXAL - Complete Local Development Setup Script (Batch Version)
REM =============================================================================
REM
REM This script sets up and runs the complete Pozmixal application locally
REM
REM Prerequisites:
REM   - Node.js 22+ installed
REM   - Docker Desktop installed and running
REM   - pnpm installed
REM
REM Usage:
REM   1. Open Command Prompt or PowerShell as Administrator
REM   2. Navigate to the project directory
REM   3. Run: LOCAL_SETUP_START.bat
REM
REM =============================================================================

setlocal enabledelayedexpansion

echo.
echo ================================================================================
echo                                                                              
echo            POZMIXAL - Local Development Environment Setup                     
echo           Enterprise Social Media Orchestration Platform                     
echo                                                                              
echo ================================================================================
echo.

REM Check if we're in the correct directory
if not exist "package.json" (
    echo ERROR: package.json not found. Please run this script from the project root.
    exit /b 1
)

REM =============================================================================
REM PHASE 1: Check Prerequisites
REM =============================================================================

echo PHASE 1: Checking Prerequisites...
echo ================================================================================
echo.

echo Checking Node.js...
node --version > nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js not found. Please install Node.js 22+ from https://nodejs.org
    exit /b 1
)
for /f "tokens=*" %%i in ('node --version') do echo   Found: %%i

echo Checking npm...
npm --version > nul 2>&1
if errorlevel 1 (
    echo ERROR: npm not found.
    exit /b 1
)
for /f "tokens=*" %%i in ('npm --version') do echo   Found: %%i

echo Checking pnpm...
pnpm --version > nul 2>&1
if errorlevel 1 (
    echo Installing pnpm globally...
    call npm install -g pnpm
)
for /f "tokens=*" %%i in ('pnpm --version') do echo   Found: %%i

echo Checking Docker...
docker --version > nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker not found. Please install Docker Desktop.
    exit /b 1
)
for /f "tokens=*" %%i in ('docker --version') do echo   Found: %%i

echo Checking Docker daemon...
docker ps > nul 2>&1
if errorlevel 1 (
    echo WARNING: Docker daemon not running. Attempting to start Docker Desktop...
    REM Try to start Docker Desktop
    start "" "C:\Program Files\Docker\Docker\Docker.exe"
    timeout /t 5 /nobreak
    docker ps > nul 2>&1
    if errorlevel 1 (
        echo ERROR: Docker daemon failed to start. Please start Docker Desktop manually.
        exit /b 1
    )
)
echo   Docker daemon is running

echo.

REM =============================================================================
REM PHASE 2: Set Up Environment
REM =============================================================================

echo PHASE 2: Setting Up Environment...
echo ================================================================================
echo.

if exist ".env" (
    echo   .env file already exists
) else (
    echo Creating .env from .env.local...
    copy ".env.local" ".env" > nul
    echo   .env file created
)

echo.

REM =============================================================================
REM PHASE 3: Start Docker Services
REM =============================================================================

echo PHASE 3: Starting Docker Services...
echo ================================================================================
echo.

echo Starting PostgreSQL container...
docker compose -f docker-compose.dev.yaml up -d pozmixal-postgres
if errorlevel 1 (
    echo ERROR: Failed to start PostgreSQL
    exit /b 1
)
echo   PostgreSQL started

echo Starting Redis container...
docker compose -f docker-compose.dev.yaml up -d pozmixal-redis
if errorlevel 1 (
    echo ERROR: Failed to start Redis
    exit /b 1
)
echo   Redis started

echo Waiting for PostgreSQL to be ready (this may take 10-30 seconds)...
setlocal enabledelayedexpansion
set "pg_ready=0"
set "attempt=0"
:check_pg
docker exec pozmixal-postgres pg_isready -U pozmixal-local > nul 2>&1
if not errorlevel 1 (
    set "pg_ready=1"
) else (
    set /a attempt=!attempt!+1
    if !attempt! lss 30 (
        timeout /t 1 /nobreak > nul
        goto check_pg
    )
)

if !pg_ready! equ 0 (
    echo ERROR: PostgreSQL failed to start
    exit /b 1
)
echo   PostgreSQL is ready

echo Starting optional services (pgAdmin, RedisInsight)...
docker compose -f docker-compose.dev.yaml up -d pozmixal-pg-admin pozmixal-redisinsight 2>nul
echo   Optional services started

echo.

REM =============================================================================
REM PHASE 4: Install Dependencies
REM =============================================================================

echo PHASE 4: Installing Dependencies...
echo ================================================================================
echo.

if exist "node_modules" (
    echo   Dependencies already installed (node_modules exists)
) else (
    echo Installing dependencies with pnpm (this may take 3-5 minutes)...
    call pnpm install --frozen-lockfile
    if errorlevel 1 (
        echo ERROR: Failed to install dependencies
        exit /b 1
    )
    echo   Dependencies installed successfully
)

echo.

REM =============================================================================
REM PHASE 5: Prisma Setup
REM =============================================================================

echo PHASE 5: Setting Up Database Schema...
echo ================================================================================
echo.

echo Generating Prisma client...
call pnpm run prisma-generate
if errorlevel 1 (
    echo ERROR: Failed to generate Prisma client
    exit /b 1
)
echo   Prisma client generated

echo Running database migrations...
call pnpm run prisma-db-push
if errorlevel 1 (
    echo ERROR: Failed to run database migrations
    exit /b 1
)
echo   Database migrations completed

echo.

REM =============================================================================
REM PHASE 6: Start Development Services
REM =============================================================================

echo PHASE 6: Starting Development Services...
echo ================================================================================
echo.

echo.
echo ================================================================================
echo                   ALL SETUP COMPLETE - STARTING SERVICES
echo ================================================================================
echo.
echo  The following services will start:
echo.
echo  ^>^> Frontend    (Next.js)       http://localhost:4200
echo  ^>^> Backend     (NestJS)        http://localhost:3000
echo  ^>^> Database    (PostgreSQL)    localhost:5432
echo  ^>^> Redis       (In-Memory)     localhost:6379
echo  ^>^> pgAdmin     (Database UI)   http://localhost:8081
echo  ^>^> RedisInsight                http://localhost:5540
echo.
echo  Credentials:
echo  - Database User: pozmixal-local
echo  - Database Password: pozmixal-local-pwd
echo  - pgAdmin Email: admin@admin.com
echo  - pgAdmin Password: admin
echo.
echo  To stop services: Press Ctrl+C
echo.
echo ================================================================================
echo.

pause

call pnpm run dev

exit /b 0
