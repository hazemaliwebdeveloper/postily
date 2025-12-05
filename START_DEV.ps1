# Quick Start Development Environment for Postiz
# Run with: powershell -ExecutionPolicy Bypass -File START_DEV.ps1

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "   POSTIZ LOCAL DEVELOPMENT STARTUP" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# Check if pnpm is installed
$pnpmCheck = pnpm --version 2>$null
if (-not $pnpmCheck) {
    Write-Host "ERROR: pnpm is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install pnpm first: npm install -g pnpm" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[1/4] Checking dependencies..." -ForegroundColor Cyan
pnpm install 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install dependencies" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✓ Dependencies installed" -ForegroundColor Green

Write-Host ""
Write-Host "[2/4] Generating Prisma Client..." -ForegroundColor Cyan
pnpm run prisma-generate 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Prisma generation had issues, continuing..." -ForegroundColor Yellow
}
Write-Host "✓ Prisma Client generated" -ForegroundColor Green

Write-Host ""
Write-Host "[3/4] Syncing database..." -ForegroundColor Cyan
pnpm run prisma-db-push 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Database sync had issues" -ForegroundColor Yellow
    Write-Host "Make sure PostgreSQL is running" -ForegroundColor Yellow
}
Write-Host "✓ Database synced" -ForegroundColor Green

Write-Host ""
Write-Host "[4/4] Building extension..." -ForegroundColor Cyan
pnpm --filter ./apps/extension run build:chrome 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Extension build failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✓ Extension built" -ForegroundColor Green

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "   STARTUP COMPLETE" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Services to start:" -ForegroundColor Yellow
Write-Host "  - Backend  (NestJS)     → http://localhost:3000" -ForegroundColor White
Write-Host "  - Frontend (Next.js)    → http://localhost:4200" -ForegroundColor White
Write-Host "  - Extension (Chrome)    → chrome://extensions" -ForegroundColor White
Write-Host ""

Write-Host "To load extension in Chrome:" -ForegroundColor Yellow
Write-Host "  1. Go to: chrome://extensions" -ForegroundColor White
Write-Host "  2. Enable 'Developer mode'" -ForegroundColor White
Write-Host "  3. Click 'Load unpacked'" -ForegroundColor White
Write-Host "  4. Select: apps\extension\dist" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to start all services"

Write-Host ""
Write-Host "Starting all services in parallel..." -ForegroundColor Cyan
Write-Host "This will open multiple terminals. Use Ctrl+C to stop any service." -ForegroundColor Yellow
Write-Host ""

# Start services in separate windows
$services = @(
    @{ Name = "Backend"; Filter = "./apps/backend"; Script = "pnpm --filter ./apps/backend run dev" },
    @{ Name = "Frontend"; Filter = "./apps/frontend"; Script = "pnpm --filter ./apps/frontend run dev" },
    @{ Name = "Extension Watch"; Filter = "./apps/extension"; Script = "pnpm --filter ./apps/extension run dev:chrome" },
    @{ Name = "Workers"; Filter = "./apps/workers"; Script = "pnpm --filter ./apps/workers run dev" },
    @{ Name = "Cron"; Filter = "./apps/cron"; Script = "pnpm --filter ./apps/cron run dev" }
)

foreach ($service in $services) {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $service.Script -WindowStyle Normal
    Start-Sleep -Milliseconds 1500
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "   All services started!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "IMPORTANT: Load extension manually in Chrome" -ForegroundColor Yellow
Write-Host "  1. Open Chrome and go to: chrome://extensions" -ForegroundColor White
Write-Host "  2. Enable 'Developer mode' (toggle at top right)" -ForegroundColor White
Write-Host "  3. Click 'Load unpacked'" -ForegroundColor White
Write-Host "  4. Navigate to and select: apps\extension\dist" -ForegroundColor White
Write-Host "  5. Click 'Open'" -ForegroundColor White
Write-Host ""

Write-Host "The extension should now appear in your Chrome extensions list." -ForegroundColor Green
Write-Host ""
Write-Host "Frontend: http://localhost:4200" -ForegroundColor Cyan
Write-Host "Backend:  http://localhost:3000" -ForegroundColor Cyan
Write-Host ""

Write-Host "Close any terminal to stop that service." -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit"
