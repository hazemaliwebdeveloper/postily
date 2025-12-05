# 🚀 Pozmixal - Complete Local Development Setup Guide

## **Quick Start (5 Minutes)**

### **Option 1: Automated Setup (Recommended)**

#### **Windows (Command Prompt or PowerShell)**
```batch
LOCAL_SETUP_START.bat
```

#### **Windows (PowerShell - Requires Admin)**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\LOCAL_SETUP_START.ps1
```

#### **macOS/Linux**
```bash
bash setup-local.sh
```

### **Option 2: Manual Setup (Step-by-Step)**

Follow the **Manual Setup** section below.

---

## **Prerequisites (Before You Start)**

### **Required Software**

| Software | Version | Download | Check |
|----------|---------|----------|-------|
| **Node.js** | 22+ | https://nodejs.org | `node --version` |
| **npm** | 10+ | Included with Node.js | `npm --version` |
| **Docker Desktop** | Latest | https://docker.com | `docker --version` |
| **pnpm** | 10+ | `npm install -g pnpm` | `pnpm --version` |

### **System Requirements**

- **CPU:** 2+ cores
- **RAM:** 4GB minimum (8GB recommended)
- **Disk Space:** 5GB minimum
- **Internet:** Required for initial setup

### **Verify Installation**

```bash
node --version          # Should show v22.x.x or higher
npm --version           # Should show 10.x.x or higher
docker --version        # Should show Docker version
pnpm --version          # Should show 10.x.x or higher
```

---

## **Manual Setup (Step-by-Step)**

### **Step 1: Check Prerequisites**

```bash
node --version
npm --version
docker --version
pnpm --version
```

If any command fails, install the missing software from the links above.

### **Step 2: Ensure Docker is Running**

```bash
docker ps
```

If you get an error, start **Docker Desktop** and wait 30 seconds for it to initialize.

### **Step 3: Set Up Environment File**

The `.env` file already exists, but verify it's configured correctly:

```bash
# On Windows (Command Prompt)
type .env

# On Windows (PowerShell)
Get-Content .env

# On macOS/Linux
cat .env
```

**Critical settings to verify:**
```
DATABASE_URL="postgresql://pozmixal-local:pozmixal-local-pwd@localhost:5432/pozmixal-db-local"
REDIS_URL="redis://localhost:6379"
FRONTEND_URL="http://localhost:4200"
NEXT_PUBLIC_BACKEND_URL="http://localhost:3000"
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production-min-32-chars"
NODE_ENV="development"
```

### **Step 4: Start Docker Services**

```bash
# Start PostgreSQL and Redis
docker compose -f docker-compose.dev.yaml up -d
```

**Verify services are running:**
```bash
docker ps
```

Should show 4-6 containers:
- `pozmixal-postgres` ✅
- `pozmixal-redis` ✅
- `pozmixal-pg-admin` ✅
- `pozmixal-redisinsight` ✅

### **Step 5: Install Dependencies**

```bash
pnpm install --frozen-lockfile
```

This installs all Node.js dependencies (~3-5 minutes).

### **Step 6: Generate Prisma Client**

```bash
pnpm run prisma-generate
```

This generates the TypeScript Prisma client.

### **Step 7: Run Database Migrations**

```bash
pnpm run prisma-db-push
```

This creates the database schema. You'll be prompted to confirm - type `y` and press Enter.

### **Step 8: Start Development Services**

```bash
pnpm run dev
```

This starts all services:
- **Frontend** (Next.js) → http://localhost:4200
- **Backend** (NestJS) → http://localhost:3000
- **Cron jobs**
- **Workers**
- **Extension**

Wait for messages like:
```
> Backend running at http://localhost:3000
> Frontend running at http://localhost:4200
```

### **Step 9: Access the Application**

Open your browser and go to **http://localhost:4200**

You should see:
- Pozmixal login page
- Ability to create a new account
- Full application interface

---

## **Service Access**

### **Application URLs**

| Service | URL | Purpose |
|---------|-----|---------|
| **Frontend** | http://localhost:4200 | Pozmixal web app |
| **Backend API** | http://localhost:3000 | API server |
| **pgAdmin** | http://localhost:8081 | Database management |
| **RedisInsight** | http://localhost:5540 | Redis management |

### **Database Credentials**

| Service | Host | Port | Username | Password |
|---------|------|------|----------|----------|
| **PostgreSQL** | localhost | 5432 | `pozmixal-local` | `pozmixal-local-pwd` |
| **Redis** | localhost | 6379 | (none) | (none) |
| **pgAdmin** | localhost | 8081 | `admin@admin.com` | `admin` |

---

## **Stopping Services**

### **Stop All Services**

**In the terminal running `pnpm run dev`:**
```
Press Ctrl+C
```

**Stop Docker containers:**
```bash
docker compose -f docker-compose.dev.yaml down
```

**Stop Docker and clean up everything:**
```bash
docker compose -f docker-compose.dev.yaml down -v
```

---

## **Troubleshooting**

### **Issue: Docker Not Running**

**Error:** `Cannot connect to Docker daemon`

**Solution:**
1. Start Docker Desktop
2. Wait 30 seconds
3. Run `docker ps` to verify
4. Try again

### **Issue: PostgreSQL Won't Connect**

**Error:** `Could not establish connection to PostgreSQL`

**Solution:**
```bash
# Check if container is running
docker ps | grep pozmixal-postgres

# If not running, restart Docker
docker compose -f docker-compose.dev.yaml up -d pozmixal-postgres

# Wait 10 seconds, then try again
docker exec pozmixal-postgres pg_isready -U pozmixal-local
```

### **Issue: Port Already in Use**

**Error:** `Address already in use: 0.0.0.0:3000`

**Solution:**
```bash
# Find what's using the port (macOS/Linux)
lsof -i :3000

# On Windows, use Task Manager or:
netstat -ano | findstr :3000

# Kill the process or use a different port
# Then restart the services
```

### **Issue: Dependencies Failed to Install**

**Error:** `Failed to install dependencies` or `npm ERR!`

**Solution:**
```bash
# Clear cache
pnpm store prune
rm -rf node_modules pnpm-lock.yaml

# Reinstall
pnpm install
```

### **Issue: Prisma Migration Failed**

**Error:** `Migration failed` or `Database error`

**Solution:**
```bash
# Reset database completely (WARNING: deletes all data)
pnpm run prisma-reset

# Then re-run migrations
pnpm run prisma-db-push
```

### **Issue: Frontend Shows Blank Page**

**Error:** White page or console errors

**Solution:**
```bash
# Check if backend is running
curl http://localhost:3000/health

# Clear browser cache (Ctrl+Shift+Delete)
# Hard refresh (Ctrl+Shift+R)

# Check browser console for errors (F12)
```

### **Issue: Cannot Login / Create Account**

**Error:** Login fails or account creation error

**Solution:**
1. Verify database is running: `docker ps | grep postgres`
2. Verify backend is running: Check terminal for `Backend running at...`
3. Check database has schema: `pnpm run prisma-db-push`
4. Check `.env` file configuration
5. Restart all services

---

## **Development Workflow**

### **Making Changes**

Services auto-reload when you change files:

**Frontend Changes:** Edit files in `apps/frontend/` → Auto-reloads in browser
**Backend Changes:** Edit files in `apps/backend/` → Auto-reloads

### **Running Tests**

```bash
# Run all tests
pnpm test

# Run tests for specific app
pnpm --filter ./apps/backend run test

# Run tests in watch mode
pnpm test --watch
```

### **Building for Production**

```bash
# Build all apps
pnpm build

# Build specific app
pnpm --filter ./apps/frontend run build
```

### **Linting and Formatting**

```bash
# Check for linting issues
npm run lint

# Format code
npm run format
```

---

## **Database Management**

### **Access pgAdmin**

1. Go to http://localhost:8081
2. Login with:
   - Email: `admin@admin.com`
   - Password: `admin`
3. Add a server:
   - Host: `pozmixal-postgres`
   - Port: `5432`
   - Username: `pozmixal-local`
   - Password: `pozmixal-local-pwd`

### **Run Database Queries**

```bash
# Connect to database directly
docker exec -it pozmixal-postgres psql -U pozmixal-local -d pozmixal-db-local

# Run a query
SELECT * FROM public.accounts LIMIT 10;
\q  # Exit
```

### **Backup Database**

```bash
docker exec pozmixal-postgres pg_dump -U pozmixal-local pozmixal-db-local > backup.sql
```

### **Restore Database**

```bash
docker exec -i pozmixal-postgres psql -U pozmixal-local pozmixal-db-local < backup.sql
```

---

## **Environment Variables**

### **Important Variables**

| Variable | Purpose | Example |
|----------|---------|---------|
| `DATABASE_URL` | PostgreSQL connection | `postgresql://user:pass@localhost:5432/db` |
| `REDIS_URL` | Redis connection | `redis://localhost:6379` |
| `JWT_SECRET` | Token signing key | (long random string) |
| `FRONTEND_URL` | Frontend URL for CORS | `http://localhost:4200` |
| `NEXT_PUBLIC_BACKEND_URL` | Backend URL for API calls | `http://localhost:3000` |
| `NODE_ENV` | Environment mode | `development` |

### **Adding API Keys**

Edit `.env` and add API keys for services you want to integrate:

```env
# Twitter/X
X_API_KEY="your-api-key"
X_API_SECRET="your-api-secret"

# LinkedIn
LINKEDIN_CLIENT_ID="your-client-id"
LINKEDIN_CLIENT_SECRET="your-client-secret"

# OpenAI (for AI features)
OPENAI_API_KEY="your-openai-key"
```

---

## **Next Steps After Setup**

1. ✅ **Create first account** at http://localhost:4200
2. ✅ **Explore the dashboard**
3. ✅ **Connect social media accounts** (optional - requires API keys)
4. ✅ **Create your first post** and schedule it
5. ✅ **Check the backend** at http://localhost:3000/docs (Swagger docs)

---

## **Common Tasks**

### **Restart All Services**

```bash
# Stop everything
docker compose -f docker-compose.dev.yaml down

# Wait 5 seconds

# Start everything
docker compose -f docker-compose.dev.yaml up -d
pnpm run dev
```

### **View Application Logs**

```bash
# Backend logs
docker logs -f pozmixal-postgres

# Frontend logs appear in the terminal where you ran pnpm run dev
```

### **Monitor Redis**

```bash
# Open RedisInsight at http://localhost:5540
# Or use redis-cli
docker exec -it pozmixal-redis redis-cli
```

### **Reset Everything**

```bash
# Stop all services
docker compose -f docker-compose.dev.yaml down -v

# Remove all data
rm -rf node_modules

# Start fresh
pnpm install
pnpm run dev
```

---

## **Performance Tips**

1. **Allocate enough Docker resources:**
   - CPU: 2+ cores
   - Memory: 4GB+ dedicated to Docker
   - Disk: SSD for better performance

2. **Keep dependencies updated:**
   ```bash
   pnpm update
   ```

3. **Monitor resource usage:**
   - Use Docker Desktop dashboard
   - Check system resource usage

4. **Use pgAdmin for database queries** instead of direct connections

---

## **Getting Help**

### **Check Logs**

```bash
# Backend logs
docker logs pozmixal-postgres

# Full stack trace in terminal running pnpm run dev
```

### **Verify Everything is Running**

```bash
# Check Docker containers
docker ps

# Check if ports are open
netstat -ano | findstr 3000  # Windows
lsof -i :3000               # macOS/Linux

# Test backend
curl http://localhost:3000/health

# Test frontend
curl http://localhost:4200
```

### **Known Issues**

- **Extension connection error**: See `EXTENSION_CONNECTION_ERROR_FIX.md`
- **CORS errors**: Verify `FRONTEND_URL` and `NEXT_PUBLIC_BACKEND_URL` match your setup
- **Database connection errors**: Ensure Docker containers are running

---

## **Quick Reference Commands**

```bash
# Setup
pnpm install
pnpm run prisma-generate
pnpm run prisma-db-push

# Development
pnpm run dev              # Start all services
pnpm run dev:backend      # Start only backend
pnpm run dev:frontend     # Start only frontend

# Database
pnpm run prisma-reset     # Reset database (WARNING: deletes data!)
pnpm run prisma-generate  # Regenerate Prisma client

# Docker
docker compose -f docker-compose.dev.yaml up -d      # Start containers
docker compose -f docker-compose.dev.yaml down       # Stop containers
docker compose -f docker-compose.dev.yaml down -v    # Stop & remove volumes

# Testing
pnpm test                 # Run tests
pnpm test --watch         # Run tests in watch mode

# Building
pnpm build               # Build all apps
pnpm run build:frontend  # Build only frontend
pnpm run build:backend   # Build only backend
```

---

## **Support**

If you encounter issues:

1. Check the **Troubleshooting** section above
2. Review logs in the terminal
3. Check Docker Desktop for error messages
4. See `EXTENSION_CONNECTION_ERROR_FIX.md` for extension issues
5. Check `TROUBLESHOOTING.md` for additional help

---

**Last Updated:** 2025-01-12  
**Status:** ✅ Production Ready
