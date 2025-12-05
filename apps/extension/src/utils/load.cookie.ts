import { loadCookieWithRetry } from '@gitroom/extension/utils/chrome-message.wrapper';

/**
 * Fetch a cookie value with automatic retry logic
 * Fixes: "Could not establish connection. Receiving end does not exist"
 */
export const fetchCookie = async (cookieName: string) => {
  try {
    return await loadCookieWithRetry(cookieName);
  } catch (error) {
    console.error('[Cookie] Failed to fetch cookie:', cookieName, error);
    throw error;
  }
};

export const getCookie = async (
  cookies: chrome.cookies.Cookie[],
  cookie: string
) => {
  // return cookies.find((c) => c.name === cookie).value;
};
