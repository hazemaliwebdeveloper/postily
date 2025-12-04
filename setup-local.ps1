# Local Development Setup Script for Windows
# This script sets up and starts the application locally

$ErrorActionPreference = "Stop"
$project_root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "`n" -ForegroundColor Green
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║      Local Development Environment Setup                       ║" -ForegroundColor Green
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
    Write-Host "[$StepNumber] $Message" -ForegroundColor Cyan
}

# Step 1: Verify Node.js and pnpm
Write-Step "1/6" "Verifying Node.js and pnpm..."
try {
    $node_version = node --version
    $pnpm_version = pnpm --version
    Write-Host "  ✓ Node.js: $node_version" -ForegroundColor Green
    Write-Host "  ✓ pnpm: $pnpm_version" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Node.js or pnpm not found!" -ForegroundColor Red
    Write-Host "  Please install Node.js 22+ and pnpm" -ForegroundColor Yellow
    exit 1
}

# Step 2: Check Docker
Write-Step "2/6" "Checking Docker..."
if (Test-DockerRunning) {
    Write-Host "  ✓ Docker is running" -ForegroundColor Green
}
else {
    Write-Host "  ✗ Docker is not running" -ForegroundColor Red
    Write-Host "  Starting Docker Desktop..." -ForegroundColor Yellow
    
    # Try to start Docker Desktop
    $docker_path = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $docker_path) {
        & $docker_path
        Write-Host "  Waiting 30 seconds for Docker to start..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        
        if (Test-DockerRunning) {
            Write-Host "  ✓ Docker started successfully" -ForegroundColor Green
        }
        else {
            Write-Host "  ✗ Docker failed to start" -ForegroundColor Red
            Write-Host "  Please start Docker Desktop manually" -ForegroundColor Yellow
            exit 1
        }
    }
    else {
        Write-Host "  ✗ Docker Desktop not found at $docker_path" -ForegroundColor Red
        exit 1
    }
}

# Step 3: Start Docker containers
Write-Step "3/6" "Starting Docker containers (PostgreSQL + Redis)..."
try {
    $postgres_running = Test-ContainerRunning "pozmixal-postgres"
    $redis_running = Test-ContainerRunning "pozmixal-redis"
    
    if ($postgres_running -and $redis_running) {
        Write-Host "  ✓ Containers already running" -ForegroundColor Green
    }
    else {
        Write-Host "  Starting containers..." -ForegroundColor Yellow
        Set-Location $project_root
        docker compose -f docker-compose.dev.yaml up -d 2>&1 | ForEach-Object {
            if ($_ -match "ERROR|error") {
                Write-Host "  ⚠ $_" -ForegroundColor Yellow
            }
        }
        
        Write-Host "  ✓ Docker containers started" -ForegroundColor Green
        Write-Host "    - PostgreSQL: localhost:5432" -ForegroundColor Gray
        Write-Host "    - Redis: localhost:6379" -ForegroundColor Gray
        Write-Host "  Waiting 10 seconds for services to be ready..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
    }
}
catch {
    Write-Host "  ⚠ Warning: Could not start containers: $_" -ForegroundColor Yellow
}

# Step 4: Install dependencies
Write-Step "4/6" "Installing dependencies (this may take 5-10 minutes)..."
try {
    Set-Location $project_root
    pnpm install 2>&1 | Out-Null
    Write-Host "  ✓ Dependencies installed" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Failed to install dependencies: $_" -ForegroundColor Red
    exit 1
}

# Step 5: Generate Prisma client
Write-Step "5/6" "Generating Prisma client..."
try {
    Set-Location $project_root
    pnpm run prisma-generate 2>&1 | Out-Null
    Write-Host "  ✓ Prisma client generated" -ForegroundColor Green
}
catch {
    Write-Host "  ⚠ Warning: Prisma generation had issues: $_" -ForegroundColor Yellow
    Write-Host "  This may be resolved when dev server starts" -ForegroundColor Yellow
}

# Step 6: Start development servers
Write-Step "6/6" "Starting development servers..."
Write-Host "`n" -ForegroundColor Green
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║          Starting Application in Development Mode              ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n"
Write-Host "Frontend:  http://localhost:4200" -ForegroundColor Cyan
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
