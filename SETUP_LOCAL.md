# 🚀 Local Development Setup - Postiz

## Prerequisites

Ensure you have the following installed:
- **Node.js 22** (from `.engines.node` in package.json)
- **pnpm 10.6.1+** (package manager)
- **PostgreSQL 15+** (database)
- **Redis** (cache & queues)
- **Chrome/Chromium** (for extension testing)

## Step 1: Environment Setup

### 1.1 Database Setup
```powershell
# Ensure PostgreSQL is running with the credentials from .env
# Default credentials from .env:
# User: pozmixal-local
# Password: pozmixal-local-pwd
# Database: pozmixal-db-local
# Port: 5432

# Create database (if not exists):
# In PostgreSQL CLI:
# CREATE USER "pozmixal-local" WITH PASSWORD 'pozmixal-local-pwd';
# CREATE DATABASE "pozmixal-db-local" OWNER "pozmixal-local";
```

### 1.2 Redis Setup
```powershell
# Start Redis (default port 6379)
# Using Docker:
docker run -d -p 6379:6379 redis:latest

# Or if installed locally:
redis-server
```

### 1.3 Environment Variables
All environment variables are pre-configured in `.env`:
- `FRONTEND_URL=http://localhost:4200` (Next.js frontend)
- `BACKEND_URL=http://localhost:3000` (NestJS backend)
- `REDIS_URL=redis://localhost:6379` (Redis)
- `DATABASE_URL=postgresql://...` (PostgreSQL)

## Step 2: Install Dependencies

```powershell
cd c:\Users\it\Downloads\pozmixal\postily

# Install all workspace dependencies
pnpm install

# This will automatically:
# - Install root dependencies
# - Install dependencies for all apps (frontend, backend, extension, etc.)
# - Generate Prisma Client
```

## Step 3: Database Initialization

```powershell
# Generate Prisma Client
pnpm run prisma-generate

# Push schema to database (creates tables)
pnpm run prisma-db-push

# Optional: Reset database to fresh state
pnpm run prisma-reset
```

## Step 4: Build Extension

```powershell
# Build the extension for Chrome
pnpm --filter ./apps/extension run build:chrome

# Output: apps/extension/dist/
# This folder contains the built extension ready for Chrome
```

## Step 5: Run All Services (Development Mode)

### Option A: Run All Apps in Parallel
```powershell
# Start all services at once:
# - Frontend (Next.js) on port 4200
# - Backend (NestJS) on port 3000
# - Cron service
# - Workers
# - Extension (watch mode)
pnpm run dev
```

### Option B: Run Individual Services

#### Terminal 1 - Backend (NestJS)
```powershell
pnpm --filter ./apps/backend run dev
# Runs on http://localhost:3000
# Listens for messages from extension
```

#### Terminal 2 - Frontend (Next.js)
```powershell
pnpm --filter ./apps/frontend run dev
# Runs on http://localhost:4200
# UI for the application
```

#### Terminal 3 - Extension (Watch Mode)
```powershell
pnpm --filter ./apps/extension run dev:chrome
# Watches for changes and rebuilds dist/
```

#### Terminal 4 - Workers
```powershell
pnpm --filter ./apps/workers run dev
# Runs background job processor
```

#### Terminal 5 - Cron
```powershell
pnpm --filter ./apps/cron run dev
# Runs scheduled tasks
```

## Step 6: Load Extension in Chrome

### 6.1 Open Chrome Extension Manager
```
chrome://extensions
```

### 6.2 Enable Developer Mode
- Toggle "Developer mode" in top-right corner

### 6.3 Load Unpacked Extension
1. Click "Load unpacked"
2. Navigate to: `apps/extension/dist/`
3. Select the `dist` folder
4. Extension should appear in the list

### 6.4 Verify Extension Status
- Extension should show as "active"
- Service Worker should show as "Service worker (active)"
- If you see "Cannot load the extension" error, rebuild it:
  ```powershell
  pnpm --filter ./apps/extension run build:chrome
  ```

## Step 7: Test the Application

### 7.1 Test Backend Connection
```powershell
# Check if backend is running and responding
curl http://localhost:3000/health

# Expected response: OK or health status
```

### 7.2 Test Extension with Frontend
1. Visit `http://localhost:4200` in Chrome
2. Click the Postiz extension icon in Chrome toolbar
3. Should see popup loading
4. If errors appear in popup, check:
   - Service Worker logs (chrome://extensions → Postiz → Service Worker)
   - Browser console (F12 → Console tab)

### 7.3 Check Service Worker Logs
1. Go to `chrome://extensions`
2. Find "Postiz" extension
3. Click "Service Worker" link
4. DevTools opens showing service worker console
5. Look for messages like:
   ```
   [Service Worker] Background script loaded and ready to accept messages
   [Service Worker] Health check from content script
   [Service Worker] Storage loaded: auth = [token]
   ```

## Troubleshooting

### Extension Won't Load
**Error**: "Cannot load the extension"
```powershell
# Solution: Rebuild the extension
pnpm --filter ./apps/extension run build:chrome

# Then reload in Chrome:
# Go to chrome://extensions → Postiz → Reload button
```

### Service Worker Not Ready
**Error**: "Service worker not ready" in popup
```powershell
# Check service worker logs:
# 1. chrome://extensions
# 2. Click "Service Worker" link for Postiz
# 3. Wait 2-3 seconds and refresh (F5)
# 4. Look for initialization messages
```

### "Receiving end does not exist" Error
**Cause**: Service worker crashed or not initialized
```powershell
# Solution: The retry logic handles this automatically (3-5 retries)
# If still failing:
# 1. Reload extension (chrome://extensions → Postiz → Reload)
# 2. Clear browser data (Settings → Privacy → Clear browsing data)
# 3. Rebuild and reload extension
```

### Database Connection Error
**Error**: `Error: connect ECONNREFUSED 127.0.0.1:5432`
```powershell
# Solution: Ensure PostgreSQL is running
# Check connection:
# On Windows: psql -U pozmixal-local -d pozmixal-db-local -c "SELECT 1"
# If not working, restart PostgreSQL service
```

### Redis Connection Error
**Error**: `Error: connect ECONNREFUSED 127.0.0.1:6379`
```powershell
# Solution: Ensure Redis is running
# If using Docker:
docker ps | grep redis

# If not running:
docker run -d -p 6379:6379 redis:latest
```

### Vite/Build Errors
**Error**: `Cannot find module '@gitroom/extension/...'`
```powershell
# Solution: Clear cache and rebuild
pnpm install
pnpm --filter ./apps/extension run build:chrome
```

## Quick Reference Commands

```powershell
# Install dependencies
pnpm install

# Database operations
pnpm run prisma-generate  # Generate Prisma Client
pnpm run prisma-db-push   # Sync database schema
pnpm run prisma-reset     # Reset database

# Development
pnpm run dev              # Run all apps
pnpm --filter ./apps/backend run dev    # Backend only
pnpm --filter ./apps/frontend run dev   # Frontend only
pnpm --filter ./apps/extension run dev:chrome  # Extension only

# Build
pnpm run build:extension   # Build all apps
pnpm --filter ./apps/extension run build:chrome  # Extension only

# Tests
pnpm test                 # Run all tests
```

## Project Structure

```
postily/
├── apps/
│   ├── backend/          # NestJS API (port 3000)
│   ├── frontend/         # Next.js UI (port 4200)
│   ├── extension/        # Chrome Extension
│   ├── cron/             # Scheduled tasks
│   ├── workers/          # Background jobs
│   ├── commands/         # CLI commands
│   └── sdk/              # Public SDK
├── libraries/            # Shared code
│   ├── nestjs-libraries/ # Shared NestJS utilities
│   ├── react-shared-libraries/ # Shared React components
│   └── database/         # Prisma schema
├── .env                  # Environment variables
└── package.json          # Root package.json
```

## Next Steps

1. ✅ All services running locally
2. ✅ Extension loaded in Chrome
3. ✅ Database synchronized
4. Ready for development!

Start building! 🚀
