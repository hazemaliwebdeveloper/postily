# 🚀 START HERE - Run Postiz Locally

## ⚡ Quick Start (30 seconds)

### Windows
```bash
# Double-click one of these files in the project folder:
RUN_NOW.bat
# OR
RUN_NOW.ps1 (right-click → Run with PowerShell)
```

### Mac/Linux
```bash
pnpm install
pnpm run prisma-db-push
pnpm run dev
```

---

## 📋 What Happens Automatically

When you run the startup script:

1. ✅ **Installs dependencies** (if needed)
2. ✅ **Sets up database** (PostgreSQL)
3. ✅ **Builds extension** (Chrome)
4. ✅ **Starts all services**:
   - Backend (NestJS) → http://localhost:3000
   - Frontend (Next.js) → http://localhost:4200
   - Extension (watch mode) → rebuilds on file changes

---

## 🔧 Prerequisites (Must Have)

### On Your Computer
- [ ] **Node.js 22** - Download from https://nodejs.org/
- [ ] **pnpm** - Run: `npm install -g pnpm`
- [ ] **PostgreSQL 15+** - Download from https://www.postgresql.org/download/
- [ ] **Redis** - Download from https://redis.io/ OR use Docker

### Verify Installation
```bash
node --version        # Should be 22.x.x
pnpm --version        # Should be 10.x.x
psql --version        # Should be 15+
redis-cli --version   # Should be installed
```

### Start PostgreSQL & Redis

**Windows**:
- PostgreSQL: It usually runs as a service automatically
- Redis: Either install service or use Docker:
  ```bash
  docker run -d -p 6379:6379 redis:latest
  ```

**Mac**:
```bash
brew services start postgresql@15
brew services start redis
```

**Linux**:
```bash
sudo systemctl start postgresql
sudo systemctl start redis-server
```

---

## 📝 Manual Step-by-Step (If Script Doesn't Work)

### Step 1: Open Terminal in Project Folder
```bash
# Windows: Open Command Prompt or PowerShell in the postily folder
# Or use Git Bash
cd c:\Users\it\Downloads\pozmixal\postily
```

### Step 2: Install Dependencies
```bash
pnpm install
```

### Step 3: Setup Database
```bash
pnpm run prisma-db-push
```

### Step 4: Start Backend (Terminal 1)
```bash
cd apps/backend
pnpm run dev
# Wait until you see: "Listening on port 3000"
```

### Step 5: Start Frontend (Terminal 2)
```bash
cd apps/frontend
pnpm run dev
# Wait until you see: "Ready in 15s"
# Then open: http://localhost:4200
```

### Step 6: Start Extension (Terminal 3)
```bash
cd apps/extension
pnpm run dev:chrome
# Wait until you see: "clean exit - waiting for changes"
```

### Step 7: Load Extension in Chrome
1. Open Chrome
2. Go to: `chrome://extensions`
3. Enable **"Developer mode"** (toggle on top right)
4. Click **"Load unpacked"**
5. Select folder: `apps/extension/dist/`
6. Click **"Open"**

---

## ✅ How to Know It's Working

### Backend (port 3000)
```bash
# In PowerShell, run:
curl http://localhost:3000/health
# Should return: OK or health status
```

### Frontend (port 4200)
- Open browser: http://localhost:4200
- You should see the Postiz login page

### Extension
1. Go to chrome://extensions
2. Find "Postiz" in the list
3. It should show **"Service worker (active)"**
4. Click the extension icon → popup should load

---

## ❌ Troubleshooting

### "Port 3000 already in use"
```bash
# Find and kill the process using port 3000
# Windows PowerShell:
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Mac/Linux:
lsof -i :3000
kill -9 <PID>
```

### "Port 4200 already in use"
```bash
# Same as above but use :4200
```

### "PostgreSQL connection refused"
```bash
# Make sure PostgreSQL is running
# Windows: Check Services (services.msc) for PostgreSQL
# Mac: brew services start postgresql@15
# Linux: sudo systemctl start postgresql
```

### "Redis connection refused"
```bash
# Make sure Redis is running
# Windows: Start Redis
# Mac: brew services start redis
# Linux: sudo systemctl start redis-server
# OR use Docker: docker run -d -p 6379:6379 redis:latest
```

### "Extension won't load"
```bash
# Rebuild extension
cd apps/extension
pnpm run build:chrome

# Then reload in chrome://extensions (click the refresh icon)
```

### "Blank popup in extension"
1. Go to chrome://extensions
2. Find Postiz → Click "Service Worker"
3. Look at the console for errors
4. If errors, check backend is running (http://localhost:3000/health)

### "Cannot find module '@gitroom/extension/...'"
```bash
# Clear cache and reinstall
pnpm install
pnpm run prisma-generate
```

---

## 🔄 Common Commands

```bash
# From project root (c:\Users\it\Downloads\pozmixal\postily):

# Install dependencies
pnpm install

# Setup database
pnpm run prisma-generate
pnpm run prisma-db-push

# Run all services
pnpm run dev

# Run specific service
pnpm --filter ./apps/backend run dev    # Backend only
pnpm --filter ./apps/frontend run dev   # Frontend only
pnpm --filter ./apps/extension run dev:chrome  # Extension only

# Build extension
pnpm --filter ./apps/extension run build:chrome

# Reset database (careful!)
pnpm run prisma-reset
```

---

## 📚 URLs When Running

| Service | URL | Purpose |
|---------|-----|---------|
| **Frontend** | http://localhost:4200 | Web interface - Login here first |
| **Backend** | http://localhost:3000 | API server |
| **Extension** | chrome://extensions | Load extension here |
| **Health Check** | http://localhost:3000/health | Test backend connectivity |

---

## 🔐 First Login

1. Open http://localhost:4200
2. Click "Sign Up" or use test credentials
3. Create an account or login
4. Now the extension will work on that site

---

## 📖 More Help

- **Setup Issues**: See `SETUP_LOCAL.md`
- **Extension Issues**: See `EXTENSION_DEBUG.md`
- **Development Guide**: See `CLAUDE.md`
- **Full Deployment**: See `DEPLOYMENT_VALIDATION_CHECKLIST.md`

---

## ✨ You're All Set!

The application is now running locally:
- ✅ Backend running on port 3000
- ✅ Frontend running on port 4200
- ✅ Extension loaded in Chrome
- ✅ Database synchronized

**Start developing!** 🚀

Changes you make to code will automatically rebuild (especially the extension in watch mode).

---

**Still not working?**

Run the verification script:
```bash
VERIFY.bat
```

This will check if all services are accessible and tell you what's wrong.
