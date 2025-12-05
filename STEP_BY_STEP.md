# 🚀 STEP-BY-STEP: Get Postiz Running NOW

## THE PROBLEM YOU HIT

When you tried `http://localhost:4200`, you got:
```
ERR_CONNECTION_REFUSED
localhost refused to connect
```

**Why?** The frontend wasn't running yet (or still compiling).

## THE FIX - Do This Now

### STEP 1: Open Command Prompt or PowerShell

**Windows:**
1. Press `Win + R`
2. Type: `cmd`
3. Press Enter

### STEP 2: Navigate to Project

```bash
cd c:\Users\it\Downloads\pozmixal\postily
```

### STEP 3: Install Once (First Time Only)

```bash
pnpm install
```

Wait for completion (takes 1-2 minutes).

### STEP 4: Prepare Database

```bash
pnpm run prisma-db-push
```

Should show: `Prisma schema pushed to database`

### STEP 5: Start Services

```bash
pnpm run dev
```

### STEP 6: WAIT and WATCH

You'll see output like:

**From Backend:**
```
[2:41:53 PM] Starting compilation in watch mode...
To restart at any time, enter rs.
```

**From Frontend:**
```
   ▲ Next.js 15.5.7
   - Local:        http://localhost:4200
   
 ✓ Starting...
 ✓ Compiled /instrumentation in 5.4s
 ✓ Ready in 12.7s
```

### ⏳ THIS IS THE KEY PART

**DO NOT try to access anything until you see:**
```
✓ Ready in X seconds
```

This means the frontend is ready!

### STEP 7: Once You See "Ready"

Open your browser and type:
```
http://localhost:4200
```

You should see **Postiz login page** ✅

---

## If You Still Get "Connection Refused"

### Check 1: Are All Terminal Windows Still Open?

The `pnpm run dev` command runs multiple services in ONE terminal.

If terminal closed → Services stopped → Connection refused.

**Solution**: Run `pnpm run dev` again and keep terminal open.

### Check 2: Did You Wait Long Enough?

**First time startup:**
- Backend compilation: 5-10 seconds
- Frontend compilation: 10-15 seconds
- **Total: 15-25 seconds**

Wait the full time! Don't access before "Ready" message.

### Check 3: Is Port 4200 in Use?

```powershell
# Check what's using port 4200
netstat -ano | findstr :4200

# If something shows up, kill it:
taskkill /PID <the-number> /F
```

Then try again.

### Check 4: PostgreSQL or Redis Down?

```bash
# Test PostgreSQL
psql -U pozmixal-local -d pozmixal-db-local -c "SELECT 1"

# Test Redis
redis-cli ping
```

Both should work. If not, start them.

---

## WHAT YOU SHOULD SEE

### Terminal 1: Shows Backend Compiling
```
> pozmixal-backend@1.0.0 dev
> dotenv -e ../../.env -- nest start --watch

[2:41:53 PM] Starting compilation in watch mode...
```

### Terminal 2: Shows Frontend Ready
```
> pozmixal-frontend@1.0.0 dev
> dotenv -e ../../.env -- next dev -p 4200

   ▲ Next.js 15.5.7
   - Local:        http://localhost:4200

 ✓ Ready in 12.7s
```

### Browser
```
Open: http://localhost:4200
See:  Postiz Login Page ✅
```

---

## IF USING SEPARATE TERMINALS

Instead of `pnpm run dev`, you can run each service separately:

### Terminal 1: Backend
```bash
cd apps/backend
pnpm run dev

# Wait for it to show ready
```

### Terminal 2: Frontend (NEW terminal, same folder)
```bash
cd apps/frontend
pnpm run dev

# Wait for "Ready in X seconds"
```

### Terminal 3: Extension (NEW terminal, same folder)
```bash
cd apps/extension
pnpm run dev:chrome

# This is optional, just builds/watches extension
```

---

## ✅ NOW Try Browser

Once you see frontend "Ready in X seconds":

```
http://localhost:4200
```

Should load immediately! ✅

---

## 🎯 QUICK CHECKLIST

- [ ] Opened terminal
- [ ] Ran `pnpm install` (first time only)
- [ ] Ran `pnpm run prisma-db-push`
- [ ] Ran `pnpm run dev`
- [ ] **WAITED for "✓ Ready in X seconds"**
- [ ] Opened browser: http://localhost:4200
- [ ] See login page ✅

---

## 🆘 STILL NOT WORKING?

**Copy and run this to test backend:**
```bash
curl http://localhost:3000/health
```

Should return: `OK` or health status

**If error**: Backend not running
- Check terminal for "nest" startup message
- Wait longer for compilation

---

## 🎉 YOU'VE GOT THIS!

The issue is almost always **timing** - giving services time to start.

Run `pnpm run dev` → wait 20 seconds → open browser.

That's it!
