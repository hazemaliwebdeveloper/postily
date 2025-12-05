# POZMIXAL - LOCAL DEVELOPMENT SETUP SCRIPT (Windows)
# This script sets up and runs the complete Pozmixal application locally

$ErrorActionPreference = "Stop"
$project_root = Split-Path -Parent $MyInvocation.MyCommand.Path
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

Write-Host "`n" -ForegroundColor Green
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║       POZMIXAL - LOCAL DEVELOPMENT SETUP (Windows)            ║" -ForegroundColor Green
Write-Host "║    Enterprise Social Media Orchestration Platform            ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n"

# Function to check if Docker is running
function Test-DockerRunning {
    try {
        docker ps > $null 2>&1
        return $true
    }
    catch {
        return $false
    }
}

# Function to check if Docker container is running
function Test-ContainerRunning {
    param([string]$ServiceName)
    try {
        $result = docker ps --filter "name=$ServiceName" --quiet
        return -not [string]::IsNullOrEmpty($result)
    }
    catch {
        return $false
    }
}

# Function to print step
function Write-Step {
    param([string]$StepNumber, [string]$Message)
    Write-Host "`n[$StepNumber] $Message" -ForegroundColor Cyan
}

# Function to print success
function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

# Function to print error
function Write-Error {
    param([string]$Message)
    Write-Host "  ❌ $Message" -ForegroundColor Red
}

# Step 1: Verify Node.js and pnpm
Write-Step "1/8" "Checking prerequisites..."
try {
    $node_version = node --version
    $pnpm_version = pnpm --version
    Write-Success "Node.js: $node_version"
    Write-Success "pnpm: $pnpm_version"
}
catch {
    Write-Error "Node.js or pnpm not found!"
    Write-Host "  Please install Node.js 22+ and pnpm" -ForegroundColor Yellow
    exit 1
}

# Step 2: Check Docker
Write-Step "2/8" "Checking Docker..."
if (Test-DockerRunning) {
    Write-Success "Docker is running"
}
else {
    Write-Error "Docker is not running"
    Write-Host "  Starting Docker Desktop..." -ForegroundColor Yellow
    
    # Try to start Docker Desktop
    $docker_path = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $docker_path) {
        & $docker_path
        Write-Host "  Waiting 30 seconds for Docker to start..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        
        if (Test-DockerRunning) {
            Write-Success "Docker started successfully"
        }
        else {
            Write-Error "Docker failed to start"
            Write-Host "  Please start Docker Desktop manually" -ForegroundColor Yellow
            exit 1
        }
    }
    else {
        Write-Error "Docker Desktop not found"
        exit 1
    }
}

# Step 3: Setup environment file
Write-Step "3/8" "Setting up environment configuration..."
$env_file = Join-Path $project_root ".env"
if (-not (Test-Path $env_file)) {
    Write-Host "  Creating .env file..." -ForegroundColor Yellow
    $env_content = @"
# Database Configuration
DATABASE_URL="postgresql://pozmixal-user:pozmixal-password@localhost:5432/pozmixal-db-local"
DATABASE_DIRECT_URL="postgresql://pozmixal-user:pozmixal-password@localhost:5432/pozmixal-db-local"

# Redis Configuration
REDIS_URL="redis://localhost:6379"

# JWT Secret
JWT_SECRET="dev-jwt-secret-$timestamp"

# URL Configuration
FRONTEND_URL="http://localhost:4200"
NEXT_PUBLIC_BACKEND_URL="http://localhost:3000"
BACKEND_URL="http://localhost:3000"
BACKEND_INTERNAL_URL="http://localhost:3000"

# Development Settings
ALLOW_ALL_FEATURES="true"
NODE_ENV="development"
STORAGE_PROVIDER="local"

# Optional: Social Media API Keys (add your own)
X_API_KEY=""
X_API_SECRET=""
LINKEDIN_CLIENT_ID=""
LINKEDIN_CLIENT_SECRET=""
"@
    Set-Content -Path $env_file -Value $env_content
    Write-Success ".env file created"
}
else {
    Write-Success ".env file already exists"
}

# Step 4: Start Docker containers
Write-Step "4/8" "Starting Docker containers (PostgreSQL + Redis)..."
try {
    $postgres_running = Test-ContainerRunning "pozmixal-postgres"
    $redis_running = Test-ContainerRunning "pozmixal-redis"
    
    if ($postgres_running -and $redis_running) {
        Write-Success "Containers already running"
    }
    else {
        Write-Host "  Starting containers..." -ForegroundColor Yellow
        Set-Location $project_root
        docker compose -f docker-compose.dev.yaml up -d 2>&1 | Out-Null
        
        Write-Success "Docker containers started"
        Write-Host "    PostgreSQL: localhost:5432" -ForegroundColor Gray
        Write-Host "    Redis: localhost:6379" -ForegroundColor Gray
        Write-Host "  Waiting for services to be ready..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
}
catch {
    Write-Host "  ⚠ Warning: Could not start containers" -ForegroundColor Yellow
}

# Step 5: Install dependencies
Write-Step "5/8" "Installing dependencies..."
try {
    Set-Location $project_root
    Write-Host "  Running pnpm install..." -ForegroundColor Yellow
    pnpm install 2>&1 | Out-Null
    Write-Success "Dependencies installed"
}
catch {
    Write-Error "Failed to install dependencies"
    exit 1
}

# Step 6: Generate Prisma client
Write-Step "6/8" "Generating Prisma client..."
try {
    Set-Location $project_root
    pnpm run prisma-generate 2>&1 | Out-Null
    Write-Success "Prisma client generated"
}
catch {
    Write-Host "  ⚠ Warning: Prisma generation issues (may resolve on startup)" -ForegroundColor Yellow
}

# Step 7: Run database migrations
Write-Step "7/8" "Running database migrations..."
try {
    Set-Location $project_root
    Write-Host "  Pushing schema to database..." -ForegroundColor Yellow
    pnpm run prisma-db-push 2>&1 | Out-Null
    Write-Success "Database migrations complete"
}
catch {
    Write-Host "  ⚠ Warning: Database migration issues (may resolve on startup)" -ForegroundColor Yellow
}

# Step 8: Start development servers
Write-Step "8/8" "Starting development servers..."
Write-Host "`n" -ForegroundColor Green
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║            POZMIXAL IS STARTING IN DEVELOPMENT MODE            ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║                                                                 ║" -ForegroundColor Green
Write-Host "║  🌐 Frontend  (Next.js)        http://localhost:4200           ║" -ForegroundColor Green
Write-Host "║  🔧 Backend   (NestJS)         http://localhost:3000           ║" -ForegroundColor Green
Write-Host "║  🗄️  Database  (PostgreSQL)     localhost:5432                 ║" -ForegroundColor Green
Write-Host "║  💾 Cache     (Redis)          localhost:6379                  ║" -ForegroundColor Green
Write-Host "║  📊 pgAdmin   (DB UI)          http://localhost:8081           ║" -ForegroundColor Green
Write-Host "║  📊 RedisInsight               http://localhost:8001           ║" -ForegroundColor Green
Write-Host "║                                                                 ║" -ForegroundColor Green
Write-Host "║  Database Credentials:                                         ║" -ForegroundColor Green
Write-Host "║  - User: pozmixal-user                                         ║" -ForegroundColor Green
Write-Host "║  - Pass: pozmixal-password                                     ║" -ForegroundColor Green
Write-Host "║                                                                 ║" -ForegroundColor Green
Write-Host "║  Press Ctrl+C to stop all services                             ║" -ForegroundColor Green
Write-Host "║                                                                 ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n"

# Start all services
try {
    Set-Location $project_root
    pnpm run dev
}
catch {
    Write-Error "Failed to start development servers"
    exit 1
}
Write-Host "Backend:   http://localhost:3000" -ForegroundColor Cyan
Write-Host "`n"
Write-Host "Press Ctrl+C to stop all services" -ForegroundColor Yellow
Write-Host "`n"

Set-Location $project_root
try {
    pnpm run dev
}
catch {
    Write-Host "Error starting dev server: $_" -ForegroundColor Red
    exit 1
}
