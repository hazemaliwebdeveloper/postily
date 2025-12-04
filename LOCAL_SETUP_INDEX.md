# Pozmixal Local Setup - Complete Index & Guide

## 🎯 Welcome to Pozmixal!

This index helps you quickly find what you need to run Pozmixal locally.

---

## 🚀 Want to Get Running FAST? (15 minutes)

**Start here:** [`QUICKSTART.md`](./QUICKSTART.md)

- ✅ Fastest setup possible
- ✅ Step-by-step instructions
- ✅ Common issues & quick fixes
- ✅ Verify everything works

**TL;DR:**
```bash
docker-compose -f docker-compose.dev.yaml up -d pozmixal-postgres pozmixal-redis
cp .env.local .env
pnpm install
pnpm run prisma-db-push
pnpm run dev
# Then open http://localhost:4200 in browser
```

---

## 📚 Full Documentation

### 1. **Detailed Setup Guide** → [`SETUP.md`](./SETUP.md)
   - System requirements
   - Step-by-step installation
   - Database setup (Docker or local)
   - Environment configuration explained
   - Service startup instructions
   - User account creation
   - Development workflows

   **When to use:**
   - First time setup
   - Need detailed explanations
   - Installing from scratch
   - Don't have Docker

---

### 2. **Environment Configuration** → [`.env.local`](./.env.local)
   - Complete template with all variables
   - Detailed comments for each setting
   - Critical vs optional variables
   - Examples for different scenarios
   - Security notes

   **When to use:**
   - Setting up .env file
   - Need variable reference
   - Configuring integrations
   - Understanding what each setting does

---

### 3. **Troubleshooting Guide** → [`TROUBLESHOOTING.md`](./TROUBLESHOOTING.md)
   - Critical errors explained
   - Quick fix checklists
   - Common causes & solutions
   - Debug commands
   - Error messages reference

   **When to use:**
   - Something isn't working
   - Getting error messages
   - Connection issues
   - Authentication problems

---

### 4. **Complete Testing Checklist** → [`TESTING_CHECKLIST.md`](./TESTING_CHECKLIST.md)
   - 31 comprehensive tests
   - Pre-flight checklist
   - Application startup verification
   - Frontend accessibility tests
   - Authentication flow tests
   - API endpoint tests
   - Database verification
   - Performance checks
   - Security verification

   **When to use:**
   - After setup, before development
   - Verify everything works
   - Test a feature end-to-end
   - Debug specific functionality

---

## 🛠️ Utility Scripts

### Health Check Script
```bash
# Verify all systems are ready
node scripts/health-check.js
```

- Checks environment variables
- Tests backend connectivity
- Verifies database connection
- Tests Redis connection
- Validates CORS configuration

### Database Commands
```bash
# Generate Prisma client
pnpm run prisma-generate

# Push database schema
pnpm run prisma-db-push

# Reset database (deletes all data!)
pnpm run prisma-reset
```

---

## 📋 Quick Reference

### Services & Ports

| Service | URL | Port | Status |
|---------|-----|------|--------|
| Frontend | http://localhost:4200 | 4200 | Development |
| Backend | http://localhost:3000 | 3000 | Development |
| PostgreSQL | - | 5432 | Local/Docker |
| Redis | - | 6379 | Local/Docker (optional) |
| pgAdmin | http://localhost:8081 | 8081 | Docker (admin/admin) |
| RedisInsight | http://localhost:5540 | 5540 | Docker |

### Key Environment Variables

```bash
# Critical - must be set correctly
FRONTEND_URL=http://localhost:4200          # Must match browser URL!
NEXT_PUBLIC_BACKEND_URL=http://localhost:3000
DATABASE_URL=postgresql://...               # Must have running database
JWT_SECRET=your-secret-key                  # Min 32 chars, keep secret

# Optional but recommended
REDIS_URL=redis://localhost:6379            # Or skip for MockRedis
STORAGE_PROVIDER=local                      # For file uploads

# Optional - for integrations
RESEND_API_KEY=...                          # Email (skip for dev)
OPENAI_API_KEY=...                          # AI features (skip for dev)
```

---

## 🚀 Startup Procedures

### Quick Start (All Services)
```bash
pnpm run dev
```
Runs: Backend, Frontend, Workers, Cron

### Individual Services
```bash
# Terminal 1 - Backend
pnpm run dev:backend

# Terminal 2 - Frontend  
pnpm run dev:frontend

# Terminal 3 - Workers (Optional)
pnpm run workers

# Terminal 4 - Cron (Optional)
pnpm run cron
```

### With Docker Services
```bash
# Start database & cache
docker-compose -f docker-compose.dev.yaml up -d

# Stop services
docker-compose -f docker-compose.dev.yaml down

# View logs
docker-compose -f docker-compose.dev.yaml logs -f
```

---

## 🔐 First Login

### Create Account
1. Go to: http://localhost:4200
2. Click "Sign Up"
3. Enter email and password
4. Click "Sign Up"

### Login
1. Go to: http://localhost:4200
2. Click "Sign In"  
3. Enter email and password
4. Click "Sign In"

### Account Details (Example)
- Email: `admin@pozmixal.local`
- Password: `YourSecurePassword123!`

---

## 🐛 Common Issues Quick Fixes

| Issue | Fix | Reference |
|-------|-----|-----------|
| "Could not establish connection" | Start backend or check DATABASE_URL | TROUBLESHOOTING.md |
| "Failed to fetch" | Verify NEXT_PUBLIC_BACKEND_URL and backend is running | TROUBLESHOOTING.md |
| "CORS policy error" | Ensure FRONTEND_URL matches browser URL exactly | TROUBLESHOOTING.md |
| "User is not activated" | Comment out RESEND_API_KEY in .env | TROUBLESHOOTING.md |
| "Invalid credentials" | Verify user exists and password is correct | TROUBLESHOOTING.md |
| Backend won't start | Check DATABASE_URL, verify PostgreSQL running | TROUBLESHOOTING.md |
| Frontend won't start | Clear .next: `rm -rf apps/frontend/.next` | TROUBLESHOOTING.md |
| "Redis connection failed" | Start Redis or skip it (uses MockRedis) | TROUBLESHOOTING.md |

---

## 📊 Directory Structure

```
pozmixal/
├── apps/
│   ├── backend/              # NestJS API (port 3000)
│   ├── frontend/             # Next.js UI (port 4200)
│   ├── workers/              # Background jobs
│   ├── cron/                 # Scheduled tasks
│   └── extension/            # Browser extension
├── libraries/
│   ├── nestjs-libraries/     # Shared backend code
│   ├── react-shared-libraries/ # Shared frontend code
│   └── helpers/              # Utilities
├── scripts/
│   ├── health-check.js       # Verify setup
│   └── health-check.sh       # Bash version
├── .env.local                # Environment template (copy to .env)
├── .env.example              # Another template
├── docker-compose.dev.yaml   # Docker services
│
├── QUICKSTART.md             # 15-min setup (START HERE!)
├── SETUP.md                  # Detailed setup guide
├── TROUBLESHOOTING.md        # Error solutions
├── TESTING_CHECKLIST.md      # 31 tests to verify
├── LOCAL_SETUP_INDEX.md      # This file
│
├── package.json              # Monorepo config
├── pnpm-workspace.yaml       # Workspace definition
└── ...
```

---

## 🎯 Setup Flowchart

```
START
  ↓
1. Have Docker? 
  ├─ YES → Run docker-compose up
  └─ NO → Install PostgreSQL & Redis locally
  ↓
2. Copy .env.local → .env
  ↓
3. Edit .env:
  ├─ Set FRONTEND_URL to your browser URL
  ├─ Verify NEXT_PUBLIC_BACKEND_URL
  └─ Keep DATABASE_URL as is (or update if needed)
  ↓
4. Run: pnpm install
  ↓
5. Run: pnpm run prisma-db-push
  ↓
6. Run: pnpm run dev
  ↓
7. Wait for:
  ├─ Backend: "🚀 Backend is running on: http://localhost:3000"
  └─ Frontend: "ready started server on 0.0.0.0:4200"
  ↓
8. Open browser: http://localhost:4200
  ↓
9. Create account → Login
  ↓
SUCCESS! 🎉
```

---

## 📝 Checklist: Before Starting Development

- [ ] All services running (backend, frontend, database)
- [ ] Can access frontend: http://localhost:4200
- [ ] Can access backend: http://localhost:3000
- [ ] User account created and logged in
- [ ] No CORS errors in browser console
- [ ] No connection errors
- [ ] Health check passes: `node scripts/health-check.js`
- [ ] Can navigate between pages
- [ ] Session persists after refresh
- [ ] Can logout and login again

---

## 🔄 Daily Development Workflow

### Morning: Startup
```bash
# Start services (or use previous terminal)
pnpm run dev

# Verify health
node scripts/health-check.js

# Work on features!
```

### During Development
- Edit files in `apps/backend/` or `apps/frontend/`
- Changes auto-reload (hot reload)
- Check browser console (F12) for errors
- Check backend logs for issues

### If Database Schema Changes
```bash
# After editing schema.prisma
pnpm run prisma-generate
pnpm run prisma-db-push
```

### Before Committing
```bash
# Run tests (if available)
pnpm test

# Build to catch errors
pnpm run build

# Verify no console errors
```

---

## 🆘 Getting Help

### 1. Check Documentation
   - Specific issue? → `TROUBLESHOOTING.md`
   - Setup question? → `SETUP.md`
   - Need to test? → `TESTING_CHECKLIST.md`

### 2. Run Health Check
   ```bash
   node scripts/health-check.js
   ```

### 3. Check Logs
   - Browser console: F12 → Console tab
   - Backend logs: Look for red error messages
   - Database: `psql -U pozmixal-local -d pozmixal-db-local`

### 4. Debug Commands
   ```bash
   # Test backend
   curl http://localhost:3000/health

   # Test database
   psql -U pozmixal-local -d pozmixal-db-local -c "SELECT 1;"

   # Test Redis
   redis-cli ping
   ```

---

## 📚 Learning Resources

### Project Structure
- Backend: NestJS framework (TypeScript)
- Frontend: Next.js with React (TypeScript)
- Database: PostgreSQL with Prisma ORM
- Cache: Redis with BullMQ
- Monorepo: pnpm workspaces with NX

### External Docs
- NestJS: https://docs.nestjs.com
- Next.js: https://nextjs.org/docs
- Prisma: https://www.prisma.io/docs
- React: https://react.dev
- TypeScript: https://www.typescriptlang.org

---

## 🎓 Useful Git Commands

```bash
# See what changed
git status

# View recent commits
git log --oneline -10

# Make a branch for your feature
git checkout -b feature/my-feature

# Commit changes
git add .
git commit -m "feat: add my feature"

# Push to remote
git push origin feature/my-feature
```

---

## 🚀 Production Deployment

When ready to deploy, see:
- Backend: `apps/backend/README.md`
- Frontend: `apps/frontend/README.md`
- Docker: `docker-compose.prod.yaml` (if available)

---

## ✨ Summary

| Need | File |
|------|------|
| Fast setup (15 min) | [`QUICKSTART.md`](./QUICKSTART.md) |
| Detailed instructions | [`SETUP.md`](./SETUP.md) |
| Configuration help | [`.env.local`](./.env.local) |
| Troubleshooting | [`TROUBLESHOOTING.md`](./TROUBLESHOOTING.md) |
| Verification tests | [`TESTING_CHECKLIST.md`](./TESTING_CHECKLIST.md) |
| Health check | `node scripts/health-check.js` |
| API docs | http://localhost:3000/api |

---

## 🎉 You're All Set!

Everything you need to run Pozmixal locally is in this directory. 

**Pick your path:**

1. **In a Hurry?** → [`QUICKSTART.md`](./QUICKSTART.md) (15 minutes)
2. **First Time?** → [`SETUP.md`](./SETUP.md) (detailed)
3. **Something Broken?** → [`TROUBLESHOOTING.md`](./TROUBLESHOOTING.md) (fixes)
4. **Ready to Test?** → [`TESTING_CHECKLIST.md`](./TESTING_CHECKLIST.md) (31 tests)

---

**Happy coding! 🚀**

Have questions? See the relevant documentation file listed above.
