# Quick Start - Postiz Application
# Run with: powershell -ExecutionPolicy Bypass -File RUN_NOW.ps1

function Write-Status {
    param([string]$Message, [ValidateSet("Info", "Success", "Warning", "Error")]$Type = "Info")
    
    switch ($Type) {
        "Success" { Write-Host $Message -ForegroundColor Green }
        "Error" { Write-Host $Message -ForegroundColor Red }
        "Warning" { Write-Host $Message -ForegroundColor Yellow }
        default { Write-Host $Message -ForegroundColor Cyan }
    }
}

Clear-Host
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   POSTIZ - START APPLICATION             ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Step 1: Check dependencies
Write-Status "[STEP 1/4] Checking dependencies..." "Info"
if (!(Test-Path "node_modules")) {
    Write-Host "Installing dependencies..."
    pnpm install 2>&1 | Out-Null
} else {
    Write-Status "✓ Dependencies already installed" "Success"
}

# Step 2: Setup database
Write-Host ""
Write-Status "[STEP 2/4] Setting up database..." "Info"
pnpm run prisma-generate 2>&1 | Out-Null
pnpm run prisma-db-push 2>&1 | Out-Null
Write-Status "✓ Database ready" "Success"

# Step 3: Build extension
Write-Host ""
Write-Status "[STEP 3/4] Building extension..." "Info"
Push-Location "apps/extension"
pnpm run build:chrome 2>&1 | Out-Null
Pop-Location
Write-Status "✓ Extension built" "Success"

Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   STARTING SERVICES                      ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Start services
Write-Status "[*] Starting Backend (port 3000)..." "Info"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\apps\backend'; pnpm run dev" -WindowStyle Normal
Start-Sleep -Milliseconds 2000

Write-Status "[*] Starting Frontend (port 4200)..." "Info"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\apps\frontend'; pnpm run dev" -WindowStyle Normal
Start-Sleep -Milliseconds 2000

Write-Status "[*] Starting Extension (watch mode)..." "Info"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\apps\extension'; pnpm run dev:chrome" -WindowStyle Normal
Start-Sleep -Milliseconds 2000

Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   APPLICATION RUNNING                    ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Status "Frontend: http://localhost:4200" "Success"
Write-Status "Backend:  http://localhost:3000" "Success"
Write-Host ""

Write-Host "Next: Load extension in Chrome" -ForegroundColor Yellow
Write-Host "  1. Open Chrome" -ForegroundColor White
Write-Host "  2. Go to: chrome://extensions" -ForegroundColor White
Write-Host "  3. Enable 'Developer mode' (top right)" -ForegroundColor White
Write-Host "  4. Click 'Load unpacked'" -ForegroundColor White
Write-Host "  5. Select: apps\extension\dist" -ForegroundColor White
Write-Host "  6. Click 'Open'" -ForegroundColor White
Write-Host ""

Write-Host "Servers will continue running in separate windows." -ForegroundColor Cyan
Write-Host "Close any window to stop that service." -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to exit"
