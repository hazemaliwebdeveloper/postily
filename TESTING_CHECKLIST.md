# Pozmixal - Complete Local Testing Checklist

## 🎯 Pre-Flight Checklist

Before running any tests, verify all prerequisites are met:

- [ ] Node.js v22 installed: `node --version`
- [ ] pnpm v10.6.1+ installed: `pnpm --version`
- [ ] PostgreSQL 15+ running and accessible
- [ ] Redis 7+ running (or will use MockRedis)
- [ ] `.env` file created from `.env.local` template
- [ ] All critical env vars set:
  - [ ] DATABASE_URL
  - [ ] FRONTEND_URL (matches browser URL)
  - [ ] NEXT_PUBLIC_BACKEND_URL
  - [ ] JWT_SECRET
- [ ] No other services running on ports 3000, 4200, 5432, 6379, 8081, 5540

---

## 🚀 Setup Verification Tests

### Test 1: Dependencies Installation
```bash
# Clear cache
pnpm install --no-frozen-lockfile

# Status: ✅ PASS if no errors
```

**Expected:**
- All packages install successfully
- No version conflicts
- `postinstall` script runs (generates Prisma client)

**If fails:**
- [ ] Check Node.js version: `node --version` (should be 22.x)
- [ ] Check disk space (need 5GB+)
- [ ] Clear cache: `pnpm install --no-frozen-lockfile`
- [ ] Delete node_modules and try again: `rm -rf node_modules && pnpm install`

---

### Test 2: Database Connection
```bash
# Verify PostgreSQL is running
psql --version

# Connect to database
psql -U pozmixal-local -d pozmixal-db-local -c "SELECT version();"

# Status: ✅ PASS if returns PostgreSQL version
```

**Expected:**
- Returns PostgreSQL version info
- No connection errors

**If fails:**
- [ ] Start PostgreSQL service
- [ ] Verify credentials in DATABASE_URL
- [ ] Create database if missing: `createdb -U pozmixal-local pozmixal-db-local`

---

### Test 3: Prisma Schema Push
```bash
pnpm run prisma-generate
pnpm run prisma-db-push

# Status: ✅ PASS if no errors
```

**Expected:**
- Schema synchronized successfully
- All tables created

**If fails:**
- [ ] Reset database: `pnpm run prisma-reset`
- [ ] Check DATABASE_URL format
- [ ] Verify PostgreSQL is running

---

### Test 4: Environment Variables
```bash
# Verify critical env vars are set
echo "FRONTEND_URL: $FRONTEND_URL"
echo "NEXT_PUBLIC_BACKEND_URL: $NEXT_PUBLIC_BACKEND_URL"
echo "DATABASE_URL: $DATABASE_URL"
echo "JWT_SECRET: ${JWT_SECRET:0:10}..." (first 10 chars)

# Status: ✅ PASS if all variables are printed
```

**Expected:**
- All critical variables have values
- URLs don't have trailing slashes
- JWT_SECRET has minimum 32 characters

**If fails:**
- [ ] Load .env: `set -a; source .env; set +a` (Linux/macOS)
- [ ] Load .env: `dir .env` (Windows - verify file exists)
- [ ] Edit .env and add missing variables

---

## 🔧 Application Startup Tests

### Test 5: Backend Startup
```bash
# Terminal 1
pnpm run dev:backend

# Status: ✅ PASS after ~10 seconds when you see:
# "🚀 Backend is running on: http://localhost:3000"
```

**Expected:**
- No errors in console
- Backend listens on port 3000
- Database connected successfully
- Redis connection (or MockRedis fallback)

**Checklist:**
- [ ] Backend starts without errors
- [ ] Database connection successful
- [ ] No CORS warnings
- [ ] Logs show "Backend is running"

**If fails:**
- [ ] Check DATABASE_URL: `echo $DATABASE_URL`
- [ ] Verify PostgreSQL is running
- [ ] Check port 3000 is free: `lsof -i :3000` (macOS/Linux) or `netstat -ano | findstr :3000` (Windows)
- [ ] Check backend logs for specific errors

---

### Test 6: Frontend Startup
```bash
# Terminal 2
pnpm run dev:frontend

# Status: ✅ PASS after ~20 seconds when you see:
# "- ready started server on 0.0.0.0:4200, url: http://localhost:4200"
```

**Expected:**
- No errors in console
- Frontend listens on port 4200
- Compilation successful
- Hot reload enabled

**Checklist:**
- [ ] Frontend starts without errors
- [ ] No TypeScript errors
- [ ] Port 4200 is accessible
- [ ] Logs show "ready started server"

**If fails:**
- [ ] Clear Next.js cache: `rm -rf apps/frontend/.next`
- [ ] Check port 4200 is free: `lsof -i :4200`
- [ ] Check NEXT_PUBLIC_BACKEND_URL is set
- [ ] Rebuild: `pnpm run build:frontend`

---

### Test 7: Health Check Script
```bash
# Terminal 3
node scripts/health-check.js

# Status: ✅ PASS if all checks pass
```

**Expected:**
- All environment variables present
- Backend responding
- Database connected
- Redis connected (or MockRedis)
- CORS configured correctly

**Checklist:**
- [ ] All checks show ✓ (green)
- [ ] Backend responding (HTTP 200 or 404)
- [ ] Database connection successful
- [ ] Redis or MockRedis active

**If fails:**
- [ ] Run individual checks manually
- [ ] See TROUBLESHOOTING.md for specific error

---

## 🌐 Frontend Accessibility Tests

### Test 8: Frontend Loads
```bash
# Open in browser
http://localhost:4200

# Status: ✅ PASS if page loads without errors
```

**Expected:**
- Page loads completely (no 404 or errors)
- Logo and branding visible
- All text readable
- No console errors

**Browser Console (F12 → Console tab):**
- [ ] No red error messages
- [ ] No CORS errors
- [ ] No "[POZMIXAL]" error messages

---

### Test 9: Authentication Page Loads
```bash
# Navigate to
http://localhost:4200/auth

# Status: ✅ PASS if sign-in page loads
```

**Expected:**
- Sign-in/Sign-up page loads
- Form fields visible
- "Sign Up" link visible
- No network errors

**Checklist:**
- [ ] Page loads completely
- [ ] Email input field visible
- [ ] Password input field visible
- [ ] Sign In button visible
- [ ] "Sign Up" link visible
- [ ] No red error messages in console

---

### Test 10: Network Connectivity Check
```bash
# Open DevTools
F12 → Network tab

# Refresh page
Ctrl+R (or Cmd+R)

# Status: ✅ PASS if no failed requests
```

**Expected:**
- All requests show green (200)
- No requests to backend fail
- No CORS errors
- Response times reasonable (<500ms)

**What to look for:**
- [ ] No red (failed) requests
- [ ] No 404 errors
- [ ] No CORS messages
- [ ] API requests show 200-201 status
- [ ] No "Failed to fetch" errors

**If CORS errors appear:**
- [ ] Check FRONTEND_URL in .env matches browser URL exactly
- [ ] Restart backend
- [ ] Check backend logs for CORS warnings

---

## 🔐 Authentication Flow Tests

### Test 11: User Registration
```bash
# On http://localhost:4200/auth

1. Click "Sign Up"
2. Enter:
   - Email: testuser@pozmixal.local
   - Password: TestPassword123!
3. Click "Sign Up"

# Status: ✅ PASS if redirects to dashboard or shows success
```

**Expected:**
- Registration succeeds
- Redirects to dashboard or shows activation message
- User created in database
- No CORS or connection errors

**Browser Console:**
- [ ] No red errors
- [ ] No "[POZMIXAL]" error messages
- [ ] Should see "[POZMIXAL] Login successful" or similar

**Database Check (Optional):**
```bash
psql -U pozmixal-local -d pozmixal-db-local
SELECT * FROM public."User" WHERE email = 'testuser@pozmixal.local';
\q
```
- [ ] User record exists
- [ ] Email matches
- [ ] Password is hashed (not plain text)

**If registration fails:**
- [ ] Check browser console for error message
- [ ] Verify backend is running: `curl http://localhost:3000/health`
- [ ] Check backend logs for registration errors
- [ ] Verify DATABASE_URL is correct
- [ ] See TROUBLESHOOTING.md for specific error

---

### Test 12: User Login
```bash
# On http://localhost:4200/auth (Sign In tab)

1. Enter:
   - Email: testuser@pozmixal.local
   - Password: TestPassword123!
2. Click "Sign In"

# Status: ✅ PASS if redirects to dashboard
```

**Expected:**
- Login succeeds
- Redirects to main dashboard
- User is authenticated
- Session maintained

**Checklist:**
- [ ] Redirects to `/launches` or `/analytics`
- [ ] Dashboard loads
- [ ] User name/avatar visible
- [ ] No error messages
- [ ] Browser console clean

**Database Check:**
```bash
# List recent sessions (if applicable)
psql -U pozmixal-local -d pozmixal-db-local -c "SELECT email, activated FROM public.\"User\" WHERE email = 'testuser@pozmixal.local';"
```
- [ ] User record shows activated=true
- [ ] Login attempt time is recent

**If login fails:**
- [ ] Verify registration succeeded (check Test 11)
- [ ] Check password is correct (case-sensitive)
- [ ] If "User is not activated", see TROUBLESHOOTING.md
- [ ] Check backend logs: `pnpm run dev:backend 2>&1 | grep -i error`

---

### Test 13: Authentication Cookie Handling
```bash
# Open DevTools
F12 → Application tab → Cookies

# After successful login, check:
```

**Expected:**
- [ ] Cookie named "auth" exists
- [ ] Cookie has secure flag (if HTTPS)
- [ ] Cookie has httpOnly flag
- [ ] Cookie has appropriate expiry
- [ ] Cookie domain is correct

**If cookies not present:**
- [ ] Check FRONTEND_URL is correct
- [ ] Verify backend is setting cookies (see backend logs)
- [ ] Check browser cookie settings

---

### Test 14: Session Persistence
```bash
# After successful login:

1. Refresh page
   Ctrl+R (or Cmd+R)

2. Verify still logged in

# Status: ✅ PASS if session persists after refresh
```

**Expected:**
- Page refreshes
- User remains logged in
- Dashboard loads
- No redirect to login

**Checklist:**
- [ ] After refresh, still on dashboard
- [ ] User data loads
- [ ] No re-login required
- [ ] Browser shows no errors

**If session lost:**
- [ ] Check cookie is being set (Test 13)
- [ ] Check backend middleware logs
- [ ] Verify JWT_SECRET is consistent
- [ ] See TROUBLESHOOTING.md

---

## 🌐 API Endpoint Tests

### Test 15: Backend Health Check
```bash
curl -i http://localhost:3000/health

# Status: ✅ PASS if returns 200 OK
```

**Expected:**
- HTTP Status: 200 OK or 404 (endpoint exists)
- Response is JSON
- No connection timeout

---

### Test 16: User Registration API
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "apitest@pozmixal.local",
    "password": "ApiTestPassword123!",
    "provider": "LOCAL"
  }'

# Status: ✅ PASS if returns 200 or 400 (not 500)
```

**Expected:**
- HTTP Status: 200 (success) or 400 (validation error)
- Response is JSON
- No 500 errors

**If 500 error:**
- [ ] Check backend logs
- [ ] Verify DATABASE_URL
- [ ] Verify PostgreSQL is running

---

### Test 17: User Login API
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@pozmixal.local",
    "password": "TestPassword123!",
    "provider": "LOCAL"
  }'

# Status: ✅ PASS if returns auth token
```

**Expected:**
- HTTP Status: 200 OK
- Response includes auth token or cookie header
- Response headers include Set-Cookie (if cookie-based)

**If 401 error:**
- [ ] Verify user exists and password is correct
- [ ] Check user is activated

---

### Test 18: Protected API Endpoint
```bash
# Get auth token from login response
TOKEN="your-token-here"

# Test protected endpoint
curl -i -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/user

# Status: ✅ PASS if returns 200 with user data
```

**Expected:**
- HTTP Status: 200 OK
- Response includes user data
- No 401 Unauthorized

**If 401 Unauthorized:**
- [ ] Verify token is valid
- [ ] Check Authorization header format
- [ ] Verify JWT_SECRET is correct

---

## 💾 Database Tests

### Test 19: Database Schema Verification
```bash
psql -U pozmixal-local -d pozmixal-db-local \
  -c "\dt public.*" | head -20

# Status: ✅ PASS if lists tables
```

**Expected:**
- Lists multiple tables (User, Organization, Post, etc.)
- All tables exist
- No errors

**Critical tables to check:**
- [ ] public."User"
- [ ] public."Organization"
- [ ] public."Post"
- [ ] public."Integration"

---

### Test 20: Sample Data Verification
```bash
# Count users
psql -U pozmixal-local -d pozmixal-db-local \
  -c "SELECT COUNT(*) FROM public.\"User\";"

# List users
psql -U pozmixal-local -d pozmixal-db-local \
  -c "SELECT email, activated FROM public.\"User\" LIMIT 5;"

# Status: ✅ PASS if returns user records
```

**Expected:**
- At least 1 user record (the one created in Test 11)
- User email matches
- Activated status is true

---

## 🔄 Feature Flow Tests

### Test 21: Complete Login-to-Dashboard Flow
```bash
# 1. Open frontend
http://localhost:4200

# 2. See homepage/landing

# 3. Click Sign In

# 4. Enter credentials

# 5. Click Sign In

# 6. See dashboard

# Status: ✅ PASS if reaches dashboard without errors
```

**Expected:**
- Smooth flow from homepage → login → dashboard
- No CORS errors
- No connection errors
- No console errors
- Page loads under 5 seconds

---

### Test 22: Navigation Test
```bash
# After logged in:

1. Try different menu items
2. Navigate to different pages
3. Go back to main dashboard

# Status: ✅ PASS if navigation works smoothly
```

**Expected:**
- All links work
- Pages load quickly
- No 404 errors
- No broken images

---

### Test 23: Logout Flow
```bash
# On dashboard:

1. Click user profile/settings (if available)
2. Click logout
3. Should redirect to login page

# Status: ✅ PASS if logged out and redirected
```

**Expected:**
- Logout succeeds
- Redirected to login page
- Cannot access protected pages
- Session cleared

**Verification:**
- [ ] Trying to access dashboard redirects to login
- [ ] Cookies cleared (check DevTools)

---

## 🛠️ Error Handling Tests

### Test 24: Invalid Login Credentials
```bash
# On login page:

1. Enter: wrong@email.com, WrongPassword123!
2. Click Sign In

# Status: ✅ PASS if shows appropriate error message
```

**Expected:**
- Shows error message
- Does not log in
- Error message is clear
- No 500 errors in backend

---

### Test 25: Network Error Handling
```bash
# With backend running:

1. Open DevTools
2. Go to Network tab
3. Throttle to "Slow 3G" (if available)
4. Try to login

# Status: ✅ PASS if handles slow network gracefully
```

**Expected:**
- Page still responds
- Shows loading indicator
- Eventually succeeds or shows timeout error
- No application crash

---

### Test 26: Backend Unavailable Error
```bash
# With frontend running:

1. Stop backend
2. Try to login on frontend

# Status: ✅ PASS if shows appropriate error message
```

**Expected:**
- Shows "Connection failed" or similar message
- Does not crash frontend
- Suggests troubleshooting steps (if implemented)
- Clear error message

---

## 📊 Performance Tests

### Test 27: Page Load Time
```bash
# Open DevTools
F12 → Performance tab

# Load page and measure:
```

**Targets:**
- [ ] Homepage load: < 3 seconds
- [ ] Dashboard load: < 2 seconds
- [ ] API response: < 500ms

---

### Test 28: Memory Usage
```bash
# Open DevTools
F12 → Memory/Performance tab

# Observe memory usage during normal use:
```

**Targets:**
- [ ] Frontend: < 100MB
- [ ] Backend: < 200MB

---

## 🔐 Security Tests

### Test 29: Password Not Visible
```bash
# On registration/login page:

1. Type in password field
2. Verify characters show as dots/asterisks
3. Inspect HTML element

# Status: ✅ PASS if password is masked
```

**Expected:**
- Password always shown as dots (●●●●)
- View source doesn't show plain text password
- No console logs contain password

---

### Test 30: HTTPS Warnings (if applicable)
```bash
# Check DevTools console:
```

**Expected:**
- [ ] No "mixed content" warnings
- [ ] No certificate errors (on production)
- [ ] No security warnings

---

## 🎉 Final Integration Test

### Test 31: Complete User Journey

**Follow this complete workflow:**

```
1. ✅ Start all services
   - PostgreSQL running
   - Redis running (or MockRedis)
   - Backend running
   - Frontend running

2. ✅ Open frontend
   - http://localhost:4200
   - Page loads without errors

3. ✅ Create new account
   - Click "Sign Up"
   - Enter: newtester@pozmixal.local / NewPassword123!
   - Verify success

4. ✅ Login with new account
   - Go to login page
   - Enter credentials
   - Login succeeds
   - Dashboard appears

5. ✅ Verify session
   - Refresh page
   - Still logged in
   - No redirect to login

6. ✅ Logout
   - Click logout
   - Redirected to login page
   - Cannot access dashboard

7. ✅ Login again
   - Verify login still works
   - Dashboard appears

8. ✅ Check database
   - User record exists
   - User marked as activated
   - No errors

9. ✅ Verify no console errors
   - Open DevTools (F12)
   - Check Console tab
   - No red errors
   - No CORS warnings
   - No connection errors

10. ✅ Run health check
    - node scripts/health-check.js
    - All checks pass
```

**Status: ✅ PASS if all 10 steps complete successfully**

---

## 🐛 Debugging Command Reference

### Common Issues & Quick Fixes

**Backend won't start:**
```bash
# Check logs
pnpm run dev:backend 2>&1 | grep -i error

# Check port
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Restart database
docker-compose -f docker-compose.dev.yaml restart pozmixal-postgres
```

**Frontend won't start:**
```bash
# Clear cache
rm -rf apps/frontend/.next

# Check port
lsof -i :4200  # macOS/Linux
netstat -ano | findstr :4200  # Windows

# Rebuild
pnpm run build:frontend
```

**CORS errors:**
```bash
# Verify FRONTEND_URL
echo $FRONTEND_URL  # Should match browser URL exactly

# Restart backend
pnpm run dev:backend
```

**Connection errors:**
```bash
# Test backend
curl http://localhost:3000/health

# Test database
psql -U pozmixal-local -d pozmixal-db-local -c "SELECT 1;"

# Test Redis
redis-cli ping
```

---

## 📋 Final Checklist

Before considering tests complete, verify:

- [ ] All 31 tests pass
- [ ] No CORS errors
- [ ] No connection errors
- [ ] No console errors
- [ ] Login/logout works smoothly
- [ ] Database correctly populated
- [ ] Session persists across refreshes
- [ ] All pages load under 3 seconds
- [ ] Health check script passes all items
- [ ] Application is ready for development

---

## 🎯 Next Steps

Once all tests pass:

1. **Start development**
   - Begin implementing features
   - Use hot reload for quick iteration
   - Commit code regularly

2. **Monitor logs**
   - Keep backend logs visible
   - Watch for errors
   - Check database queries

3. **Test frequently**
   - Test after each major change
   - Use automated testing
   - Check browser console regularly

4. **Document issues**
   - If tests fail, document the error
   - Reference TROUBLESHOOTING.md
   - Share findings with team

---

**All tests passing? 🎉 Your Pozmixal application is ready for development!**

For issues, see **TROUBLESHOOTING.md** or **SETUP.md**.
