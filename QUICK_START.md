# Quick Start Guide - Local Development

## ✅ All Issues Fixed

The application is now ready to run locally. All problems have been resolved:

- ✅ Prisma 7 schema compatibility fixed
- ✅ Windows shell command incompatibilities resolved
- ✅ Docker configuration prepared
- ✅ Environment variables configured

---

## 🚀 Start Application (3 Options)

### Option 1: Quick Start (Recommended for Windows)
Double-click this file in the project root:
```
setup-local.bat
```
This will automatically:
- Start Docker Desktop if needed
- Launch PostgreSQL & Redis containers
- Install dependencies
- Start all development servers

---

### Option 2: PowerShell (Advanced)
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup-local.ps1"
```

---

### Option 3: Manual Steps

#### 1. Start Docker Desktop
Press `Start` menu, search for "Docker Desktop" and launch it.

#### 2. Open Terminal in Project Root
```bash
cd c:\Users\it\Downloads\pozmixal\postily
```

#### 3. Start Containers
```bash
docker compose -f docker-compose.dev.yaml up -d
```

#### 4. Install Dependencies (First Time Only)
```bash
pnpm install
```

#### 5. Generate Prisma Client
```bash
pnpm run prisma-generate
```

#### 6. Start Development Servers
```bash
pnpm run dev
```

---

## 📱 Access the Application

Once servers are running:

- **Frontend**: http://localhost:4200
- **Backend API**: http://localhost:3000
- **Admin**: Create account and login

---

## 🛠️ Available Commands

```bash
pnpm run dev              # Start all services
pnpm run dev:frontend     # Frontend only
pnpm run dev:backend      # Backend only
pnpm run build            # Build for production
pnpm test                 # Run tests
pnpm run lint             # Check code quality

# Database commands
pnpm run prisma-generate  # Regenerate Prisma client
pnpm run prisma-db-push   # Sync schema with database
pnpm run prisma-reset     # ⚠️ Reset database (deletes all data)

# Docker commands
docker compose -f docker-compose.dev.yaml up -d    # Start containers
docker compose -f docker-compose.dev.yaml down      # Stop containers
docker compose logs                                  # View logs
```

---

## ✔️ Verify Services Are Running

In a new terminal, check container status:
```bash
docker ps
```

You should see:
- `pozmixal-postgres` (PostgreSQL on :5432)
- `pozmixal-redis` (Redis on :6379)

---

## 📋 Environment Setup

Configuration is already set in `.env` file:
- Database: `localhost:5432`
- Redis: `localhost:6379`
- Frontend URL: `http://localhost:4200`
- Backend URL: `http://localhost:3000`

**To customize**: Edit `.env` file and restart services.

---

## 🔧 Troubleshooting

### Docker won't start
```bash
# Open Docker Desktop manually
# Windows: Start Menu > Search "Docker Desktop" > Open
```

### Port 3000 or 4200 already in use
```bash
# Find process using port (PowerShell)
Get-NetTCPConnection -LocalPort 3000 | Select-Object OwnerModule

# Kill process
Stop-Process -Id <PID> -Force

# Or change ports in .env file
```

### Database connection errors
```bash
# Wait 10 seconds for containers to be ready
# Then try again

# If still failing, reset database:
pnpm run prisma-reset
```

### npm/pnpm install fails
```bash
# Clear cache and retry
pnpm store prune
pnpm install --no-frozen-lockfile
```

### Prisma generation errors
```bash
# Try reinstalling Prisma
pnpm add -D prisma@5.18.0
pnpm run prisma-generate
```

---

## 📚 Documentation

- Full setup guide: `LOCAL_SETUP.md`
- Project README: `README.md`
- Main docs: https://docs.postiz.com/

---

## 🎯 Next Steps

1. Open http://localhost:4200 in browser
2. Create a user account
3. Connect social media channels (optional)
4. Start building!

---

**Questions?** Check `LOCAL_SETUP.md` for detailed troubleshooting.
