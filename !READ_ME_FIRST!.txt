╔════════════════════════════════════════════╗
║  POSTIZ - CONNECTION REFUSED FIX            ║
║  READ THIS FIRST                            ║
╚════════════════════════════════════════════╝

PROBLEM: localhost refused to connect
ERROR: ERR_CONNECTION_REFUSED on port 4200

SOLUTION: Double-click this file

═════════════════════════════════════════════

OPTION 1: EASIEST - One Click (Recommended)

  1. Find this file in project folder:
     REAL_RUN.bat

  2. Double-click it

  3. Wait for 3 windows to open:
     - BACKEND window
     - FRONTEND window  
     - EXTENSION window

  4. Wait 20-30 seconds for messages like:
     Backend:  "🚀 Backend is running on: http://localhost:3000"
     Frontend: "✓ Ready in 12.5s"

  5. Open browser: http://localhost:4200

  6. You should see POSTIZ LOGIN PAGE ✅

═════════════════════════════════════════════

OPTION 2: MANUAL - If Script Doesn't Work

  1. Open Command Prompt (Win + R → cmd → Enter)

  2. Copy and paste this:
     cd c:\Users\it\Downloads\pozmixal\postily

  3. Run command:
     pnpm install

  4. Wait for completion (2-3 minutes)

  5. Run command:
     pnpm run prisma-db-push

  6. Open THREE separate Command Prompts (Ctrl+N or Win+R → cmd 3 times)

  In Command Prompt 1:
     cd c:\Users\it\Downloads\pozmixal\postily\apps\backend
     pnpm run dev

  In Command Prompt 2:
     cd c:\Users\it\Downloads\pozmixal\postily\apps\frontend
     pnpm run dev

  In Command Prompt 3:
     cd c:\Users\it\Downloads\pozmixal\postily\apps\extension
     pnpm run dev:chrome

  7. WAIT until you see:
     Backend:  "🚀 Backend is running on: http://localhost:3000"
     Frontend: "✓ Ready in X seconds"

  8. Open browser: http://localhost:4200

  9. See login page ✅

═════════════════════════════════════════════

CRITICAL RULES

⚠️ DO NOT CLOSE ANY COMMAND WINDOWS
   (Closing them stops the services)

⚠️ DO NOT TRY TO ACCESS BROWSER TOO EARLY
   (Must wait for "Ready" message first)

⚠️ DO NOT USE ONE WINDOW FOR ALL SERVICES
   (They need separate windows to run properly)

⚠️ DO NOT PANIC IF FIRST COMPILE IS SLOW
   (Backend takes 10-20 seconds, frontend takes 15-20 seconds)

═════════════════════════════════════════════

WHAT YOU SHOULD SEE

✅ Backend window shows:
   [2:57:20 PM] Starting compilation...
   (waits 10-20 seconds)
   ✅ CORS configured...
   🚀 Backend is running on: http://localhost:3000

✅ Frontend window shows:
   ▲ Next.js 15.5.7
   - Local: http://localhost:4200
   (waits 15-20 seconds)
   ✓ Ready in 12.5s

✅ Browser shows:
   Postiz login page (or signup page)

═════════════════════════════════════════════

IF STILL NOT WORKING

1. Check backend window for "🚀 Backend is running"
   If not there, backend has an error
   → Scroll up and look for ERROR message
   → Most common: Database not running
      Solution: Start PostgreSQL

2. Check frontend window for "✓ Ready in X seconds"
   If not there, frontend compilation failed
   → Look for ERROR message
   → Scroll up to see full error

3. Make sure port 4200 is not used by something else
   Open Command Prompt and type:
   netstat -ano | findstr :4200
   
   If it shows something with port 4200:
   taskkill /PID [that number] /F

4. Make sure PostgreSQL is running
   Windows: Services → PostgreSQL → Running
   Or: psql -U pozmixal-local -d pozmixal-db-local -c "SELECT 1"

5. Make sure Redis is running
   Or: docker run -d -p 6379:6379 redis:latest

═════════════════════════════════════════════

QUICK CHECKLIST

□ Double-clicked REAL_RUN.bat or ran manual commands
□ Three windows opened (backend, frontend, extension)
□ Waited 20-30 seconds for startup
□ Saw "🚀 Backend is running" message
□ Saw "✓ Ready in X seconds" message
□ Opened http://localhost:4200 in browser
□ See Postiz login page
✅ SUCCESS!

═════════════════════════════════════════════

FILES IN THIS FOLDER

REAL_RUN.bat ................. USE THIS (easiest)
SOLVE_CONNECTION_REFUSED.md .. Detailed troubleshooting
RUN_BACKEND.bat .............. Start backend only
RUN_FRONTEND.bat ............. Start frontend only
STEP_BY_STEP.md .............. Manual commands guide
START_HERE.md ................ Complete documentation

═════════════════════════════════════════════

NEXT: Load Extension in Chrome

After frontend loads:

1. Open Chrome
2. Type: chrome://extensions
3. Toggle "Developer mode" ON
4. Click "Load unpacked"
5. Select folder: apps\extension\dist
6. Click "Open"
7. Extension appears in your Chrome toolbar

═════════════════════════════════════════════

Need help? Read SOLVE_CONNECTION_REFUSED.md

It has complete troubleshooting for:
- Port already in use
- Database errors
- Services not starting
- And more

═════════════════════════════════════════════

LET'S GO! 🚀

Run REAL_RUN.bat now!
