# 🐛 Chrome Extension Debugging Guide

## Common Issues & Solutions

### Issue 1: "Could not establish connection. Receiving end does not exist"

**What it means**: Extension popup can't communicate with the service worker

**Fix** (Already Implemented):
- ✅ Retry logic with exponential backoff (3-5 attempts)
- ✅ Service worker readiness detection
- ✅ Timeout protection (5 seconds)
- ✅ Automatic error recovery

**Manual Steps**:
1. Go to `chrome://extensions`
2. Find Postiz extension
3. Click the reload icon 🔄
4. Wait 2-3 seconds
5. Click the extension popup again

---

### Issue 2: Popup Shows "Initializing extension..."

**What it means**: Service worker is starting up (normal behavior)

**Solution**: Wait 2-3 seconds for initialization to complete

**If it doesn't complete**:
1. Check Service Worker logs:
   - chrome://extensions → Postiz → "Service Worker" link
   - Look for error messages
2. Reload the extension (click reload icon)
3. Try popup again

---

### Issue 3: Extension Popup Shows Blank

**What it means**: Service worker crashed or plugin not found

**Debug Steps**:
1. Open Extension DevTools:
   ```
   chrome://extensions → Postiz → "Service Worker" link
   ```
2. Look at the Console tab
3. Check for errors like:
   - `Manifest error`
   - `Failed to load resource`
   - Network errors

**Solutions**:

If you see `Manifest error`:
```powershell
# Rebuild the extension
pnpm --filter ./apps/extension run build:chrome

# Reload in Chrome (chrome://extensions → Postiz → reload icon)
```

If you see network errors:
```powershell
# Ensure backend is running
pnpm --filter ./apps/backend run dev

# Check backend health
curl http://localhost:3000/health
```

---

### Issue 4: Service Worker Crashes Repeatedly

**What it means**: There's an unhandled error in the background script

**Debug Steps**:
1. chrome://extensions → Postiz → "Service Worker"
2. Look at Console for errors
3. Look at the error messages

**Common Errors**:

#### Error: `Cannot find module '@gitroom/...'`
```powershell
# Solution: Rebuild
pnpm install
pnpm --filter ./apps/extension run build:chrome
```

#### Error: `chrome.storage is undefined`
```powershell
# Solution: Manifest.json missing "storage" permission
# Check: apps/extension/dist/manifest.json has "storage" in permissions
```

#### Error: `Uncaught (in promise) TypeError: ...`
```powershell
# Solution: Check the full error message and fix the issue
# If related to Prisma/database, restart backend
```

---

### Issue 5: Storage Operations Fail

**What it means**: Can't save/load data from extension storage

**Debug Steps**:
1. Open popup
2. Open popup DevTools (right-click → Inspect)
3. Look for messages:
   ```
   [Storage] Failed to fetch storage key: auth
   ```

**Solutions**:

Check if storage permissions are in manifest.json:
```json
{
  "permissions": [
    "storage",  // ← Must be here
    "cookies",
    "tabs",
    "activeTab"
  ]
}
```

If not there:
```powershell
pnpm --filter ./apps/extension run build:chrome
# Then reload extension in Chrome
```

---

### Issue 6: Cookie Not Loading

**Error**: "Auth cookie not found"

**Debug Steps**:
1. Open popup, wait for initialization
2. Open popup DevTools
3. Check for:
   ```
   [Cookie] Fetching cookie: auth
   [Cookie] Successfully fetched cookie: auth
   ```

**Solutions**:

#### If you see: `[Cookie] Failed to fetch cookie after all retries: auth`

Check if you're logged in:
1. Visit `http://localhost:4200`
2. Check if there's an `auth` cookie
   - Press F12 → Application → Cookies → http://localhost:4200
   - Look for cookie named `auth`

If no `auth` cookie:
1. Login to the application
2. Then try the extension popup again

---

### Issue 7: HTTP Requests Fail

**Error**: "Failed to send request"

**Debug Steps**:
1. Open popup DevTools
2. Look for:
   ```
   [Request] Sending request: { url: '...', method: 'GET' }
   [Request] Request successful: ...
   ```

**Solutions**:

#### If you see: `Failed to establish connection after X attempts`

Check backend:
```powershell
# Is backend running?
curl http://localhost:3000/health

# If not, start it:
pnpm --filter ./apps/backend run dev
```

#### If you see: `HTTP 401: Unauthorized`

Check authentication:
1. Ensure you're logged in to frontend (`http://localhost:4200`)
2. Check if `auth` cookie exists and is valid
3. Try logging out and back in

---

## How to Enable Detailed Logging

The extension includes detailed logging in development mode.

### 1. Check if Development Mode is Enabled

Build the extension with dev flag:
```powershell
# Current .env has NODE_ENV=development by default
# Extension logs automatically appear in Service Worker console
```

### 2. View Logs

Go to: `chrome://extensions → Postiz → Service Worker`

You should see messages like:
```
[Service Worker] Background script loaded and ready to accept messages
[Service Worker] Received ping from http://localhost:4200
[Service Worker] Storage loaded: auth = [token]
[Service Worker] HTTP request successful: http://localhost:3000/api/...
[Storage] Saving key: myKey = myValue (attempt 1/3)
[Cookie] Fetching cookie: auth (attempt 1/3)
[Request] Sending request: { url: '/api/users', method: 'GET' }
```

### 3. Filter Logs

In the Console, you can filter:
```javascript
// Copy and paste in console to filter logs
console.log = ((f) => function(...args) { 
  if (args[0]?.includes?.('[')) return; // Hide [prefixed logs
  return f.apply(console, args);
})(console.log);
```

---

## Performance Metrics

Expected performance (from testing):

| Scenario | Expected Time | Status |
|----------|----------------|--------|
| Cold start (1st popup click) | 200-300ms | ✅ With visible feedback |
| Subsequent loads (cached) | 50-100ms | ✅ Fast |
| After service worker crash | 200-400ms | ✅ Auto-recovery |
| With 2 retries needed | 300-500ms | ✅ Auto-retries |
| Max timeout (error state) | 5000ms | ⚠️ If this occurs, service worker unavailable |

If times exceed these, check:
1. Backend performance (`curl http://localhost:3000/health`)
2. Database performance
3. Network latency

---

## Files to Check

When debugging, check these files:

| File | Purpose | Key Messages |
|------|---------|--------------|
| `apps/extension/src/utils/chrome-message.wrapper.ts` | Retry logic & communication | `Failed to establish connection after X attempts` |
| `apps/extension/src/pages/background/index.ts` | Service worker handler | `[Service Worker]` messages |
| `apps/extension/src/utils/load.cookie.ts` | Cookie loading | `[Cookie]` messages |
| `apps/extension/src/utils/load.storage.ts` | Storage operations | `[Storage]` messages |
| `apps/extension/src/utils/request.util.ts` | HTTP requests | `[Request]` messages |
| `apps/extension/src/pages/popup/Popup.tsx` | Popup UI | Initialization status |

---

## Rebuild & Reload Checklist

When things aren't working:

```powershell
# 1. Rebuild extension
pnpm --filter ./apps/extension run build:chrome

# 2. Reload in Chrome
# Go to chrome://extensions → Postiz → Click reload icon 🔄

# 3. Clear popup cache
# Close all Chrome windows (or use Incognito mode)
# Reopen Chrome, go to chrome://extensions

# 4. Try popup again
# Click extension icon

# 5. Check logs
# chrome://extensions → Postiz → Service Worker → Look at Console
```

---

## Emergency: Full Extension Reset

If extension is completely broken:

```powershell
# 1. Remove extension from Chrome
chrome://extensions → Postiz → Remove (trash icon)

# 2. Delete build files
rmdir /s "apps/extension/dist"

# 3. Rebuild
pnpm --filter ./apps/extension run build:chrome

# 4. Reload in Chrome
# chrome://extensions → Load unpacked → Select apps/extension/dist

# 5. Test
# Click extension popup
```

---

## Getting Help

If you still have issues:

1. **Check DevTools**:
   - Browser console (F12 → Console)
   - Service Worker console (chrome://extensions → Postiz → Service Worker)

2. **Check logs**:
   - Backend logs (Terminal running backend)
   - Database logs (PostgreSQL)
   - Redis logs

3. **Verify setup**:
   - Backend running? `curl http://localhost:3000/health`
   - Frontend running? `http://localhost:4200`
   - Database connected? Check `.env` credentials
   - Redis running? `redis-cli ping` → should return PONG

4. **Share**:
   - Service Worker console output
   - Browser console errors
   - Error messages from backend logs
