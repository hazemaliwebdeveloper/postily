# 🧪 Extension Fix - Testing Checklist

## **PRE-TESTING SETUP**

- [ ] All code changes saved
- [ ] Extension rebuilt: `npm run build` (in `apps/extension`)
- [ ] Chrome browser open
- [ ] Developer tools available (F12)

---

## **PHASE 1: BUILD & DEPLOYMENT**

### Build Process
- [ ] Run `npm run build` in `apps/extension`
- [ ] No build errors appear
- [ ] `dist/` folder contains compiled files
- [ ] `dist/manifest.json` exists

### Extension Loading
- [ ] Open `chrome://extensions/`
- [ ] Enable "Developer mode"
- [ ] Click "Load unpacked"
- [ ] Select `apps/extension/dist` folder
- [ ] Extension loads successfully
- [ ] No red errors appear
- [ ] Extension icon visible in toolbar

---

## **PHASE 2: SERVICE WORKER VERIFICATION**

### Service Worker Status
- [ ] Open `chrome://extensions/`
- [ ] Find "Pozmixal" extension
- [ ] Click on "Service Worker" link
- [ ] Service Worker DevTools opens
- [ ] Console tab shows: `[Service Worker] Background script loaded and ready to accept messages`
- [ ] No errors in console
- [ ] Service Worker status: "Running"

### Manifest Check
- [ ] In `chrome://extensions` details page
- [ ] Verify permissions include: `storage`, `cookies`, `tabs`, `activeTab`
- [ ] Verify background service worker is defined
- [ ] Content scripts configured for `http://` and `https://`

---

## **PHASE 3: CONTENT SCRIPT INITIALIZATION**

### Test on Any Website
1. [ ] Visit any website (e.g., `https://www.example.com`)
2. [ ] Open Developer Console (F12 → Console)
3. [ ] Wait 2-3 seconds for content script to load
4. [ ] In Console, verify logs:
   - [ ] `[Content Script Init] Attempt 1/10`
   - [ ] `[Content Script Init] Service worker is healthy`
5. [ ] No errors like:
   - [ ] ❌ "Could not establish connection"
   - [ ] ❌ "Receiving end does not exist"
   - [ ] ❌ "Chrome runtime error"

### Content Script Console Logs
- [ ] Console shows: `[Content Script Init] Service worker is healthy`
- [ ] If cookies accessed: `[Cookie] Fetching cookie: auth (attempt 1/3)`
- [ ] If successful: `[Cookie] Successfully fetched cookie: auth`
- [ ] No repeated error messages (retries are silent unless failing)

### Service Worker Console Logs
- [ ] Open Service Worker DevTools (from `chrome://extensions`)
- [ ] Console shows health check messages
- [ ] Verify logs like:
  - [ ] `[Service Worker] Health check from content script`
  - [ ] `[Service Worker] Loading cookie: auth`
- [ ] No errors in Service Worker

---

## **PHASE 4: SPECIFIC FUNCTIONALITY TESTS**

### Cookie Retrieval Test
1. [ ] On test website, trigger cookie fetch (if extension UI available)
2. [ ] Content Script console shows: `[Cookie] Successfully fetched cookie: auth`
3. [ ] No timeout errors
4. [ ] No "Receiving end" errors

### Storage Operations Test
1. [ ] Trigger any extension storage operation
2. [ ] Content Script console shows: `[Storage] Successfully saved key: ...`
3. [ ] No connection errors

### HTTP Request Test (if applicable)
1. [ ] Trigger any HTTP request through extension
2. [ ] Service Worker console shows: `[Service Worker] Making HTTP request: ...`
3. [ ] Request completes or fails gracefully (not with connection error)

---

## **PHASE 5: ERROR SCENARIO TESTING**

### Test 1: Extension Reload During Operation
1. [ ] Load a website with extension enabled
2. [ ] Unload extension from `chrome://extensions`
3. [ ] Reload extension (click load unpacked again)
4. [ ] Reload website
5. [ ] Wait 2-3 seconds
6. [ ] ✅ Content script loads without "Receiving end" errors
7. [ ] ✅ No console errors on website

### Test 2: Service Worker Restart
1. [ ] Open Service Worker DevTools
2. [ ] Open another tab with the extension-enabled website
3. [ ] Try to trigger extension functionality
4. [ ] ✅ Retry logic engages
5. [ ] ✅ Eventually succeeds or fails gracefully

### Test 3: Rapid Consecutive Messages
1. [ ] On extension-enabled website
2. [ ] Rapidly trigger multiple extension actions (if UI allows)
3. [ ] ✅ All messages queue properly
4. [ ] ✅ No "Receiving end does not exist" errors
5. [ ] ✅ Messages process sequentially or with proper concurrency

### Test 4: Long Page Session
1. [ ] Open website with extension
2. [ ] Keep page open for 5 minutes
3. [ ] Periodically trigger extension actions
4. [ ] ✅ No connection errors
5. [ ] ✅ Service Worker continues to respond
6. [ ] ✅ No memory leaks (check DevTools Memory)

---

## **PHASE 6: CROSS-BROWSER TESTING (if applicable)**

### Chrome/Edge (Chromium-based)
- [ ] Extension loads in Chrome
- [ ] Extension works without connection errors
- [ ] Service Worker initializes properly

### Firefox (if supporting ManifestV3)
- [ ] Extension loads in Firefox
- [ ] Content script initializes
- [ ] No connection errors

---

## **PHASE 7: PRODUCTION BUILD VALIDATION**

### Production Build
1. [ ] Run: `npm run build` (not `build:dev`)
2. [ ] [ ] Build succeeds
3. [ ] [ ] Logs disabled (no `[Content Script Init]` logs in console)
4. [ ] [ ] File size reasonable (not larger than pre-fix)

### Load Production Build
1. [ ] Load production build from `dist/`
2. [ ] Extension works without connection errors
3. [ ] No console pollution with debug logs

---

## **PHASE 8: REGRESSION TESTING**

### Existing Features Still Work
- [ ] All previously working features continue to work
- [ ] No new error messages appear
- [ ] No performance degradation
- [ ] Memory usage stable

### Edge Cases
- [ ] Extension disabled and re-enabled: ✅ Works
- [ ] Multiple tabs with extension: ✅ Works
- [ ] Page reloads: ✅ Works
- [ ] Browser sleep/wake: ✅ Works
- [ ] Network interruption recovery: ✅ Works

---

## **FINAL VERIFICATION**

### Success Criteria
- [ ] ✅ "Could not establish connection" error is gone
- [ ] ✅ "Receiving end does not exist" error is gone
- [ ] ✅ Content script initializes on all pages
- [ ] ✅ All messages successfully delivered to service worker
- [ ] ✅ Service worker responds to all actions
- [ ] ✅ No performance degradation
- [ ] ✅ Graceful error handling (fails safely, not crashes)
- [ ] ✅ Debug logs helpful for troubleshooting
- [ ] ✅ All existing features continue to work

### Sign-Off
- [ ] **Developer:** Tested and verified
- [ ] **Date:** _______________
- [ ] **Notes:** _______________

---

## **TROUBLESHOOTING DURING TESTING**

### If "Receiving end does not exist" still appears:
1. [ ] Hard refresh page (Ctrl+Shift+R)
2. [ ] Clear extension data: `chrome://extensions` → Details → Clear data
3. [ ] Unload and reload extension
4. [ ] Check Service Worker console for errors
5. [ ] Verify `manifest.json` has all required permissions

### If Content Script doesn't initialize:
1. [ ] Check website console for any errors
2. [ ] Verify content script console logs appear
3. [ ] Open Service Worker DevTools and check for health check logs
4. [ ] Verify website matches `content_scripts` matches pattern in manifest

### If Service Worker crashes:
1. [ ] Check `chrome://extensions` error section
2. [ ] Review Service Worker DevTools console
3. [ ] Look for JavaScript errors in build output
4. [ ] Rebuild with `npm run build:dev` for better error messages

### If retries are happening too much:
1. [ ] Check network latency (might be legitimate)
2. [ ] Verify service worker is actually running
3. [ ] Check if there are permission issues with cookies/storage
4. [ ] Increase retry delay settings if needed

---

## **PERFORMANCE BENCHMARKS**

| Metric | Expected | Actual | Status |
|--------|----------|--------|--------|
| Extension load time | <100ms | _____ | [ ] Pass |
| Service worker init | <500ms | _____ | [ ] Pass |
| First message response | <1s | _____ | [ ] Pass |
| Subsequent messages | <50ms | _____ | [ ] Pass |
| Memory usage | <10MB | _____ | [ ] Pass |

---

## **TEST REPORT SUMMARY**

| Phase | Status | Notes |
|-------|--------|-------|
| Build & Deployment | [ ] Pass / [ ] Fail | __________ |
| Service Worker | [ ] Pass / [ ] Fail | __________ |
| Content Script Init | [ ] Pass / [ ] Fail | __________ |
| Functionality | [ ] Pass / [ ] Fail | __________ |
| Error Scenarios | [ ] Pass / [ ] Fail | __________ |
| Regression | [ ] Pass / [ ] Fail | __________ |
| Production | [ ] Pass / [ ] Fail | __________ |

**Overall Status:** [ ] ✅ PASS [ ] ❌ FAIL

**Signed Off By:** ________________  
**Date:** ________________  
**Ready for Deployment:** [ ] YES [ ] NO
