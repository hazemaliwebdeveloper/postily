# 🔧 SOLVE "Connection Refused" Error - WORKING SOLUTION

## Problem
You're getting: `ERR_CONNECTION_REFUSED` on `http://localhost:4200`

## Root Cause
The services are not starting properly or not listening on the correct ports.

---

## ✅ WORKING SOLUTION - Use Separate Windows

### Step 1: Open 3 Command Prompts

**Do this:**
1. Press `Win + R`
2. Type `cmd`
3. Click OK
4. Repeat 2 more times (you'll have 3 command prompts open)

### Step 2: In First Window - Start Backend

**Window 1:**
```bash
cd c:\Users\it\Downloads\pozmixal\postily\apps\backend
pnpm run dev
```

**Wait until you see:**
```
🚀 Backend is running on: http://localhost:3000
```

**This means backend is ready!**

### Step 3: In Second Window - Start Frontend

**Window 2:**
```bash
cd c:\Users\it\Downloads\pozmixal\postily\apps\frontend
pnpm run dev
```

**Wait until you see:**
```
✓ Ready in X seconds
- Local:        http://localhost:4200
```

**This means frontend is ready!**

### Step 4: Test Backend Health

**Window 3 (or new command prompt):**
```bash
curl http://localhost:3000/health
```

**Should return:** `OK`

If you get error, backend didn't start properly.

### Step 5: Open Browser

Once you see both messages:
- Backend: `🚀 Backend is running on: http://localhost:3000`
- Frontend: `✓ Ready in X seconds`

**Then:**
Open browser: `http://localhost:4200`

**You should see login page!** ✅

---

## 🚀 Quick Method Using Batch Files

Instead of typing commands, just double-click:

1. **RUN_BACKEND.bat** - Starts backend (keep window open)
2. **RUN_FRONTEND.bat** - Starts frontend (keep window open)
3. Wait for both to show "Ready" messages
4. Open browser: `http://localhost:4200`

---

## 🐛 Still Getting "Connection Refused"?

### Check 1: Verify Port 4200 is Actually Running

**In a new command prompt:**
```bash
netstat -ano | findstr :4200
```

**Should show:** A process using port 4200

**If shows nothing:** Frontend never started
- Check the frontend window for error messages
- Scroll up to see the startup logs

### Check 2: Verify Port 3000 is Actually Running

```bash
netstat -ano | findstr :3000
```

**Should show:** A process using port 3000

**If shows nothing:** Backend never started
- Check the backend window for error messages
- Look for "🚀 Backend is running"

### Check 3: Check for Errors in Windows

**In backend window:**
- Look for `ERROR` or `Exception`
- Look for database errors like `connect ECONNREFUSED`

**In frontend window:**
- Look for `ERROR` or `FAILED`
- Look for compilation errors

---

## 🔍 Debug: What Each Service Should Show

### Backend Startup (Normal)
```
> pozmixal-backend@1.0.0 dev
> dotenv -e ../../.env -- nest start --watch

[2:57:20 PM] Starting compilation in watch mode...
To restart at any time, enter rs.

(waits 10-20 seconds)

✅ CORS configured for origins: http://localhost:4200
🚀 Backend is running on: http://localhost:3000
```

### Frontend Startup (Normal)
```
> pozmixal-frontend@1.0.0 dev
> dotenv -e ../../.env -- next dev -p 4200

   ▲ Next.js 15.5.7
   - Local:        http://localhost:4200
   - Network:      http://172.27.80.1:4200

 ✓ Starting...
 ○ Compiling /instrumentation ...
 ✓ Compiled /instrumentation in 5.4s
 ✓ Ready in 12.5s
```

---

## ⚠️ Common Problems

### Problem: Port Already in Use

**Error:**
```
listen EADDRINUSE :::3000
```

**Fix:**
```bash
netstat -ano | findstr :3000
taskkill /PID <number> /F
```

Then restart backend.

### Problem: Database Connection Error

**Error:**
```
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Fix:**
- Start PostgreSQL
- Windows: Services → PostgreSQL → Start
- Or check `.env` DATABASE_URL is correct

### Problem: Redis Connection Error

**Error:**
```
Redis connection refused
```

**Fix:**
- Start Redis
- Windows: `docker run -d -p 6379:6379 redis:latest`
- Or start Redis service

---

## ✅ Verification Checklist

Before trying browser, confirm:

- [ ] Backend window shows: `🚀 Backend is running on: http://localhost:3000`
- [ ] Frontend window shows: `✓ Ready in X seconds`
- [ ] 3 separate command windows are open (not closed)
- [ ] No error messages in any window
- [ ] `curl http://localhost:3000/health` returns `OK`

---

## 🎯 Final Test

1. **Backend window:** Shows "Backend is running"
2. **Frontend window:** Shows "Ready in X seconds"
3. **Open browser:** `http://localhost:4200`
4. **Result:** See Postiz login page ✅

If you see blank page or loading forever:
- Check console (F12)
- Check network tab for errors
- Check backend is returning responses

---

## 📝 Files to Use

Run these batch files from project folder:

- `RUN_BACKEND.bat` - Start backend only
- `RUN_FRONTEND.bat` - Start frontend only

Or run commands manually in separate command prompts (recommended for debugging).

---

## 🆘 Still Not Working?

Try this **nuclear option**:

```bash
# In project root
pnpm install
pnpm run prisma-generate
pnpm run prisma-db-push

# Make sure PostgreSQL and Redis are running

# Then try again with separate windows
```

If STILL not working, the issue is likely:
1. PostgreSQL not running → Start it
2. Redis not running → Start it with Docker
3. Node modules corrupted → Delete node_modules, run pnpm install again
4. Port in use → Kill the process using that port

---

## KEY POINT

**DO NOT USE:** `pnpm run dev` from root
**DO USE:** Separate command windows for backend and frontend

This prevents one service blocking the other!

---

**Try now and report results!**
