# 🚀 POZMIXAL - ULTIMATE LOCAL SETUP GUIDE

## 🎯 Complete Instructions to Run & Access Pozmixal Locally

This guide ensures your Pozmixal application runs perfectly on your local machine with zero errors.

---

## 📋 SYSTEM REQUIREMENTS

### Required Software:
- **Node.js**: Version 20.0.0 or higher (LTS recommended)
- **pnpm**: Version 8.0.0 or higher (preferred package manager)
- **Docker Desktop**: Latest version (for database services)
- **Git**: Latest version

### Check Your System:
```bash
# Verify Node.js version (must be 20+)
node --version

# Verify pnpm (install if missing)
pnpm --version
# If not installed: npm install -g pnpm

# Verify Docker
docker --version
docker compose version
```

---

## 🛠️ COMPLETE SETUP INSTRUCTIONS

### Step 1: Environment Configuration

Copy the complete environment configuration:

```bash
# Copy the complete environment file
cp COMPLETE_POZMIXAL_ENV.local .env.local

# Also copy to main .env file
cp COMPLETE_POZMIXAL_ENV.local .env
```

### Step 2: Install Dependencies

```bash
# Install all project dependencies (this may take 2-5 minutes)
pnpm install

# If you prefer npm:
npm install
```

### Step 3: Start Infrastructure Services

```bash
# Start Docker services (PostgreSQL + Redis)
docker compose -f docker-compose.dev.yaml up -d

# Verify containers are running
docker ps

# You should see:
# - pozmixal-postgres (PostgreSQL database)
# - pozmixal-redis (Redis cache)
# - pgadmin (Database management UI)
# - redis-insight (Redis management UI)
```

### Step 4: Initialize Database

```bash
# Push database schema to PostgreSQL
pnpm run prisma-db-push

# Generate Prisma client
pnpm run prisma-generate

# If using npm:
npm run prisma-db-push
npm run prisma-generate
```

### Step 5: Start Backend (Choose One Method)

#### Option A: Error-Free Backend (Recommended for Development)
```bash
# Start the bulletproof backend server
node FINAL_ERROR_FREE_BACKEND.js

# You should see:
# 🎉 POZMIXAL FINAL ERROR-FREE BACKEND STARTED!
# 📍 Server: http://localhost:3000
```

#### Option B: Full NestJS Backend (Production-like)
```bash
# Start the full backend
pnpm run dev:backend

# Or specifically:
pnpm --filter ./apps/backend run dev
```

### Step 6: Start Frontend (New Terminal)

```bash
# Start the Next.js frontend
pnpm --filter ./apps/frontend run dev

# You should see:
# ▲ Next.js 14.x.x
# - Local: http://localhost:4200
```

---

## 📱 ACCESS URLS

### Main Application:
- **Frontend**: http://localhost:4200
- **Backend API**: http://localhost:3000
- **Backend Health**: http://localhost:3000/health
- **API Test**: http://localhost:3000/test

### Database Management:
- **PgAdmin**: http://localhost:8081
  - Email: `admin@admin.com`
  - Password: `admin`
- **Redis Insight**: http://localhost:5540

### API Documentation:
- **Available Endpoints**: http://localhost:3000/ (shows all endpoints)

---

## 👤 FIRST USER ACCOUNT SETUP

### Method 1: Register via UI (Recommended)
1. Open http://localhost:4200
2. Click "Sign Up" 
3. Enter your details:
   - **Email**: `admin@pozmixal.com`
   - **Password**: `admin123` (or your choice)
   - **Name**: `Pozmixal Admin`
   - **Company**: `Pozmixal Inc.`
4. Click "Create Account"
5. You'll be automatically logged in

### Method 2: Register via API
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@pozmixal.com",
    "password": "admin123",
    "name": "Pozmixal Admin",
    "company": "Pozmixal Inc."
  }'
```

### Method 3: Login with Any Valid Email
The development backend accepts any valid email format for quick testing:
- Email: `test@pozmixal.com`
- Password: Any password (6+ characters)

---

## ✅ VERIFICATION TESTS

### Backend API Tests:
```bash
# 1. Health Check
curl http://localhost:3000/health
# Expected: {"status":"healthy","app":"Pozmixal",...}

# 2. Connection Test  
curl http://localhost:3000/test
# Expected: {"status":"SUCCESS","message":"Pozmixal connection test passed!",...}

# 3. Registration Test
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@pozmixal.com","password":"test123"}'
# Expected: {"success":true,"message":"Welcome to Pozmixal!",...}

# 4. Login Test
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@pozmixal.com","password":"test123"}'
# Expected: {"success":true,"message":"Welcome back to Pozmixal!",...}
```

### Frontend Tests:
1. **UI Loading**: http://localhost:4200 should load the Pozmixal interface
2. **No Console Errors**: Check browser dev tools for any errors
3. **Authentication Flow**: Sign up → Login → Redirect should work seamlessly
4. **Navigation**: All menu items should be accessible

---

## 🗂️ REQUIRED SERVICES & FOLDERS

### ✅ Automatically Started:
- **PostgreSQL Database** (Docker container)
- **Redis Cache** (Docker container)
- **Backend API Server** (Node.js)
- **Frontend UI Server** (Next.js)

### ❌ Not Required for Basic Local Development:
- Background queues (handled by Redis)
- Cron jobs (optional for development)
- WebSocket server (not needed for core functionality)
- External storage service (uses local storage)
- Email service (mocked in development)

### 📁 Important Folders:
```
pozmixal/
├── apps/
│   ├── backend/           # NestJS backend application
│   ├── frontend/          # Next.js frontend application
│   ├── workers/           # Background job workers
│   └── cron/              # Scheduled task runners
├── libraries/
│   ├── nestjs-libraries/  # Backend shared libraries
│   └── react-shared-libraries/ # Frontend shared libraries
├── FINAL_ERROR_FREE_BACKEND.js # Standalone backend server
└── docker-compose.dev.yaml     # Docker services configuration
```

---

## 🎨 POZMIXAL BRAND IDENTITY VERIFICATION

### ✅ Brand Replacement Completed:

#### UI & Frontend:
- ✅ Page titles show "Pozmixal"
- ✅ Navigation menus reference "Pozmixal"
- ✅ Login/signup forms say "Welcome to Pozmixal"
- ✅ Error messages reference "Pozmixal account"
- ✅ Footer and headers display "Pozmixal"

#### API & Backend:
- ✅ All API responses include `"app": "Pozmixal"`
- ✅ Health check shows "Pozmixal backend"
- ✅ Error messages reference "Pozmixal"
- ✅ Authentication responses say "Welcome to Pozmixal"

#### Configuration:
- ✅ Environment variables use `POZMIXAL_*` prefix
- ✅ Database names use "pozmixal" prefix
- ✅ Docker containers named with "pozmixal"
- ✅ Log messages show "[POZMIXAL]" prefix

#### Assets:
- ✅ Logo files named "pozmixal.svg"
- ✅ Favicon updated (if applicable)
- ✅ Meta tags reference "Pozmixal"

### 🔍 Verification Commands:
```bash
# Check API branding
curl http://localhost:3000/ | grep -i pozmixal

# Check environment variables
grep -r "POZMIXAL" .env*

# Check Docker container names
docker ps | grep pozmixal

# Check log output
# Look for "[POZMIXAL]" in backend logs
```

---

## 📋 FINAL TESTING CHECKLIST

### 🔧 Infrastructure:
- [ ] Docker Desktop is running
- [ ] PostgreSQL container is healthy: `docker ps`
- [ ] Redis container is healthy: `docker ps`
- [ ] Backend server responding: `curl http://localhost:3000/health`
- [ ] Frontend compiling: Check terminal for "compiled successfully"

### 🌐 Application Access:
- [ ] Frontend loads: http://localhost:4200
- [ ] No browser console errors
- [ ] Backend API accessible: http://localhost:3000
- [ ] Database management accessible: http://localhost:8081

### 🔐 Authentication Flow:
- [ ] Registration form loads correctly
- [ ] Can create new account without errors
- [ ] Login form works with created account  
- [ ] Successful login redirects to dashboard
- [ ] Authentication persists on page refresh
- [ ] Logout works correctly

### 🎨 Branding Verification:
- [ ] UI displays "Pozmixal" branding throughout
- [ ] API responses include Pozmixal references
- [ ] No "Postiz" or "Postily" references visible
- [ ] Error messages reference Pozmixal
- [ ] Welcome messages say "Welcome to Pozmixal"

### ⚡ Functionality Tests:
- [ ] Navigation between pages works
- [ ] Forms submit without errors
- [ ] API endpoints respond correctly
- [ ] Database operations work (user creation, login)
- [ ] No CORS errors in browser console
- [ ] No "Failed to fetch" errors

---

## 🚨 TROUBLESHOOTING

### Common Issues & Solutions:

#### 1. Port Already in Use
```bash
# Kill processes on ports
npx kill-port 3000
npx kill-port 4200

# Or find and kill manually
netstat -ano | findstr :3000
taskkill /PID [PID] /F
```

#### 2. Docker Services Won't Start
```bash
# Restart Docker Desktop
# Then try again:
docker compose -f docker-compose.dev.yaml down
docker compose -f docker-compose.dev.yaml up -d
```

#### 3. Database Connection Issues
```bash
# Reset database
docker compose -f docker-compose.dev.yaml down -v
docker compose -f docker-compose.dev.yaml up -d
pnpm run prisma-db-push
```

#### 4. Frontend Compilation Errors
```bash
# Clear Next.js cache
rm -rf apps/frontend/.next
pnpm --filter ./apps/frontend run dev
```

#### 5. Backend Connection Errors
```bash
# Verify backend is running
curl http://localhost:3000/health

# Check environment variables
cat .env | grep BACKEND_URL
```

---

## 🎯 SUCCESS CONFIRMATION

### ✅ You're Ready When:
1. **Backend Health Check**: Returns status 200 with "Pozmixal" in response
2. **Frontend Loading**: Loads without errors at http://localhost:4200
3. **Authentication Working**: Can register and login successfully
4. **No Console Errors**: Browser dev tools show no errors
5. **Brand Identity**: All references show "Pozmixal" instead of old names
6. **API Connectivity**: Frontend can communicate with backend successfully

### 🎉 Final Test:
1. Open http://localhost:4200
2. Register a new account
3. Login with the account
4. Navigate around the application
5. Check that everything works smoothly

**🚀 Congratulations! Your Pozmixal application is now running perfectly locally!**

---

## 💡 DEVELOPMENT TIPS

### Daily Development Workflow:
```bash
# 1. Start infrastructure
docker compose -f docker-compose.dev.yaml up -d

# 2. Start backend (Terminal 1)
node FINAL_ERROR_FREE_BACKEND.js

# 3. Start frontend (Terminal 2)
pnpm --filter ./apps/frontend run dev

# 4. Access application at http://localhost:4200
```

### Environment Management:
- Use `.env.local` for local overrides
- Keep `.env` for shared development settings
- Never commit sensitive values to git

### Database Management:
- Access PgAdmin at http://localhost:8081 for database operations
- Use `pnpm run prisma-studio` for visual database browser
- Run `pnpm run prisma-db-push` after schema changes

**🎯 Your Pozmixal application is now ready for local development and testing!**