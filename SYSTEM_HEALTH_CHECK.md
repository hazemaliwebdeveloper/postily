# 🏥 Pozmixal System Health Check

Run this checklist to verify your system is properly configured and running.

---

## ✅ Pre-Startup Checklist

### 1. Docker Services
```bash
docker ps
```

**Expected Output** (all containers RUNNING):
- ✅ `pozmixal-postgres` - Status: Up
- ✅ `pozmixal-redis` - Status: Up  
- ✅ `pozmixal-pg-admin` - Status: Up
- ✅ `pozmixal-redisinsight` - Status: Up

**If missing**: 
```bash
docker-compose -f docker-compose.dev.yaml up -d
```

---

### 2. Environment Variables
```bash
# Windows Command Prompt
type .env

# Windows PowerShell
Get-Content .env

# macOS/Linux
cat .env
```

**Critical Variables** (must be present):
- ✅ `NODE_ENV=development`
- ✅ `DATABASE_URL=postgresql://pozmixal-local:pozmixal-local-pwd@localhost:5432/pozmixal-db-local`
- ✅ `REDIS_URL=redis://localhost:6379`
- ✅ `FRONTEND_URL=http://localhost:4200`
- ✅ `NEXT_PUBLIC_BACKEND_URL=http://localhost:3000`
- ✅ `BACKEND_URL=http://localhost:3000`
- ✅ `JWT_SECRET=<any-string>`

---

### 3. Database Connection
```bash
# Test PostgreSQL connection
docker exec pozmixal-postgres psql -U pozmixal-local -d pozmixal-db-local -c "SELECT 1"

# Expected: 
# 1
# (1 row)
```

**If fails**: Check Docker is running and PostgreSQL container is healthy

---

### 4. Redis Connection
```bash
# Test Redis connection
docker exec pozmixal-redis redis-cli ping

# Expected output: PONG
```

**If fails**: Check Redis container is running

---

## 🚀 Startup Sequence

### Phase 1: Install Dependencies
```bash
pnpm install
```

**Expected**: No errors, all packages installed

---

### Phase 2: Generate Prisma
```bash
pnpm run prisma-generate
```

**Expected Output**:
```
✔ Generated Prisma Client
```

---

### Phase 3: Setup Database
```bash
pnpm run prisma-db-push
```

**Expected Output**:
```
Prisma schema loaded from libraries/nestjs-libraries/src/database/prisma/schema.prisma
Datasource "db": PostgreSQL database "pozmixal-db-local" at "localhost:5432"

✔ Database synced
```

---

### Phase 4: Start Development
```bash
pnpm run dev
```

**Watch for these logs** (in the first 30 seconds):

✅ Frontend Starting:
```
▲ Next.js 15.x.x
- Local: http://localhost:4200
```

✅ Backend Starting:
```
[Nest] ... - 12/05/2025, XX:XX:XX AM     LOG [NestFactory] Bootstrapping...
...
✅ Successfully connected to PostgreSQL database
✅ Backend is running on: http://localhost:3000
```

---

## 🧪 Runtime Verification

### Test 1: Frontend Loads
```bash
# Open in browser
http://localhost:4200
```

**Expected**:
- ✅ Page loads without console errors
- ✅ No CORS errors
- ✅ Auth/login components visible

---

### Test 2: Backend API
```bash
# From terminal
curl http://localhost:3000/

# Expected response:
# App is running!
```

---

### Test 3: API Authentication
```bash
# Check swagger docs
curl http://localhost:3000/api/docs

# Should return HTML swagger page
```

---

### Test 4: Database Communication
```bash
# Frontend → Backend → Database test
curl http://localhost:3000/auth/can-register

# Expected response:
# {"register":true}
```

---

### Test 5: Redis Communication  
```bash
# Check backend logs show Redis connected
# Look for: "✅ Redis health check passed"
```

---

## 🔴 Common Issues & Fixes

### Issue: "Could not establish connection"
```
❌ Error: Could not establish connection. Receiving end does not exist.
```

**Fix**:
1. Verify `NEXT_PUBLIC_BACKEND_URL=http://localhost:3000`
2. Verify backend is running: `curl http://localhost:3000`
3. Check CORS in browser DevTools → Console tab
4. Ensure no typos in URLs

---

### Issue: "Database connection failed"
```
❌ Error: Could not establish connection to database
```

**Fix**:
1. Check PostgreSQL: `docker ps | grep postgres`
2. Check credentials in DATABASE_URL
3. Verify database exists: `docker exec pozmixal-postgres psql -U pozmixal-local -l`

---

### Issue: "CORS policy error"
```
❌ Access to XMLHttpRequest from origin 'http://localhost:4200' 
   has been blocked by CORS policy
```

**Fix**:
1. Verify `FRONTEND_URL=http://localhost:4200` in .env
2. Check you're accessing from exactly that URL
3. Restart backend after changing FRONTEND_URL

---

### Issue: "Redis connection error"
```
⚠️ Redis connection failed, falling back to MockRedis
```

**Acceptable** in development (uses in-memory fallback)

**To fix**:
1. Verify Redis running: `docker ps | grep redis`
2. Check `REDIS_URL=redis://localhost:6379`
3. Test: `redis-cli -h localhost -p 6379 ping`

---

## 📊 Health Check Status

After startup, you should see:

| Component | Status | Port | URL |
|-----------|--------|------|-----|
| Frontend | ✅ Running | 4200 | http://localhost:4200 |
| Backend | ✅ Running | 3000 | http://localhost:3000 |
| PostgreSQL | ✅ Connected | 5432 | (internal) |
| Redis | ✅ Connected | 6379 | (internal) |
| pgAdmin | ✅ Running | 8081 | http://localhost:8081 |
| RedisInsight | ✅ Running | 5540 | http://localhost:5540 |

---

## 🔧 Useful Commands

### View Logs
```bash
# All services
pnpm run dev

# Individual services
pnpm run dev:backend
pnpm run dev:frontend
```

### Database Management
```bash
# Access database
docker exec -it pozmixal-postgres psql -U pozmixal-local -d pozmixal-db-local

# View tables
\dt

# Exit
\q
```

### Redis Management  
```bash
# Access Redis CLI
docker exec -it pozmixal-redis redis-cli

# Check memory
INFO memory

# Exit
EXIT
```

### Check Port Usage
```bash
# Windows
netstat -ano | findstr :3000
netstat -ano | findstr :4200

# macOS/Linux
lsof -i :3000
lsof -i :4200
```

---

## ✨ Final Verification

After all fixes and startup, run this test:

```bash
# 1. Open http://localhost:4200 in browser
# 2. Open DevTools (F12)
# 3. Go to Console tab
# 4. Look for connection logs
# 5. Navigate to login page
# 6. Try to load data
# 7. No errors should appear
```

**Success Indicators**:
- ✅ No "CORS blocked" errors
- ✅ No "Could not establish connection" errors
- ✅ API calls succeed (check Network tab)
- ✅ Pages load without 500 errors
- ✅ Backend responds to requests

---

## 🎯 When Everything Works

You should see:

**Frontend Console**:
```
✅ Backend connection established
✅ Fetching user data...
✅ User authenticated
```

**Backend Logs**:
```
✅ Database connected
✅ Redis connected
✅ API server listening on 3000
```

**Browser**:
- Login/Register page loads
- Can navigate to dashboard
- Real-time updates working

---

**Status**: Ready to develop! 🚀
