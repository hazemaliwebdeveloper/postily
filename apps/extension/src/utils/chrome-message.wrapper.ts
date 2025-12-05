/**
 * CHROME EXTENSION MESSAGE WRAPPER WITH RETRY LOGIC
 * Fixes: "Could not establish connection. Receiving end does not exist"
 * 
 * This module ensures reliable communication with the service worker by:
 * 1. Adding exponential backoff retry logic
 * 2. Handling Chrome API errors properly
 * 3. Providing timeout protection
 * 4. Graceful fallback mechanisms
 */

interface RetryOptions {
  maxRetries?: number;
  initialDelayMs?: number;
  maxDelayMs?: number;
  timeoutMs?: number;
  isContentScript?: boolean;
}

const DEFAULT_OPTIONS: RetryOptions = {
  maxRetries: 3,
  initialDelayMs: 100,
  maxDelayMs: 2000,
  timeoutMs: 5000,
};

const CONTENT_SCRIPT_OPTIONS: RetryOptions = {
  maxRetries: 5,
  initialDelayMs: 200,
  maxDelayMs: 3000,
  timeoutMs: 8000,
};

let serviceWorkerReady = false;
let serviceWorkerReadyPromise: Promise<void> | null = null;

/**
 * Helper: Calculate exponential backoff delay
 */
function getBackoffDelay(attempt: number, maxDelay: number, initialDelay: number): number {
  const exponentialDelay = initialDelay * Math.pow(2, attempt);
  return Math.min(exponentialDelay, maxDelay);
}

/**
 * Initialize service worker readiness check (content script safe)
 */
function initializeServiceWorkerReadiness(): void {
  if (serviceWorkerReadyPromise) return;

  serviceWorkerReadyPromise = new Promise((resolve) => {
    const checkReady = async () => {
      try {
        const response = await new Promise<any>((resolveCheck, rejectCheck) => {
          const timeoutId = setTimeout(() => {
            rejectCheck(new Error('Timeout waiting for service worker'));
          }, 1000);

          chrome.runtime.sendMessage({ action: '__health_check__' }, (response) => {
            clearTimeout(timeoutId);
            if (chrome.runtime.lastError) {
              rejectCheck(chrome.runtime.lastError);
            } else {
              resolveCheck(response);
            }
          });
        });

        if (response) {
          serviceWorkerReady = true;
          resolve();
        }
      } catch {
        setTimeout(checkReady, 100);
      }
    };

    checkReady();
  });
}

/**
 * Core wrapper: Send message to service worker with retry logic and timeout
 */
export async function sendMessageWithRetry<T = any>(
  message: any,
  options: RetryOptions = {}
): Promise<T> {
  const { isContentScript, ...restOptions } = options;
  const config = {
    ...(isContentScript ? CONTENT_SCRIPT_OPTIONS : DEFAULT_OPTIONS),
    ...restOptions,
  };

  initializeServiceWorkerReadiness();
  if (isContentScript && !serviceWorkerReady) {
    await serviceWorkerReadyPromise;
  }

  let lastError: Error | null = null;

  for (let attempt = 0; attempt <= config.maxRetries!; attempt++) {
    try {
      return await new Promise((resolve, reject) => {
        const timeoutId = setTimeout(() => {
          reject(new Error(`Chrome extension message timeout after ${config.timeoutMs}ms`));
        }, config.timeoutMs);

        chrome.runtime.sendMessage(message, (response) => {
          clearTimeout(timeoutId);

          if (chrome.runtime.lastError) {
            reject(new Error(`Chrome extension error: ${chrome.runtime.lastError.message}`));
            return;
          }

          if (response?.error) {
            reject(new Error(`Service worker error: ${response.error}`));
            return;
          }

          resolve(response);
        });
      });
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      if (
        lastError.message.includes('Extension context invalidated') ||
        lastError.message.includes('The message port closed')
      ) {
        throw lastError;
      }

      if (attempt === config.maxRetries) {
        throw new Error(
          `Failed to establish connection after ${config.maxRetries! + 1} attempts. Last error: ${lastError.message}`
        );
      }

      const delayMs = getBackoffDelay(attempt, config.maxDelayMs!, config.initialDelayMs!);
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }
  }

  throw lastError || new Error('Unknown error in message retry logic');
}

/**
 * Wrapper: Wait for service worker to be ready
 * Polls the extension state to ensure the service worker is active
 */
export async function waitForServiceWorkerReady(timeoutMs: number = 5000): Promise<void> {
  const startTime = Date.now();

  while (Date.now() - startTime < timeoutMs) {
    try {
      // Try a simple ping message
      const response = await sendMessageWithRetry(
        { action: 'ping' },
        { maxRetries: 0, timeoutMs: 500 }
      );

      if (response) {
        return; // Service worker is ready
      }
    } catch {
      // Not ready yet, will retry
    }

    // Wait 100ms before retrying
    await new Promise((resolve) => setTimeout(resolve, 100));
  }

  throw new Error(`Service worker not ready after ${timeoutMs}ms`);
}

/**
 * Enhanced API for making HTTP requests through the service worker
 */
export async function makeHttpRequest(
  auth: string,
  url: string,
  method: 'GET' | 'POST' = 'GET',
  body?: string,
  options: RetryOptions = {}
) {
  return sendMessageWithRetry(
    {
      action: 'makeHttpRequest',
      url,
      method,
      body,
      auth,
    },
    { isContentScript: true, ...options }
  );
}

/**
 * Enhanced API for storage operations with retry logic
 */
export async function loadStorageWithRetry(key: string, options: RetryOptions = {}) {
  return sendMessageWithRetry(
    {
      action: 'loadStorage',
      key,
    },
    { isContentScript: true, ...options }
  );
}

export async function saveStorageWithRetry(
  key: string,
  value: any,
  options: RetryOptions = {}
) {
  return sendMessageWithRetry(
    {
      action: 'saveStorage',
      key,
      value,
    },
    { isContentScript: true, ...options }
  );
}

/**
 * Enhanced API for cookie operations with retry logic
 */
export async function loadCookieWithRetry(
  cookieName: string,
  options: RetryOptions = {}
) {
  return sendMessageWithRetry(
    {
      action: 'loadCookie',
      cookieName,
    },
    { isContentScript: true, ...options }
  );
}
