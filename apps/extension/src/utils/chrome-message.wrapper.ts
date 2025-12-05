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
}

const DEFAULT_OPTIONS: RetryOptions = {
  maxRetries: 3,
  initialDelayMs: 100,
  maxDelayMs: 2000,
  timeoutMs: 5000,
};

/**
 * Helper: Calculate exponential backoff delay
 */
function getBackoffDelay(attempt: number, maxDelay: number, initialDelay: number): number {
  const exponentialDelay = initialDelay * Math.pow(2, attempt);
  return Math.min(exponentialDelay, maxDelay);
}

/**
 * Core wrapper: Send message to service worker with retry logic and timeout
 */
export async function sendMessageWithRetry<T = any>(
  message: any,
  options: RetryOptions = {}
): Promise<T> {
  const config = { ...DEFAULT_OPTIONS, ...options };
  let lastError: Error | null = null;

  for (let attempt = 0; attempt <= config.maxRetries!; attempt++) {
    try {
      return await new Promise((resolve, reject) => {
        // Set up timeout
        const timeoutId = setTimeout(() => {
          reject(new Error(`Chrome extension message timeout after ${config.timeoutMs}ms`));
        }, config.timeoutMs);

        // Send message with response handler
        chrome.runtime.sendMessage(message, (response) => {
          clearTimeout(timeoutId);

          // Handle Chrome runtime errors
          if (chrome.runtime.lastError) {
            reject(new Error(`Chrome extension error: ${chrome.runtime.lastError.message}`));
            return;
          }

          // Handle server-side errors in response
          if (response?.error) {
            reject(new Error(`Service worker error: ${response.error}`));
            return;
          }

          resolve(response);
        });
      });
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      // Don't retry on certain errors
      if (
        lastError.message.includes('Extension context invalidated') ||
        lastError.message.includes('The message port closed')
      ) {
        throw lastError;
      }

      // If this was the last attempt, throw
      if (attempt === config.maxRetries) {
        throw new Error(
          `Failed to establish connection after ${config.maxRetries! + 1} attempts. Last error: ${lastError.message}`
        );
      }

      // Wait before retrying with exponential backoff
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
    options
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
    options
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
    options
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
    options
  );
}
