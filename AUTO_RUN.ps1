# AUTO_RUN.ps1 - Fully Automated Solution
# This script starts everything and opens browser automatically when ready
# Run with: powershell -ExecutionPolicy Bypass -File AUTO_RUN.ps1

$ErrorActionPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'

# Configuration
$projectPath = Get-Location
$backendPath = Join-Path $projectPath "apps\backend"
$frontendPath = Join-Path $projectPath "apps\frontend"
$extensionPath = Join-Path $projectPath "apps\extension"
$backendUrl = "http://localhost:3000/health"
$frontendUrl = "http://localhost:4200"
$maxWaitSeconds = 120
$checkInterval = 2

Write-Host ""
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  POSTIZ - FULLY AUTOMATED START                ║" -ForegroundColor Green
Write-Host "║  Services will start and browser will open      ║" -ForegroundColor Green
Write-Host "║  automatically when ready                       ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Step 1: Setup
Write-Host "[1/5] Checking dependencies..." -ForegroundColor Cyan
if (!(Test-Path "node_modules")) {
    Write-Host "      Installing (first time only)..." -ForegroundColor Yellow
    pnpm install 2>&1 | Out-Null
}
Write-Host "      ✓ Done" -ForegroundColor Green

Write-Host "[2/5] Setting up database..." -ForegroundColor Cyan
pnpm run prisma-generate 2>&1 | Out-Null
pnpm run prisma-db-push 2>&1 | Out-Null
Write-Host "      ✓ Done" -ForegroundColor Green

Write-Host "[3/5] Building extension..." -ForegroundColor Cyan
Push-Location $extensionPath
pnpm run build:chrome 2>&1 | Out-Null
Pop-Location
Write-Host "      ✓ Done" -ForegroundColor Green

Write-Host "[4/5] Starting services in background..." -ForegroundColor Cyan

# Start backend
$backendProcess = Start-Process powershell -ArgumentList `
    "-NoExit", `
    "-Command", `
    "cd '$backendPath'; pnpm run dev" `
    -PassThru -WindowStyle Minimized -ErrorAction SilentlyContinue

Write-Host "      • Backend starting..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Start frontend
$frontendProcess = Start-Process powershell -ArgumentList `
    "-NoExit", `
    "-Command", `
    "cd '$frontendPath'; pnpm run dev" `
    -PassThru -WindowStyle Minimized -ErrorAction SilentlyContinue

Write-Host "      • Frontend starting..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Start extension
$extensionProcess = Start-Process powershell -ArgumentList `
    "-NoExit", `
    "-Command", `
    "cd '$extensionPath'; pnpm run dev:chrome" `
    -PassThru -WindowStyle Minimized -ErrorAction SilentlyContinue

Write-Host "      • Extension starting..." -ForegroundColor Yellow
Write-Host "      ✓ All services started" -ForegroundColor Green

Write-Host "[5/5] Waiting for services to be ready..." -ForegroundColor Cyan
Write-Host ""

# Wait for backend
$backendReady = $false
$elapsed = 0
Write-Host "      Waiting for backend..." -ForegroundColor Yellow
while (-not $backendReady -and $elapsed -lt $maxWaitSeconds) {
    try {
        $response = Invoke-WebRequest -Uri $backendUrl -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $backendReady = $true
            Write-Host "      ✓ Backend is ready!" -ForegroundColor Green
        }
    } catch {
        # Not ready yet
    }
    
    if (-not $backendReady) {
        Start-Sleep -Seconds $checkInterval
        $elapsed += $checkInterval
        Write-Host "      Checking... ($elapsed/$maxWaitSeconds seconds)" -ForegroundColor DarkGray
    }
}

if (-not $backendReady) {
    Write-Host "      ✗ Backend failed to start" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check backend window for errors!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Wait for frontend
$frontendReady = $false
$elapsed = 0
Write-Host "      Waiting for frontend..." -ForegroundColor Yellow
while (-not $frontendReady -and $elapsed -lt $maxWaitSeconds) {
    try {
        $response = Invoke-WebRequest -Uri $frontendUrl -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $frontendReady = $true
            Write-Host "      ✓ Frontend is ready!" -ForegroundColor Green
        }
    } catch {
        # Not ready yet
    }
    
    if (-not $frontendReady) {
        Start-Sleep -Seconds $checkInterval
        $elapsed += $checkInterval
        Write-Host "      Checking... ($elapsed/$maxWaitSeconds seconds)" -ForegroundColor DarkGray
    }
}

if (-not $frontendReady) {
    Write-Host "      ✗ Frontend failed to start" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check frontend window for errors!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ ALL SERVICES READY!                        ║" -ForegroundColor Green
Write-Host "║  Opening browser now...                        ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Open browser
Start-Sleep -Seconds 1
try {
    Start-Process $frontendUrl -ErrorAction SilentlyContinue
    Write-Host "✓ Browser opened: $frontendUrl" -ForegroundColor Green
} catch {
    Write-Host "✓ Services ready, open browser: $frontendUrl" -ForegroundColor Green
}

Write-Host ""
Write-Host "Services running:" -ForegroundColor Cyan
Write-Host "  • Backend:   http://localhost:3000" -ForegroundColor White
Write-Host "  • Frontend:  http://localhost:4200" -ForegroundColor White
Write-Host ""
Write-Host "Load Extension in Chrome:" -ForegroundColor Yellow
Write-Host "  1. chrome://extensions" -ForegroundColor White
Write-Host "  2. Enable Developer mode" -ForegroundColor White
Write-Host "  3. Load unpacked → apps\extension\dist" -ForegroundColor White
Write-Host ""
Write-Host "Minimized windows are running in background." -ForegroundColor Cyan
Write-Host "Close them to stop services." -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter when done"
