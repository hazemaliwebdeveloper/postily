# Pozmixal - Quick Start Guide (15 Minutes)

## ⚡ The Fastest Way to Get Pozmixal Running Locally

Follow these steps in order. Takes about 15 minutes.

---

## 1️⃣ Prerequisites (2 minutes)

### Verify you have:
```bash
node --version          # Should be 22.x
pnpm --version         # Should be 10.6.1+
docker --version       # Optional but recommended
```

**Missing something?**
- Install Node.js: https://nodejs.org (download v22)
- Install pnpm: `npm install -g pnpm@10.6.1`
- Install Docker: https://docker.com

---

## 2️⃣ Start Database & Redis (2 minutes)

### Using Docker (Recommended - One Command)
```bash
cd c:\Users\it\Downloads\pozmixal\postily

docker-compose -f docker-compose.dev.yaml up -d \
  pozmixal-postgres pozmixal-redis
```

**Verify:**
```bash
docker-compose -f docker-compose.dev.yaml ps
# Should show pozmixal-postgres and pozmixal-redis as UP
```

### Without Docker?
- Install PostgreSQL locally: https://www.postgresql.org/download
- Install Redis locally: https://redis.io/download
- Create database:
  ```bash
  psql -U postgres
  CREATE USER "pozmixal-local" WITH PASSWORD 'pozmixal-local-pwd';
  CREATE DATABASE "pozmixal-db-local" OWNER "pozmixal-local";
  \q
  ```

---

## 3️⃣ Setup Application (4 minutes)

```bash
# Go to project directory
cd c:\Users\it\Downloads\pozmixal\postily

# Install dependencies
pnpm install

# Setup database
pnpm run prisma-generate
pnpm run prisma-db-push
```

---

## 4️⃣ Create .env File (1 minute)

```bash
# Copy template
cp .env.local .env

# Or on Windows:
copy .env.local .env
```

**Edit `.env` and verify these are correct:**

```bash
FRONTEND_URL=http://localhost:4200
NEXT_PUBLIC_BACKEND_URL=http://localhost:3000
DATABASE_URL=postgresql://pozmixal-local:pozmixal-local-pwd@localhost:5432/pozmixal-db-local
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
```

⚠️ **IMPORTANT**: `FRONTEND_URL` must match what you'll type in your browser!

---

## 5️⃣ Start the Application (3 minutes)

```bash
# Start everything at once
pnpm run dev
```

**Wait for both to show:**
- Backend: `🚀 Backend is running on: http://localhost:3000`
- Frontend: `- ready started server on 0.0.0.0:4200`

---

## 6️⃣ Access & Login (3 minutes)

### Open in Browser
```
http://localhost:4200
```

### Create Account
1. Click "Sign Up"
2. Enter:
   - Email: `admin@pozmixal.local`
   - Password: `Admin123!Secure`
3. Click "Sign Up"
4. You're now logged in! 🎉

---

## ✅ That's It!

Your Pozmixal application is now running locally with:
- ✅ Frontend: http://localhost:4200
- ✅ Backend API: http://localhost:3000
- ✅ Database: PostgreSQL on localhost:5432
- ✅ Cache: Redis on localhost:6379
- ✅ Admin user created and logged in

---

## 🧪 Quick Verification

```bash
# In another terminal, verify everything works:
node scripts/health-check.js

# Should show all checks ✓ passing
```

---

## 🛑 Troubleshooting

### "Could not establish connection"
```bash
# Make sure backend is running
curl http://localhost:3000/health

# Check FRONTEND_URL in .env matches your browser URL
```

### "CORS policy error"
```bash
# FRONTEND_URL must match browser URL exactly
# Examples:
FRONTEND_URL=http://localhost:4200       # ✅ if accessing from localhost
FRONTEND_URL=http://192.168.1.100:4200  # ✅ if accessing from other machine
```

### "Failed to fetch"
```bash
# Verify backend is running
pnpm run dev:backend

# Check port 3000 is accessible
curl http://localhost:3000/health
```

### "User is not activated"
```bash
# Remove email requirement for development:
# In .env, comment out or remove:
# RESEND_API_KEY=""
```

**For more issues, see `TROUBLESHOOTING.md`**

---

## 📁 What's Running

| Service | URL | Port | Details |
|---------|-----|------|---------|
| Frontend | http://localhost:4200 | 4200 | Next.js app |
| Backend | http://localhost:3000 | 3000 | NestJS API |
| Database | - | 5432 | PostgreSQL (docker or local) |
| Redis | - | 6379 | Redis cache (optional) |
| pgAdmin | http://localhost:8081 | 8081 | Database UI (docker) |
| RedisInsight | http://localhost:5540 | 5540 | Redis UI (docker) |

---

## 🚀 Next Steps

### Development
- Edit code in `apps/frontend/` or `apps/backend/`
- Changes auto-reload (hot reload enabled)
- Check browser console (F12) for errors

### Database
- Access pgAdmin: http://localhost:8081
- Email: admin@admin.com | Password: admin
- Add PostgreSQL connection with host: pozmixal-postgres

### Stopping Services
```bash
# Stop with Ctrl+C in the terminal

# Or if using Docker, stop services:
docker-compose -f docker-compose.dev.yaml down

# To remove data too:
docker-compose -f docker-compose.dev.yaml down -v
```

---

## 📚 Full Documentation

- **Detailed Setup**: See `SETUP.md`
- **Troubleshooting**: See `TROUBLESHOOTING.md`
- **Testing**: See `TESTING_CHECKLIST.md`
- **API Docs**: http://localhost:3000/api (when backend running)

---

## 💡 Pro Tips

### Hot Reload
Both frontend and backend support hot reload:
- Edit files → Changes appear instantly
- No server restart needed

### Database Queries
```bash
# Connect to database directly
psql -U pozmixal-local -d pozmixal-db-local

# Common queries
SELECT * FROM public."User";
SELECT email, activated FROM public."User";
UPDATE public."User" SET activated = true WHERE email = 'admin@pozmixal.local';
```

### View Logs
```bash
# Backend logs (search for errors)
pnpm run dev:backend 2>&1 | grep -i "error"

# Frontend logs in browser:
F12 → Console tab
```

### Reset Everything
```bash
# Full reset (deletes all data)
pnpm run prisma-reset
pnpm run dev
```

---

## 🎯 Common Commands

```bash
# Start all services
pnpm run dev

# Start just backend
pnpm run dev:backend

# Start just frontend
pnpm run dev:frontend

# Build for production
pnpm run build

# Run tests
pnpm test

# Generate Prisma client
pnpm run prisma-generate

# Push database schema
pnpm run prisma-db-push

# Reset database (deletes data!)
pnpm run prisma-reset

# Health check
node scripts/health-check.js
```

---

## 🐛 Debug Mode

```bash
# Enable verbose logging
NODE_ENV=development pnpm run dev:backend

# Check all environment variables
cat .env

# Verify database connection
psql "$DATABASE_URL"

# Test API endpoint
curl http://localhost:3000/auth/can-register
```

---

## ⚠️ Important Notes

1. **FRONTEND_URL** - Must match your browser URL exactly, or you'll get CORS errors
2. **JWT_SECRET** - Keep it secret, change it in production
3. **DATABASE_URL** - Make sure PostgreSQL is running
4. **Email is optional** - Comment out RESEND_API_KEY for development
5. **Redis is optional** - Will use MockRedis if not available

---

## 🎉 Success Indicators

You're done when you see:

- ✅ Frontend loads: http://localhost:4200
- ✅ Backend API responds: http://localhost:3000/health
- ✅ Can create account
- ✅ Can login
- ✅ Can see dashboard
- ✅ No CORS errors in console
- ✅ No connection errors in console
- ✅ Health check passes: `node scripts/health-check.js`

---

## 📞 Still Having Issues?

1. **See TROUBLESHOOTING.md** - Most common issues covered
2. **Run health check** - `node scripts/health-check.js`
3. **Check browser console** - F12 → Console tab
4. **Check backend logs** - Look for red error messages
5. **Verify .env** - Make sure FRONTEND_URL matches your browser URL

---

**Ready? Run `pnpm run dev` and open http://localhost:4200 in your browser! 🚀**
