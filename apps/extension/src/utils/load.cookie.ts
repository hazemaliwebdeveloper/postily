import { loadCookieWithRetry } from '@gitroom/extension/utils/chrome-message.wrapper';

/**
 * Fetch a cookie value with automatic retry logic
 * Fixes: "Could not establish connection. Receiving end does not exist"
 * 
 * This function includes robust error handling for content script scenarios
 * where the service worker might not be immediately available.
 */
export const fetchCookie = async (cookieName: string, maxRetries: number = 3) => {
  let lastError: Error | null = null;

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      if (process.env.NODE_ENV === 'development') {
        console.log(`[Cookie] Fetching cookie: ${cookieName} (attempt ${attempt + 1}/${maxRetries})`);
      }

      const result = await loadCookieWithRetry(cookieName);

      if (process.env.NODE_ENV === 'development') {
        console.log(`[Cookie] Successfully fetched cookie: ${cookieName}`);
      }

      return result;
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      if (process.env.NODE_ENV === 'development') {
        console.warn(
          `[Cookie] Attempt ${attempt + 1} failed:`,
          lastError.message
        );
      }

      if (attempt < maxRetries - 1) {
        const delayMs = Math.min(1000 * Math.pow(2, attempt), 5000);
        await new Promise((resolve) => setTimeout(resolve, delayMs));
      }
    }
  }

  console.error('[Cookie] Failed to fetch cookie after all retries:', cookieName, lastError);
  throw lastError || new Error(`Failed to fetch cookie: ${cookieName}`);
};

export const getCookie = async (
  cookies: chrome.cookies.Cookie[],
  cookie: string
) => {
  // return cookies.find((c) => c.name === cookie).value;
};
