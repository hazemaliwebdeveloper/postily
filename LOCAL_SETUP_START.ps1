# =============================================================================
# POZMIXAL - Complete Local Development Setup Script
# =============================================================================
# This script sets up and runs the complete Pozmixal application locally
# 
# Prerequisites:
#   - Node.js 22+ (check with: node --version)
#   - Docker Desktop installed and running
#   - pnpm installed (or npm install -g pnpm)
#
# What this script does:
#   1. Checks all prerequisites
#   2. Starts Docker and required services
#   3. Installs dependencies
#   4. Generates Prisma client
#   5. Runs database migrations
#   6. Starts all development services
#
# =============================================================================

$ErrorActionPreference = "Stop"

# Colors for output
$colors = @{
    Green  = "Green"
    Red    = "Red"
    Yellow = "Yellow"
    Cyan   = "Cyan"
}

function Write-Step {
    param([string]$message)
    Write-Host "→ $message" -ForegroundColor $colors.Cyan
}

function Write-Success {
    param([string]$message)
    Write-Host "✓ $message" -ForegroundColor $colors.Green
}

function Write-Error-Custom {
    param([string]$message)
    Write-Host "✗ $message" -ForegroundColor $colors.Red
    exit 1
}

function Write-Warning-Custom {
    param([string]$message)
    Write-Host "⚠ $message" -ForegroundColor $colors.Yellow
}

Clear-Host

Write-Host @"

╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║           POZMIXAL - Local Development Environment Setup              ║
║          Enterprise Social Media Orchestration Platform              ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor $colors.Cyan

# =============================================================================
# PHASE 1: Check Prerequisites
# =============================================================================

Write-Host "PHASE 1: Checking Prerequisites..." -ForegroundColor $colors.Yellow
Write-Host "━" * 73

# Check Node.js
Write-Step "Checking Node.js..."
try {
    $nodeVersion = node --version
    Write-Success "Node.js $nodeVersion installed"
} catch {
    Write-Error-Custom "Node.js not found. Please install Node.js 22+ from https://nodejs.org"
}

# Check npm
Write-Step "Checking npm..."
try {
    $npmVersion = npm --version
    Write-Success "npm $npmVersion installed"
} catch {
    Write-Error-Custom "npm not found. Please install Node.js with npm"
}

# Check pnpm
Write-Step "Checking pnpm..."
try {
    $pnpmVersion = pnpm --version
    Write-Success "pnpm $pnpmVersion installed"
} catch {
    Write-Warning-Custom "pnpm not found. Installing globally..."
    npm install -g pnpm
    $pnpmVersion = pnpm --version
    Write-Success "pnpm $pnpmVersion installed"
}

# Check Docker
Write-Step "Checking Docker..."
try {
    $dockerVersion = docker --version
    Write-Success "$dockerVersion installed"
} catch {
    Write-Error-Custom "Docker not found. Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
}

# Check Docker daemon
Write-Step "Checking Docker daemon..."
try {
    docker info > $null 2>&1
    Write-Success "Docker daemon is running"
} catch {
    Write-Warning-Custom "Docker daemon not running. Starting Docker Desktop..."
    Write-Host ""
    Write-Host "Please start Docker Desktop and then press any key to continue..."
    Read-Host
    
    # Try again
    try {
        docker info > $null 2>&1
        Write-Success "Docker daemon is now running"
    } catch {
        Write-Error-Custom "Docker daemon still not running. Please start Docker Desktop manually."
    }
}

# =============================================================================
# PHASE 2: Set Up Environment
# =============================================================================

Write-Host ""
Write-Host "PHASE 2: Setting Up Environment..." -ForegroundColor $colors.Yellow
Write-Host "━" * 73

Write-Step "Checking .env file..."
$envPath = ".env"
if (Test-Path $envPath) {
    Write-Success ".env file exists"
} else {
    Write-Step "Creating .env file from .env.local..."
    Copy-Item -Path ".env.local" -Destination $envPath
    Write-Success ".env file created"
}

# =============================================================================
# PHASE 3: Start Docker Services
# =============================================================================

Write-Host ""
Write-Host "PHASE 3: Starting Docker Services..." -ForegroundColor $colors.Yellow
Write-Host "━" * 73

Write-Step "Starting PostgreSQL container..."
try {
    docker compose -f docker-compose.dev.yaml up -d pozmixal-postgres 2>$null
    Write-Success "PostgreSQL started"
} catch {
    Write-Error-Custom "Failed to start PostgreSQL container"
}

Write-Step "Starting Redis container..."
try {
    docker compose -f docker-compose.dev.yaml up -d pozmixal-redis 2>$null
    Write-Success "Redis started"
} catch {
    Write-Error-Custom "Failed to start Redis container"
}

Write-Step "Waiting for PostgreSQL to be ready (this may take 10-30 seconds)..."
$maxAttempts = 30
$attempt = 0
while ($attempt -lt $maxAttempts) {
    try {
        docker exec pozmixal-postgres pg_isready -U pozmixal-local 2>$null | Out-Null
        Write-Success "PostgreSQL is ready"
        break
    } catch {
        $attempt++
        if ($attempt -lt $maxAttempts) {
            Start-Sleep -Seconds 1
            Write-Host "  Waiting... ($attempt/$maxAttempts)" -ForegroundColor $colors.Yellow
        }
    }
}

if ($attempt -eq $maxAttempts) {
    Write-Error-Custom "PostgreSQL failed to start within timeout"
}

Write-Step "Starting optional services (pgAdmin, RedisInsight)..."
try {
    docker compose -f docker-compose.dev.yaml up -d pozmixal-pg-admin pozmixal-redisinsight 2>$null
    Write-Success "Optional services started"
} catch {
    Write-Warning-Custom "Optional services failed to start (not critical)"
}

# =============================================================================
# PHASE 4: Install Dependencies
# =============================================================================

Write-Host ""
Write-Host "PHASE 4: Installing Dependencies..." -ForegroundColor $colors.Yellow
Write-Host "━" * 73

$nodeModulesPath = "node_modules"
if (Test-Path $nodeModulesPath) {
    Write-Success "Dependencies already installed (node_modules exists)"
} else {
    Write-Step "Installing dependencies with pnpm (this may take 3-5 minutes)..."
    try {
        pnpm install --frozen-lockfile
        Write-Success "Dependencies installed successfully"
    } catch {
        Write-Error-Custom "Failed to install dependencies. Check pnpm-lock.yaml"
    }
}

# =============================================================================
# PHASE 5: Prisma Setup
# =============================================================================

Write-Host ""
Write-Host "PHASE 5: Setting Up Database Schema..." -ForegroundColor $colors.Yellow
Write-Host "━" * 73

Write-Step "Generating Prisma client..."
try {
    pnpm run prisma-generate
    Write-Success "Prisma client generated"
} catch {
    Write-Error-Custom "Failed to generate Prisma client"
}

Write-Step "Running database migrations..."
try {
    pnpm run prisma-db-push
    Write-Success "Database migrations completed"
} catch {
    Write-Error-Custom "Failed to run database migrations. Check database connection."
}

# =============================================================================
# PHASE 6: Start Development Services
# =============================================================================

Write-Host ""
Write-Host "PHASE 6: Starting Development Services..." -ForegroundColor $colors.Yellow
Write-Host "━" * 73

Write-Host @"

╔═══════════════════════════════════════════════════════════════════════╗
║                  ALL SETUP COMPLETE - STARTING SERVICES              ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║  The following services will start:                                  ║
║                                                                       ║
║  🌐 Frontend    (Next.js)       http://localhost:4200                ║
║  🔧 Backend     (NestJS)        http://localhost:3000                ║
║  🐘 Database    (PostgreSQL)    localhost:5432                       ║
║  🗂️  Redis       (In-Memory)     localhost:6379                       ║
║  📊 pgAdmin     (Database UI)   http://localhost:8081                ║
║  📊 RedisInsight                http://localhost:5540                ║
║                                                                       ║
║  Credentials:                                                         ║
║  ├─ Database User: pozmixal-local                                    ║
║  ├─ Database Password: pozmixal-local-pwd                            ║
║  ├─ pgAdmin Email: admin@admin.com                                   ║
║  └─ pgAdmin Password: admin                                          ║
║                                                                       ║
║  Next Steps:                                                          ║
║  1. Wait for all services to start (watch console for URLs)          ║
║  2. Open http://localhost:4200 in your browser                       ║
║  3. Create a new account and start building                          ║
║                                                                       ║
║  To stop services:                                                    ║
║  ├─ Press Ctrl+C in this terminal                                    ║
║  └─ Run: docker compose -f docker-compose.dev.yaml down              ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝

" -ForegroundColor $colors.Green

Write-Host "Press any key to start services..." -ForegroundColor $colors.Yellow
Read-Host

Write-Step "Starting all development services..."
Write-Host ""

try {
    pnpm run dev
} catch {
    Write-Error-Custom "Failed to start development services"
}
