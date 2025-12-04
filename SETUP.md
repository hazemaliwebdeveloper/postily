# Pozmixal - Complete Local Setup Guide

## 🎯 Overview

This guide will help you set up and run the complete Pozmixal application locally, including:
- Backend (NestJS + PostgreSQL)
- Frontend (Next.js)
- Database (PostgreSQL)
- Cache/Queue (Redis)
- Email (Resend - optional)

**Total setup time: 15-30 minutes**

---

## ✅ System Requirements

### Minimum Requirements
- **Node.js**: v22.x (or v20.17.0)
- **pnpm**: v10.6.1 or higher
- **PostgreSQL**: v15+ (or use Docker)
- **Redis**: v7.x (or use Docker / MockRedis)
- **Disk Space**: 5GB minimum
- **RAM**: 4GB minimum (8GB recommended)

### Recommended: Docker Setup
If you have Docker installed, it's easier to run PostgreSQL and Redis in containers.

---

## 📋 Step 1: Verify Prerequisites

### Check Node.js Version
```bash
node --version
# Expected: v22.x.x or v20.17.0

npm --version
# Expected: 10.x or higher
```

### Install/Update pnpm
```bash
npm install -g pnpm@10.6.1
pnpm --version
# Expected: 10.6.1
```

### Check Docker (Optional)
```bash
docker --version
docker-compose --version
```

---

## 🔧 Step 2: Database Setup

### Option A: Docker (Recommended)

**Start PostgreSQL and Redis**
```bash
cd <pozmixal-root>
docker-compose -f docker-compose.dev.yaml up -d pozmixal-postgres pozmixal-redis
```

**Verify Services**
```bash
docker-compose -f docker-compose.dev.yaml ps
# Should show:
# - pozmixal-postgres   UP
# - pozmixal-redis      UP
```

**Access Database Admin (Optional)**
```
pgAdmin: http://localhost:8081
- Email: admin@admin.com
- Password: admin
- Host: pozmixal-postgres
- Port: 5432
```

**Access Redis Admin (Optional)**
```
RedisInsight: http://localhost:5540
- No authentication
```

---

### Option B: Local Installation

#### PostgreSQL Setup

**Windows**
```bash
# Install PostgreSQL from https://www.postgresql.org/download/windows/
# Default port: 5432
# Create user: pozmixal-local
# Password: pozmixal-local-pwd
# Create database: pozmixal-db-local

# Or use WSL2
sudo apt-get install postgresql postgresql-contrib
sudo service postgresql start
```

**macOS**
```bash
# Using Homebrew
brew install postgresql@17
brew services start postgresql@17

# Or use Docker (recommended)
```

**Linux**
```bash
sudo apt-get install postgresql postgresql-contrib
sudo service postgresql start
```

#### Create Database & User
```bash
# Connect to PostgreSQL
psql -U postgres

# Inside psql shell
CREATE USER "pozmixal-local" WITH PASSWORD 'pozmixal-local-pwd';
CREATE DATABASE "pozmixal-db-local" OWNER "pozmixal-local";
ALTER ROLE "pozmixal-local" CREATEDB;

# Exit psql
\q
```

#### Redis Setup

**Windows**
```bash
# Use WSL2 or Docker (recommended)
# Or download from: https://github.com/microsoftarchive/redis/releases
```

**macOS**
```bash
brew install redis
brew services start redis
```

**Linux**
```bash
sudo apt-get install redis-server
sudo systemctl start redis-server
```

---

## 🚀 Step 3: Application Setup

### Clone/Navigate to Project
```bash
cd c:\Users\it\Downloads\pozmixal\postily
# Or your project directory
```

### Install Dependencies
```bash
pnpm install
# This will:
# - Install all dependencies
# - Generate Prisma client
# - Set up workspace packages
```

### Setup Environment Variables

**Create `.env` file from template**
```bash
# Windows
copy .env.example .env

# macOS/Linux
cp .env.example .env
```

**Edit `.env` with your configuration**

See "Step 4: Environment Configuration" below.

### Initialize Database

**Generate Prisma Client**
```bash
pnpm run prisma-generate
```

**Push Database Schema**
```bash
pnpm run prisma-db-push
```

**Reset Database (if needed)**
```bash
# Warning: This deletes all data
pnpm run prisma-reset
```

---

## 🔐 Step 4: Environment Configuration

### Create `.env` File

Create file: `.env` in the project root with the following content:

```bash
# ============================================
# CRITICAL: Database Configuration
# ============================================

# PostgreSQL connection string
DATABASE_URL="postgresql://pozmixal-local:pozmixal-local-pwd@localhost:5432/pozmixal-db-local"
DATABASE_DIRECT_URL="postgresql://pozmixal-local:pozmixal-local-pwd@localhost:5432/pozmixal-db-local"

# ============================================
# CRITICAL: Redis Configuration
# ============================================

# Redis connection string (can be commented out for MockRedis in dev)
REDIS_URL="redis://localhost:6379"

# ============================================
# CRITICAL: JWT & Security
# ============================================

# Generate a strong random string (min 32 characters)
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production-12345"

# ============================================
# CRITICAL: URL Configuration (must match your access URLs)
# ============================================

# Frontend URL - The URL you use in your browser
FRONTEND_URL="http://localhost:4200"

# Backend URLs - Must be accessible from frontend
NEXT_PUBLIC_BACKEND_URL="http://localhost:3000"
BACKEND_URL="http://localhost:3000"
BACKEND_INTERNAL_URL="http://localhost:3000"

# ============================================
# Optional: Email Configuration (Resend)
# ============================================

# Email provider - leave empty to skip email verification
# RESEND_API_KEY="your-resend-api-key"
# EMAIL_FROM_ADDRESS="noreply@yourdomain.com"
# EMAIL_FROM_NAME="Pozmixal"

# ============================================
# Optional: Storage Configuration
# ============================================

STORAGE_PROVIDER="local"
# UPLOAD_DIRECTORY="/path/to/uploads"
# NEXT_PUBLIC_UPLOAD_STATIC_DIRECTORY="/uploads"

# ============================================
# Optional: Analytics & Monitoring
# ============================================

# NEXT_PUBLIC_SENTRY_DSN="your-sentry-dsn"
# NEXT_PUBLIC_POSTHOG_KEY="your-posthog-key"
# NEXT_PUBLIC_POSTHOG_HOST="https://app.posthog.com"

# ============================================
# Optional: Social Media API Keys
# ============================================

# Leave these empty if not needed initially
X_API_KEY=""
X_API_SECRET=""
LINKEDIN_CLIENT_ID=""
LINKEDIN_CLIENT_SECRET=""
REDDIT_CLIENT_ID=""
REDDIT_CLIENT_SECRET=""
GITHUB_CLIENT_ID=""
GITHUB_CLIENT_SECRET=""
FACEBOOK_APP_ID=""
FACEBOOK_APP_SECRET=""
THREADS_APP_ID=""
THREADS_APP_SECRET=""
YOUTUBE_CLIENT_ID=""
YOUTUBE_CLIENT_SECRET=""
TIKTOK_CLIENT_ID=""
TIKTOK_CLIENT_SECRET=""
PINTEREST_CLIENT_ID=""
PINTEREST_CLIENT_SECRET=""
DISCORD_CLIENT_ID=""
DISCORD_CLIENT_SECRET=""
DISCORD_BOT_TOKEN_ID=""
SLACK_ID=""
SLACK_SECRET=""
SLACK_SIGNING_SECRET=""

# ============================================
# Optional: Payment & Billing
# ============================================

FEE_AMOUNT=0.05
# STRIPE_PUBLISHABLE_KEY="your-stripe-key"
# STRIPE_SECRET_KEY="your-stripe-key"
# STRIPE_SIGNING_KEY="your-stripe-key"

# ============================================
# Optional: Cloudflare Storage (for production)
# ============================================

# CLOUDFLARE_ACCOUNT_ID="your-account-id"
# CLOUDFLARE_ACCESS_KEY="your-access-key"
# CLOUDFLARE_SECRET_ACCESS_KEY="your-secret-key"
# CLOUDFLARE_BUCKETNAME="your-bucket-name"
# CLOUDFLARE_BUCKET_URL="https://your-bucket-url.r2.cloudflarestorage.com/"
# CLOUDFLARE_REGION="auto"

# ============================================
# Optional: Development Settings
# ============================================

NX_ADD_PLUGINS=false
IS_GENERAL="true"
NODE_ENV="development"

# For local development without HTTPS
# NOT_SECURED=true
```

### Key Configuration Notes

#### CRITICAL URLs (Most Important!)

**FRONTEND_URL**
- Must match your browser access URL exactly
- Examples:
  - `http://localhost:4200` ✅ (if you access from localhost)
  - `http://192.168.1.100:4200` ✅ (if you access from local IP)
  - `http://yourdomain.local:4200` ✅ (if you use a local domain)

**NEXT_PUBLIC_BACKEND_URL**
- Must be accessible from the frontend
- Usually: `http://localhost:3000`
- Must NOT have trailing slash

#### CRITICAL Database URLs

**DATABASE_URL**
- Format: `postgresql://username:password@host:port/database`
- Default: `postgresql://pozmixal-local:pozmixal-local-pwd@localhost:5432/pozmixal-db-local`

**REDIS_URL**
- Format: `redis://host:port` or `redis://:password@host:port`
- Default: `redis://localhost:6379`
- Can be omitted in development (will use MockRedis)

#### JWT_SECRET
- Generate a random string (min 32 characters)
- Use: `openssl rand -base64 32` or online generator
- Must be same across backend and frontend

---

## 🏃 Step 5: Run the Application

### Option A: Run All Services Together (Recommended)

**Start Everything**
```bash
pnpm run dev
```

This will start:
- ✅ Backend (port 3000)
- ✅ Frontend (port 4200)
- ✅ Workers (background jobs)
- ✅ Cron (scheduled tasks)
- ✅ Extension (if available)

**Wait for startup (takes 30-60 seconds)**
- Backend: `🚀 Backend is running on: http://localhost:3000`
- Frontend: `- ready started server on 0.0.0.0:4200, url: http://localhost:4200`

---

### Option B: Run Services Separately

**Terminal 1: Backend**
```bash
pnpm run dev:backend
# Expected: "🚀 Backend is running on: http://localhost:3000"
```

**Terminal 2: Frontend**
```bash
pnpm run dev:frontend
# Expected: "- ready started server on 0.0.0.0:4200"
```

**Terminal 3: Workers (Optional)**
```bash
pnpm run workers
```

**Terminal 4: Cron (Optional)**
```bash
pnpm run cron
```

---

## 🌐 Step 6: Access the Application

### Frontend
```
URL: http://localhost:4200
```

### Backend API
```
URL: http://localhost:3000
API Docs: http://localhost:3000/api
Health Check: http://localhost:3000/health
```

### Database Admin (if using Docker)
```
pgAdmin: http://localhost:8081
- Email: admin@admin.com
- Password: admin
```

### Redis Admin (if using Docker)
```
RedisInsight: http://localhost:5540
```

---

## 👤 Step 7: Create First User Account

### Option A: Register via Frontend

1. Open `http://localhost:4200`
2. Click "Sign Up"
3. Enter:
   - Email: `admin@pozmixal.local`
   - Password: `YourSecurePassword123!`
4. Click "Sign Up"
5. If email service is enabled, check email for verification link
6. If email is disabled, you're automatically logged in

### Option B: Create via Backend API

**Register User**
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@pozmixal.local",
    "password": "YourSecurePassword123!",
    "provider": "LOCAL"
  }'
```

**Login**
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@pozmixal.local",
    "password": "YourSecurePassword123!",
    "provider": "LOCAL"
  }'
```

---

## ✔️ Step 8: Health Check

### Run Health Check Script

**Using Node.js**
```bash
node scripts/health-check.js
```

**Using Bash**
```bash
bash scripts/health-check.sh
```

### Manual Health Checks

**Check Backend**
```bash
curl http://localhost:3000/health
# Should return: {"status":"ok"} or similar
```

**Check Frontend**
```bash
curl http://localhost:4200
# Should return HTML
```

**Check Database**
```bash
psql -U pozmixal-local -d pozmixal-db-local -c "SELECT 1"
# Should return: 1
```

**Check Redis**
```bash
redis-cli ping
# Should return: PONG
```

---

## 🧪 Step 9: Test Complete Application Flow

### Test Login Flow

1. **Open Frontend**
   ```
   http://localhost:4200
   ```

2. **Navigate to Sign In**
   - Click "Sign In" link
   - Enter credentials:
     - Email: `admin@pozmixal.local`
     - Password: `YourSecurePassword123!`
   - Click "Sign In"

3. **Verify Success**
   - Should redirect to `/launches`
   - Should see dashboard
   - No CORS errors in browser console
   - No connection errors

### Test API Endpoints

**Get User Info**
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/user
```

**Create Post**
```bash
curl -X POST http://localhost:3000/api/posts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Post",
    "content": "This is a test"
  }'
```

---

## 🛠️ Common Issues & Solutions

### Issue: "Could not establish connection"

**Cause**: Backend not running or unreachable

**Solution**:
```bash
# Check if backend is running
curl http://localhost:3000/health

# If not running, start it
pnpm run dev:backend

# Check .env file
echo $NEXT_PUBLIC_BACKEND_URL
# Should be: http://localhost:3000
```

---

### Issue: "CORS policy error"

**Cause**: FRONTEND_URL doesn't match browser URL

**Solution**:
```bash
# Check your browser URL (e.g., http://localhost:4200)
# Update .env
FRONTEND_URL="http://localhost:4200"  # Must match exactly

# Restart backend
pnpm run dev:backend
```

---

### Issue: "Failed to fetch"

**Cause**: Network connectivity or backend unreachable

**Solution**:
```bash
# 1. Check database is running
docker-compose -f docker-compose.dev.yaml ps

# 2. Check backend logs for database connection errors
pnpm run dev:backend

# 3. Verify DATABASE_URL in .env
echo $DATABASE_URL

# 4. Test connection
psql "$DATABASE_URL"
```

---

### Issue: "User is not activated"

**Cause**: User account not activated via email

**Solution**:
```bash
# Option 1: Disable email requirement
# Remove or comment out RESEND_API_KEY in .env

# Option 2: Manually activate in database
psql -U pozmixal-local -d pozmixal-db-local
UPDATE public."User" SET activated = true WHERE email = 'admin@pozmixal.local';
\q
```

---

### Issue: "Invalid email or password"

**Cause**: Wrong credentials or user doesn't exist

**Solution**:
```bash
# Create new user
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@pozmixal.local",
    "password": "TestPassword123!",
    "provider": "LOCAL"
  }'
```

---

### Issue: "Redis connection failed"

**Cause**: Redis not running (optional in development)

**Solution**:
```bash
# Option 1: Start Redis with Docker
docker-compose -f docker-compose.dev.yaml up -d pozmixal-redis

# Option 2: The app will use MockRedis automatically
# Check logs: "Using MockRedis for testing/development"
```

---

## 📁 Project Structure

```
pozmixal/
├── apps/
│   ├── backend/              # NestJS API server
│   │   └── src/
│   │       ├── main.ts       # Entry point
│   │       ├── app.module.ts # Main module
│   │       └── api/          # API routes
│   ├── frontend/             # Next.js frontend
│   │   └── src/
│   │       ├── app/          # App routes
│   │       ├── components/   # React components
│   │       └── pages/        # Next.js pages
│   ├── workers/              # Background jobs
│   ├── cron/                 # Scheduled tasks
│   └── extension/            # Browser extension
├── libraries/
│   ├── nestjs-libraries/     # Shared NestJS code
│   │   └── database/         # Prisma ORM setup
│   ├── react-shared-libraries/ # Shared React code
│   └── helpers/              # Utility functions
├── .env                      # Environment variables (create this)
├── .env.example              # Example config
├── docker-compose.dev.yaml   # Docker services
├── SETUP.md                  # This file
├── TROUBLESHOOTING.md        # Error solutions
└── package.json              # Workspace config
```

---

## 🔄 Development Workflows

### Hot Reload
Frontend and backend support hot reload:
- Edit files and changes appear instantly
- No need to restart the server

### Database Migrations
```bash
# After changing schema.prisma
pnpm run prisma-generate
pnpm run prisma-db-push

# Or reset entire database
pnpm run prisma-reset
```

### Running Tests
```bash
pnpm test
```

### Building for Production
```bash
pnpm run build
```

---

## 🚀 Production Deployment

**For production setup, see documentation at:**
- Backend: `apps/backend/README.md`
- Frontend: `apps/frontend/README.md`
- Deployment: `docs/deployment.md` (if available)

---

## 📞 Support

### Debugging Commands
```bash
# Check health of all services
node scripts/health-check.js

# View backend logs
pnpm run dev:backend 2>&1 | grep -i error

# View frontend logs
pnpm run dev:frontend 2>&1 | grep -i error

# Check environment variables
cat .env

# View database
psql -U pozmixal-local -d pozmixal-db-local -c "\dt"
```

### Useful Resources
- Troubleshooting: See `TROUBLESHOOTING.md`
- API Documentation: http://localhost:3000/api
- Prisma Docs: https://www.prisma.io/docs
- NestJS Docs: https://docs.nestjs.com
- Next.js Docs: https://nextjs.org/docs

---

## ✅ Final Checklist

Before considering setup complete:

- [ ] Node.js v22 installed
- [ ] pnpm installed
- [ ] PostgreSQL running (local or Docker)
- [ ] Redis running (local or Docker) or MockRedis
- [ ] `.env` file created and configured
- [ ] `pnpm install` completed
- [ ] Database schema pushed: `pnpm run prisma-db-push`
- [ ] Backend starts without errors: `pnpm run dev:backend`
- [ ] Frontend starts without errors: `pnpm run dev:frontend`
- [ ] Can access frontend: http://localhost:4200
- [ ] Can access backend API: http://localhost:3000
- [ ] Can register user via frontend
- [ ] Can login successfully
- [ ] No CORS errors in browser console
- [ ] No connection errors in network tab
- [ ] Health check script passes: `node scripts/health-check.js`
- [ ] Database has user record: `psql ... -c "SELECT * FROM public.User"`

Once all items are checked, your Pozmixal application is ready for development!

---

**Happy coding! 🎉**
