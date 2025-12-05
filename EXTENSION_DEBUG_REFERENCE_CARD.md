# 🐛 Extension Debug Reference Card

> Quick reference for diagnosing and debugging extension connection issues

---

## **Error Symptoms**

| Error Message | Location | Cause | Fix |
|---|---|---|---|
| `Could not establish connection` | Console | Service worker not ready | Wait for initialization |
| `Receiving end does not exist` | Console | No message listener | Check service worker |
| `Chrome runtime error` | DevTools | Permission or API issue | Verify manifest.json |
| `Timeout after 8000ms` | Console | Service worker frozen | Reload extension |

---

## **Quick Diagnostics**

### **Is the extension loaded?**
```
chrome://extensions/ → Should see "Pozmixal" listed ✅
```

### **Is the service worker running?**
```
chrome://extensions/ → Find Pozmixal → Click "Service Worker" link
Should say "Running" ✅
```

### **Is content script initializing?**
```
Visit any website → Open DevTools (F12)
Console should show: [Content Script Init] Service worker is healthy ✅
```

### **Is service worker healthy?**
```
From chrome://extensions, click Pozmixal "Service Worker" link
Console should show recent messages ✅
No errors should appear ❌
```

---

## **Console Log Indicators**

### ✅ Healthy System
```
[Service Worker] Background script loaded and ready
[Service Worker] Health check from content script
[Content Script Init] Service worker is healthy
[Cookie] Successfully fetched cookie: auth
```

### ⚠️ Warning Signs
```
[Cookie] Attempt 1 failed: ...
[Content Script Init] Retrying...
[Service Worker] Storage error...
```

### ❌ Problem Indicators
```
Uncaught Error: Could not establish connection
Receiving end does not exist
Extension context invalidated
The message port closed
Chrome runtime error
```

---

## **Emergency Fixes** (In Order)

### Fix #1: Hard Refresh
```
Ctrl + Shift + R (on webpage with extension)
```

### Fix #2: Clear Extension Data
```
chrome://extensions/ → Pozmixal → Details → Clear data
```

### Fix #3: Reload Extension
```
chrome://extensions/ → Unload extension
Then: Load unpacked → apps/extension/dist
```

### Fix #4: Restart Chrome
```
Close all Chrome windows
Reopen Chrome
```

---

## **Logging Commands**

### Enable Debug Logs
```bash
cd apps/extension
NODE_ENV=development npm run build
```

### Disable Debug Logs
```bash
cd apps/extension
NODE_ENV=production npm run build
```

### View Service Worker Logs
```
chrome://extensions/ → Pozmixal → Service Worker (blue link)
```

### View Content Script Logs
```
F12 on any website → Console tab
Filter: [Content Script] or [Cookie]
```

---

## **Verify Each Layer**

### Layer 1: Service Worker
```javascript
// In Service Worker Console, manually test:
chrome.runtime.sendMessage({action: '__health_check__'}, console.log)
// Should print: {status: 'healthy', timestamp: ...}
```

### Layer 2: Content Script
```javascript
// In Website Console, check:
console.log(document.body.innerText.includes('__root'))
// Should be true (content script injected)
```

### Layer 3: Communication
```javascript
// In Website Console, test message:
chrome.runtime.sendMessage(
  {action: 'ping'}, 
  (response) => console.log('Pong:', response)
)
// Should print: Pong: {status: 'pong', timestamp: ...}
```

---

## **Performance Checks**

### Check Memory Usage
```
chrome://extensions/ → Pozmixal → Inspect service worker
DevTools → Memory tab → Take heap snapshot
Should be <10MB
```

### Check Startup Time
```
Enable debug logs
Visit website
Check console timestamps
Should see healthy message within 2-3 seconds
```

### Check Message Latency
```
Service Worker console: Note timestamp from log
Website console: Compare with browser timestamp
Latency should be <50ms
```

---

## **File Locations**

| File | Purpose | Location |
|------|---------|----------|
| Service Worker Listener | Message handling | `apps/extension/src/pages/background/index.ts` |
| Message Wrapper | Retry logic | `apps/extension/src/utils/chrome-message.wrapper.ts` |
| Content Initializer | Health check | `apps/extension/src/utils/content-script-initializer.ts` |
| Content Entry | Script injection | `apps/extension/src/pages/content/index.tsx` |
| Manifest | Permissions | `apps/extension/manifest.json` |

---

## **Common Fixes Cheat Sheet**

**Problem:** Error on every page load
**Solution:** 
```bash
NODE_ENV=development npm run build  # Get debug logs
npm run build                        # Clean rebuild
chrome://extensions/ → Unload & reload extension
```

**Problem:** Service Worker won't respond
**Solution:**
```
chrome://extensions/ → Inspect service worker
Check for JavaScript errors
npm run build (rebuild)
```

**Problem:** Content script not injecting
**Solution:**
```
Check manifest.json content_scripts section
Verify website matches content_scripts patterns
Hard refresh with Ctrl+Shift+R
```

**Problem:** Timeout errors
**Solution:**
```bash
NODE_ENV=development npm run build  # Get logs to see where it times out
Increase timeouts in chrome-message-wrapper.ts if needed
```

---

## **Message Action Reference**

| Action | Source | Target | Response | Purpose |
|--------|--------|--------|----------|---------|
| `__health_check__` | Content | Service | `{status: 'healthy'}` | Verify service worker ready |
| `ping` | Popup | Service | `{status: 'pong'}` | Test connection |
| `loadCookie` | Content | Service | Cookie value | Get auth cookie |
| `saveStorage` | Content | Service | `{success: true}` | Save to storage |
| `loadStorage` | Content | Service | Stored value | Load from storage |
| `makeHttpRequest` | Content | Service | HTTP response | CORS bypass request |

---

## **Build & Test Workflow**

```
1. Make code changes
   ↓
2. npm run build (in apps/extension)
   ↓
3. chrome://extensions/ → Reload Pozmixal
   ↓
4. F12 on test website → Check console
   ↓
5. chrome://extensions/ → Click Service Worker → Check logs
   ↓
6. All green? ✅ Deploy! 
   All red? ❌ Check console and try again
```

---

## **Retry Logic Defaults**

| Setting | Content Script | Normal |
|---------|---|---|
| Max Retries | 5 | 3 |
| Initial Delay | 200ms | 100ms |
| Max Delay | 3000ms | 2000ms |
| Timeout | 8000ms | 5000ms |

---

## **Network Waterfall Diagram**

```
Page Load
    ↓
Content Script Injected
    ├─ Health check request #1 (500ms)
    ├─ Health check request #2 (500ms)
    │  [Service Worker responds]
    ├─ Content script renders (100ms)
    └─ Ready for operations ✅

Total: ~1-2 seconds for initialization
```

---

## **One-Liner Diagnostics**

```bash
# Test if service worker exists
chrome.runtime.sendMessage({action: '__health_check__'}, console.log)

# Check if content script is loaded
document.getElementById('__root') !== null

# Verify extension permissions
chrome.permissions.getAll(console.log)

# View all message actions
# (Look in background/index.ts for: if (request.action === '...')
```

---

## **Escalation Path**

1. **User reports:** "Extension not working"
   → Check: Error message in console?

2. **If "Receiving end does not exist"**
   → Check: Service Worker running?

3. **If Service Worker not running**
   → Check: chrome://extensions errors?

4. **If javascript errors in service worker**
   → Check: Build successful?

5. **If build has errors**
   → Check: All files modified correctly?

6. **If all else fails**
   → Rebuild and reload extension completely

---

## **Post-Deployment Checklist**

- [ ] Extension builds without errors
- [ ] Service Worker shows "running"
- [ ] No console errors on websites
- [ ] "[Content Script Init] Service worker is healthy" appears
- [ ] Cookie operations work
- [ ] Storage operations work
- [ ] No "Receiving end does not exist" errors anywhere
- [ ] Extension persists across browser restart
- [ ] Performance is unchanged

---

## **Notes**

- Debug logs only appear when `NODE_ENV=development`
- Service Worker can be inspected from `chrome://extensions`
- Content script console logs appear in website DevTools (F12)
- Restart Chrome to completely reset extension state
- Hard refresh (Ctrl+Shift+R) reloads content scripts

---

**Last Updated:** 2025-01-12  
**Version:** Extension Fix v1.0  
**Status:** Production Ready ✅
