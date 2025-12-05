# 🚀 START LOCAL ENVIRONMENT - Complete Setup Instructions

## **Current Status**

✅ **Prerequisites Verified:**
- Node.js v22.19.0 ✓
- npm v10.9.3 ✓
- pnpm v10.6.1 ✓
- Docker v28.5.1 ✓
- Dependencies Installed ✓

⏳ **Next Steps:**
1. Start Docker Desktop
2. Start Docker services
3. Generate Prisma client
4. Run database migrations
5. Start development environment

---

## **STEP 1: Start Docker Desktop**

### **On Windows:**

1. **Open Start Menu** and search for "Docker Desktop"
2. **Click** "Docker Desktop" to launch it
3. **Wait 30-60 seconds** for Docker to initialize
4. You'll see the Docker icon in the system tray (bottom right)
5. The icon should show "Docker Desktop is running" when you hover over it

### **Verify Docker is Running:**

```powershell
# Open PowerShell and run:
docker ps

# Should show:
# CONTAINER ID   IMAGE      COMMAND      CREATED      STATUS      PORTS      NAMES
# (empty if no containers running yet)
```

If you see an error like `Cannot connect to Docker daemon`, Docker is not running. Go back and start Docker Desktop.

---

## **STEP 2: Start Docker Services**

Once Docker is running, open PowerShell and run:

```powershell
cd C:\Users\it\Downloads\pozmixal\postily

# Start PostgreSQL and Redis containers
docker compose -f docker-compose.dev.yaml up -d
```

**Expected output:**
```
[+] Running 4/4
  ✔ Container pozmixal-postgres      Started
  ✔ Container pozmixal-redis         Started
  ✔ Container pozmixal-pg-admin      Started
  ✔ Container pozmixal-redisinsight  Started
```

### **Verify Services Started:**

```powershell
docker ps
```

Should show 4 containers:
- `pozmixal-postgres` (PostgreSQL database)
- `pozmixal-redis` (Cache/message queue)
- `pozmixal-pg-admin` (Database management UI)
- `pozmixal-redisinsight` (Redis management UI)

---

## **STEP 3: Wait for PostgreSQL to Be Ready**

PostgreSQL needs 10-30 seconds to initialize. Run this to check:

```powershell
# Keep running this until it succeeds:
docker exec pozmixal-postgres pg_isready -U pozmixal-local
```

**Success message:**
```
accepting connections
```

**Still waiting?**
```
rejecting connections
```

Wait a few more seconds and try again.

---

## **STEP 4: Generate Prisma Client**

```powershell
cd C:\Users\it\Downloads\pozmixal\postily
pnpm run prisma-generate
```

**Expected output:**
```
✔ Generated Prisma Client (v5.18.0) to ./node_modules/@prisma/client in 245ms
```

---

## **STEP 5: Run Database Migrations**

```powershell
pnpm run prisma-db-push
```

**You'll be asked:**
```
✔ Database created
✔ Migrations completed
```

If you see any warnings, you'll be asked if you want to continue. Type `y` and press Enter.

---

## **STEP 6: Start Development Environment**

Now start all services:

```powershell
pnpm run dev
```

**Wait for messages like:**
```
➜  Backend ready on http://localhost:3000
➜  Frontend ready on http://localhost:4200
```

When you see these messages, the setup is complete!

---

## **STEP 7: Access the Application**

Open your browser and visit:

### **http://localhost:4200**

You should see:
- Pozmixal login page
- "Sign up" button
- "Forgot password" link

### **Create Your First Account:**

1. Click "Sign up"
2. Enter email and password
3. Click "Create account"
4. You should be logged in and see the dashboard

---

## **Available Services**

Once everything is running, you can access:

| Service | URL | Purpose |
|---------|-----|---------|
| **Pozmixal App** | http://localhost:4200 | Main application |
| **Backend API** | http://localhost:3000 | API endpoints |
| **API Documentation** | http://localhost:3000/docs | Swagger API docs |
| **pgAdmin** | http://localhost:8081 | Database GUI |
| **RedisInsight** | http://localhost:5540 | Redis GUI |

---

## **Troubleshooting**

### **Problem: "Cannot connect to Docker daemon"**

**Solution:**
1. Open Docker Desktop from Start Menu
2. Wait 1 minute for it to fully load
3. Try `docker ps` again

### **Problem: PostgreSQL won't connect**

**Solution:**
```powershell
# Restart PostgreSQL container
docker restart pozmixal-postgres

# Wait 10 seconds, then check
docker exec pozmixal-postgres pg_isready -U pozmixal-local
```

### **Problem: "Port 3000 already in use"**

**Solution:**
```powershell
# Find what's using port 3000
netstat -ano | findstr :3000

# If something is using it, either:
# 1. Close that application
# 2. Change port in .env file
# 3. Kill the process (find PID above and use it):
taskkill /PID <PID> /F
```

### **Problem: Frontend shows blank page**

**Solution:**
1. Check backend is running: `curl http://localhost:3000/health`
2. Open DevTools in browser (F12)
3. Check Console tab for errors
4. Hard refresh: Ctrl+Shift+R
5. Check .env file has correct URLs

### **Problem: Cannot create account**

**Solution:**
```powershell
# Make sure database is ready
docker exec pozmixal-postgres pg_isready -U pozmixal-local

# Make sure migrations ran
pnpm run prisma-db-push

# Restart backend (stop pnpm and run again)
pnpm run dev
```

---

## **Stopping Everything**

### **Stop Services:**

In the terminal running `pnpm run dev`, press **Ctrl+C**

### **Stop Docker Containers:**

```powershell
docker compose -f docker-compose.dev.yaml down
```

### **Stop Docker and Remove Data:**

```powershell
# WARNING: This deletes all database data
docker compose -f docker-compose.dev.yaml down -v
```

---

## **Next Steps**

Now that your environment is running:

1. ✅ Create an account on http://localhost:4200
2. ✅ Explore the dashboard
3. ✅ Create your first post
4. ✅ Check out the extension setup (optional)
5. ✅ Add social media API keys (optional)

---

## **Quick Reference**

**Full setup from scratch:**
```powershell
cd C:\Users\it\Downloads\pozmixal\postily

# 1. Docker services
docker compose -f docker-compose.dev.yaml up -d

# 2. Wait for PostgreSQL
docker exec pozmixal-postgres pg_isready -U pozmixal-local

# 3. Generate Prisma
pnpm run prisma-generate

# 4. Database migration
pnpm run prisma-db-push

# 5. Start everything
pnpm run dev
```

---

## **Health Check Commands**

Use these to verify everything is working:

```powershell
# Check Docker containers
docker ps

# Check PostgreSQL
docker exec pozmixal-postgres pg_isready -U pozmixal-local

# Check backend
curl http://localhost:3000/health

# Check frontend (should return HTML)
curl http://localhost:4200
```

---

## **Support**

- See `LOCAL_DEVELOPMENT_SETUP_GUIDE.md` for detailed documentation
- See `TROUBLESHOOTING.md` for additional issues
- See `EXTENSION_CONNECTION_ERROR_FIX.md` for extension setup

---

**Status:** ✅ Ready to develop!
