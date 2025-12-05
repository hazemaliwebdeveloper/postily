# 🚀 LOCAL SETUP GUIDE - POZMIXAL

## Quick Start (< 5 minutes)

### Windows (PowerShell)
```powershell
# Open PowerShell and run:
cd C:\Users\it\Downloads\pozmixal\postily
.\setup-local.ps1
```

### macOS / Linux (Bash)
```bash
cd /path/to/pozmixal
chmod +x setup-local.sh
./setup-local.sh
```

---

## Prerequisites

Before running the setup script, ensure you have:

✅ **Node.js 22+**
```bash
node --version  # Should show v22.x.x or higher
```
Install from: https://nodejs.org/

✅ **pnpm 10.6.1+**
```bash
pnpm --version
```
Install with:
```bash
npm install -g pnpm@10.6.1
```

✅ **Docker Desktop**
- Download from: https://www.docker.com/products/docker-desktop
- Make sure Docker is running before executing setup script

---

## Automatic Setup (Recommended)

### Windows
1. Open PowerShell **as Administrator**
2. Navigate to project directory:
   ```powershell
   cd C:\Users\it\Downloads\pozmixal\postily
   ```
3. Run setup script:
   ```powershell
   .\setup-local.ps1
   ```
4. Wait for all services to start (~5-10 minutes on first run)

### macOS / Linux
1. Open Terminal
2. Navigate to project directory:
   ```bash
   cd /path/to/pozmixal
   ```
3. Make script executable:
   ```bash
   chmod +x setup-local.sh
   ```
4. Run setup script:
   ```bash
   ./setup-local.sh
   ```
5. Wait for all services to start (~5-10 minutes on first run)

---

## Manual Setup (If Automated Script Fails)

### Step 1: Start Docker Services
```powershell
# Windows (PowerShell)
docker compose -f docker-compose.dev.yaml up -d

# macOS / Linux (Bash)
docker compose -f docker-compose.dev.yaml up -d
```

This will start:
- **PostgreSQL** on `localhost:5432`
- **Redis** on `localhost:6379`
- **pgAdmin** on `http://localhost:8081` (optional)
- **RedisInsight** on `http://localhost:8001` (optional)

### Step 2: Create Environment File

Create `.env` file in project root:

```bash
# Windows (PowerShell)
$env_content = @"
DATABASE_URL="postgresql://pozmixal-user:pozmixal-password@localhost:5432/pozmixal-db-local"
DATABASE_DIRECT_URL="postgresql://pozmixal-user:pozmixal-password@localhost:5432/pozmixal-db-local"
REDIS_URL="redis://localhost:6379"
JWT_SECRET="dev-jwt-secret-$(Get-Date -Format 'yyyyMMddHHmmss')"
FRONTEND_URL="http://localhost:4200"
NEXT_PUBLIC_BACKEND_URL="http://localhost:3000"
BACKEND_URL="http://localhost:3000"
BACKEND_INTERNAL_URL="http://localhost:3000"
ALLOW_ALL_FEATURES="true"
NODE_ENV="development"
STORAGE_PROVIDER="local"
"@
Set-Content -Path ".env" -Value $env_content

# macOS / Linux (Bash)
cat > .env << 'EOF'
DATABASE_URL="postgresql://pozmixal-user:pozmixal-password@localhost:5432/pozmixal-db-local"
DATABASE_DIRECT_URL="postgresql://pozmixal-user:pozmixal-password@localhost:5432/pozmixal-db-local"
REDIS_URL="redis://localhost:6379"
JWT_SECRET="dev-jwt-secret-$(date +%s)"
FRONTEND_URL="http://localhost:4200"
NEXT_PUBLIC_BACKEND_URL="http://localhost:3000"
BACKEND_URL="http://localhost:3000"
BACKEND_INTERNAL_URL="http://localhost:3000"
ALLOW_ALL_FEATURES="true"
NODE_ENV="development"
STORAGE_PROVIDER="local"
EOF
```

### Step 3: Install Dependencies
```bash
pnpm install
```

### Step 4: Generate Prisma Client
```bash
pnpm run prisma-generate
```

### Step 5: Initialize Database
```bash
pnpm run prisma-db-push
```

### Step 6: Start Development Servers
```bash
pnpm run dev
```

---

## What Gets Started

When setup completes, you'll have:

| Service | URL | Purpose |
|---------|-----|---------|
| **Frontend** | http://localhost:4200 | Next.js application |
| **Backend API** | http://localhost:3000 | NestJS REST API |
| **PostgreSQL** | localhost:5432 | Main database |
| **Redis** | localhost:6379 | Cache & queues |
| **pgAdmin** | http://localhost:8081 | Database management UI |
| **RedisInsight** | http://localhost:8001 | Redis management UI |

---

## Default Credentials

### Database (PostgreSQL)
- **Host**: localhost
- **Port**: 5432
- **User**: pozmixal-user
- **Password**: pozmixal-password
- **Database**: pozmixal-db-local

### pgAdmin (Database UI)
- **URL**: http://localhost:8081
- **Email**: admin@admin.com
- **Password**: admin

### Redis
- **Host**: localhost
- **Port**: 6379
- **No password** (development only)

---

## Accessing the Application

### Frontend
1. Open browser to: **http://localhost:4200**
2. You'll see the Pozmixal login page
3. Click "Sign up" or "Demo" to get started

### Backend API
- Base URL: **http://localhost:3000**
- API Docs: **http://localhost:3000/api** (if available)

### Database Management
- pgAdmin: **http://localhost:8081**
- RedisInsight: **http://localhost:8001**

---

## Development Workflow

### Running Individual Services

If you want to run services separately:

```bash
# Terminal 1: Frontend
pnpm run dev:frontend

# Terminal 2: Backend
pnpm run dev:backend

# Terminal 3: Workers (background jobs)
pnpm run dev:workers

# Terminal 4: Cron (scheduled tasks)
pnpm run dev:cron
```

### Restarting Services

```bash
# Stop all services
Ctrl+C

# Restart all services
pnpm run dev

# Or just rebuild frontend
pnpm run build:frontend
pnpm run dev:frontend
```

### Database Management

```bash
# View Prisma schema
cat libraries/nestjs-libraries/src/database/prisma/schema.prisma

# Generate Prisma client
pnpm run prisma-generate

# Push schema to database
pnpm run prisma-db-push

# Reset database (CAREFUL - deletes all data)
pnpm run prisma-reset
```

---

## Troubleshooting

### "Could not establish connection" Error

**Problem**: Backend can't connect to PostgreSQL

**Solution**:
```powershell
# Check if PostgreSQL is running
docker ps | grep pozmixal-postgres

# If not running, start it
docker compose -f docker-compose.dev.yaml up -d pozmixal-postgres

# Wait 30 seconds and try again
```

### "Receiving end does not exist" Error

This is the browser extension error that was fixed. Make sure you're using the latest code:

```bash
git pull origin main
pnpm run build:extension
```

### Redis Connection Failed

**Problem**: Backend can't connect to Redis

**Solution**:
```bash
# Check if Redis is running
docker ps | grep pozmixal-redis

# If not running, start it
docker compose -f docker-compose.dev.yaml up -d pozmixal-redis

# Test Redis connection
redis-cli ping  # Should return: PONG
```

### Port Already in Use

**Problem**: "Address already in use" for port 3000, 4200, etc.

**Solution**:
```powershell
# Windows - Kill process on port 3000
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# macOS/Linux - Kill process on port 3000
lsof -ti:3000 | xargs kill -9
```

### Module Not Found / Import Errors

**Problem**: TypeScript can't find modules

**Solution**:
```bash
# Regenerate Prisma
pnpm run prisma-generate

# Reinstall dependencies
rm -rf node_modules pnpm-lock.yaml
pnpm install

# Clear build cache
pnpm run clean 2>/dev/null || true
pnpm run build
```

### Database Migration Issues

**Problem**: Prisma migration fails

**Solution**:
```bash
# Force push schema (WARNING: deletes data in dev DB)
pnpm run prisma-reset

# Or manually migrate
pnpm run prisma-db-push --force
```

### Docker Service Won't Start

**Problem**: Docker compose fails

**Solution**:
```bash
# Stop all containers
docker compose -f docker-compose.dev.yaml down

# Remove volumes (WARNING: deletes database)
docker compose -f docker-compose.dev.yaml down -v

# Start fresh
docker compose -f docker-compose.dev.yaml up -d
```

---

## Monitoring & Debugging

### View Logs

```bash
# All services
pnpm run dev  # Logs displayed in terminal

# Individual services
docker compose -f docker-compose.dev.yaml logs -f pozmixal-postgres
docker compose -f docker-compose.dev.yaml logs -f pozmixal-redis

# Backend only (if running separately)
pnpm run dev:backend
```

### Monitor Services

```bash
# Docker services
docker compose -f docker-compose.dev.yaml ps

# Database UI: http://localhost:8081
# Redis UI: http://localhost:8001
```

### Test Connection to Services

```bash
# Test PostgreSQL
docker exec pozmixal-postgres psql -U pozmixal-user -d pozmixal-db-local -c "SELECT 1"

# Test Redis
redis-cli ping

# Test Backend API
curl http://localhost:3000/health

# Test Frontend
curl http://localhost:4200
```

---

## Performance Tips

### Initial Setup Takes Long?
- First `pnpm install` can take 5-10 minutes
- First build can take 3-5 minutes
- Subsequent runs are much faster (cached)

### Development is Slow?

Try these optimizations:

1. **Increase Docker resources**:
   - Docker Settings → Resources
   - Increase CPU: 4+ cores
   - Increase Memory: 8GB+
   - Increase Disk: 50GB+

2. **Use SSD for better I/O**:
   - Project should be on SSD, not USB

3. **Run services separately** (if all together is slow):
   ```bash
   pnpm run dev:frontend  # Terminal 1
   pnpm run dev:backend   # Terminal 2
   ```

4. **Disable unused services**:
   - Comment out pgAdmin/RedisInsight in docker-compose.dev.yaml
   - These are optional monitoring tools

---

## Next Steps

### After Application Starts

1. **Access Frontend**: http://localhost:4200
2. **Create Account**: Sign up or use demo account
3. **Connect Social Media**: Add Instagram/LinkedIn credentials
4. **Schedule Content**: Try scheduling a post
5. **View Logs**: Check backend console for activity

### Explore the Codebase

```bash
# Frontend code
code apps/frontend

# Backend code
code apps/backend

# Shared libraries
code libraries

# Database schema
code libraries/nestjs-libraries/src/database/prisma/schema.prisma
```

### Run Tests

```bash
# Run all tests
pnpm test

# Run tests for specific app
pnpm --filter ./apps/backend test

# Watch mode (auto-rerun on changes)
pnpm test -- --watch
```

---

## Production Deployment

For production deployment information, see:
- Documentation: https://docs.pozmixal.com/deployment
- Docker deployment: https://docs.pozmixal.com/installation/docker-compose
- Kubernetes: https://docs.pozmixal.com/installation/kubernetes

---

## Need Help?

### Check Documentation
- **Main Docs**: https://docs.pozmixal.com
- **GitHub Issues**: Check existing issues
- **TROUBLESHOOTING.md**: Common issues and fixes

### Common Documents in This Repo
- `LOCAL_SETUP.md` - Setup guide
- `QUICKSTART.md` - Quick reference
- `TROUBLESHOOTING.md` - Problem solving
- `README.md` - Project overview

---

## Summary

You're now ready to develop on Pozmixal locally! 

**Quick Start Reminder:**
```bash
# Windows (PowerShell)
.\setup-local.ps1

# macOS / Linux
./setup-local.sh
```

**Everything should be running on:**
- 🌐 Frontend: http://localhost:4200
- 🔧 Backend: http://localhost:3000
- 🗄️ Database: localhost:5432
- 💾 Cache: localhost:6379

Happy coding! 🚀
