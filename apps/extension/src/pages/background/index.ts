import { fetchRequestUtil } from '@gitroom/extension/utils/request.util';

const isDevelopment = process.env.NODE_ENV === 'development';

/**
 * SERVICE WORKER MESSAGE LISTENER
 * 
 * This listener handles all communication from content scripts, popups, and options pages.
 * CRITICAL: This MUST be registered synchronously before any messages are sent.
 * 
 * Features:
 * - Proper async handling with return true for async operations
 * - Comprehensive error handling and logging
 * - Support for multiple action types (HTTP requests, storage, cookies)
 */

if (isDevelopment) {
  console.log('[Service Worker] Background script loaded and ready to accept messages');
}

// Register message listener immediately
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  try {
    // Ping action - used to verify service worker is running
    if (request.action === 'ping') {
      if (isDevelopment) {
        console.log('[Service Worker] Received ping from', sender.url);
      }
      sendResponse({ status: 'pong', timestamp: Date.now() });
      return true;
    }

    // HTTP Request action
    if (request.action === 'makeHttpRequest') {
      if (isDevelopment) {
        console.log('[Service Worker] Making HTTP request:', { url: request.url, method: request.method });
      }

      fetchRequestUtil(request)
        .then((response) => {
          if (isDevelopment) {
            console.log('[Service Worker] HTTP request successful:', request.url);
          }
          sendResponse(response);
        })
        .catch((error) => {
          console.error('[Service Worker] HTTP request failed:', error);
          sendResponse({ error: error.message });
        });

      return true; // Required for async response
    }

    // Load Storage action
    if (request.action === 'loadStorage') {
      if (isDevelopment) {
        console.log('[Service Worker] Loading storage key:', request.key);
      }

      chrome.storage.local.get([request.key], function (storage) {
        if (chrome.runtime.lastError) {
          console.error('[Service Worker] Storage error:', chrome.runtime.lastError);
          sendResponse({ error: chrome.runtime.lastError.message });
          return;
        }

        if (isDevelopment) {
          console.log('[Service Worker] Storage loaded:', request.key, '=', storage[request.key]);
        }

        sendResponse(storage[request.key]);
      });

      return true; // Required for async response
    }

    // Save Storage action
    if (request.action === 'saveStorage') {
      if (isDevelopment) {
        console.log('[Service Worker] Saving storage:', request.key, '=', request.value);
      }

      chrome.storage.local.set({ [request.key]: request.value }, function () {
        if (chrome.runtime.lastError) {
          console.error('[Service Worker] Storage save error:', chrome.runtime.lastError);
          sendResponse({ error: chrome.runtime.lastError.message, success: false });
          return;
        }

        if (isDevelopment) {
          console.log('[Service Worker] Storage saved successfully:', request.key);
        }

        sendResponse({ success: true });
      });

      return true; // Required for async response
    }

    // Load Cookie action
    if (request.action === 'loadCookie') {
      if (isDevelopment) {
        console.log('[Service Worker] Loading cookie:', request.cookieName);
      }

      const cookieUrl = import.meta.env?.FRONTEND_URL || process?.env?.FRONTEND_URL || 'http://localhost:4200';

      chrome.cookies.get(
        {
          url: cookieUrl,
          name: request.cookieName,
        },
        function (cookie) {
          if (chrome.runtime.lastError) {
            console.error('[Service Worker] Cookie error:', chrome.runtime.lastError);
            sendResponse({ error: chrome.runtime.lastError.message });
            return;
          }

          if (isDevelopment) {
            console.log('[Service Worker] Cookie loaded:', request.cookieName, '=', !!cookie?.value);
          }

          sendResponse(cookie?.value);
        }
      );

      return true; // Required for async response
    }

    // Unknown action - log warning but don't crash
    console.warn('[Service Worker] Unknown action received:', request.action);
    sendResponse({ error: `Unknown action: ${request.action}` });
    return true;
  } catch (error) {
    console.error('[Service Worker] Uncaught error in message handler:', error);
    sendResponse({ error: error instanceof Error ? error.message : String(error) });
    return true;
  }
});
