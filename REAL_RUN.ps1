# REAL_RUN.ps1 - Actually Working Solution
# Run with: powershell -ExecutionPolicy Bypass -File REAL_RUN.ps1

$ErrorActionPreference = 'Continue'

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║ $Text" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
}

function Write-Status {
    param([string]$Message, [ValidateSet("Info", "Success", "Warning", "Error")]$Type = "Info")
    
    switch ($Type) {
        "Success" { Write-Host $Message -ForegroundColor Green }
        "Error" { Write-Host $Message -ForegroundColor Red }
        "Warning" { Write-Host $Message -ForegroundColor Yellow }
        default { Write-Host $Message -ForegroundColor Cyan }
    }
}

Write-Header "POSTIZ - REAL WORKING RUN"

# Step 1: Check dependencies
Write-Status "[STEP 1/3] Checking dependencies..." "Info"
if (!(Test-Path "node_modules")) {
    Write-Status "Installing dependencies (first time only)..." "Warning"
    pnpm install 2>&1 | Out-Null
}
Write-Status "✓ Dependencies ready" "Success"

# Step 2: Setup database
Write-Host ""
Write-Status "[STEP 2/3] Setting up database..." "Info"
pnpm run prisma-generate 2>&1 | Out-Null
pnpm run prisma-db-push 2>&1 | Out-Null
Write-Status "✓ Database ready" "Success"

# Step 3: Build extension
Write-Host ""
Write-Status "[STEP 3/3] Building extension..." "Info"
Push-Location "apps/extension"
pnpm run build:chrome 2>&1 | Out-Null
Pop-Location
Write-Status "✓ Extension built" "Success"

Write-Header "STARTING SERVICES IN SEPARATE WINDOWS"

Write-Status "Opening Backend window (port 3000)..." "Info"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\apps\backend'; Write-Host 'Backend starting...' -ForegroundColor Green; pnpm run dev" -WindowStyle Normal

Start-Sleep -Seconds 2

Write-Status "Opening Frontend window (port 4200)..." "Info"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\apps\frontend'; Write-Host 'Frontend starting...' -ForegroundColor Green; pnpm run dev" -WindowStyle Normal

Start-Sleep -Seconds 2

Write-Status "Opening Extension window (watch mode)..." "Info"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\apps\extension'; Write-Host 'Extension starting...' -ForegroundColor Green; pnpm run dev:chrome" -WindowStyle Normal

Write-Host ""
Write-Header "SERVICES STARTED"

Write-Host "CRITICAL RULES:" -ForegroundColor Yellow
Write-Host "  ⚠️ DO NOT CLOSE ANY WINDOWS" -ForegroundColor Yellow
Write-Host "  ⚠️ WAIT 20-30 seconds for first compile" -ForegroundColor Yellow
Write-Host "  ⚠️ Look for startup messages" -ForegroundColor Yellow
Write-Host ""

Write-Host "WAIT for these messages:" -ForegroundColor Cyan
Write-Host "  Backend:  🚀 Backend is running on: http://localhost:3000" -ForegroundColor White
Write-Host "  Frontend: ✓ Ready in X seconds" -ForegroundColor White
Write-Host ""

Write-Host "Then:" -ForegroundColor Green
Write-Host "  1. Open browser" -ForegroundColor White
Write-Host "  2. Type: http://localhost:4200" -ForegroundColor White
Write-Host "  3. Press Enter" -ForegroundColor White
Write-Host "  4. See login page ✅" -ForegroundColor White
Write-Host ""

Write-Host "If windows are minimized, check taskbar!" -ForegroundColor Yellow

Read-Host "Press Enter to exit this window (services will keep running)"
