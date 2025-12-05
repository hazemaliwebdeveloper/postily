import { makeHttpRequest } from '@gitroom/extension/utils/chrome-message.wrapper';

const isDev = process.env.NODE_ENV === 'development';

/**
 * Send HTTP request through the service worker with automatic retry logic
 * Fixes: "Could not establish connection. Receiving end does not exist"
 * 
 * The service worker acts as a proxy to bypass CORS restrictions
 */
export const sendRequest = async (
  auth: string,
  url: string,
  method: 'GET' | 'POST' = 'GET',
  body?: string
) => {
  try {
    if (isDev) {
      console.log('[Request] Sending request:', { url, method });
    }

    const response = await makeHttpRequest(auth, url, method, body);

    if (isDev) {
      console.log('[Request] Request successful:', url);
    }

    return response;
  } catch (error) {
    console.error('[Request] Failed to send request:', { url, method }, error);
    throw error;
  }
};

/**
 * Internal utility: Fetch HTTP request (executed by service worker)
 * This function runs in the service worker context, so it has fetch access
 */
export const fetchRequestUtil = async (request: any) => {
  try {
    const baseUrl = import.meta.env?.FRONTEND_URL || process?.env?.FRONTEND_URL || 'http://localhost:4200';
    const requestUrl = `${baseUrl}${request.url}`;

    if (isDev) {
      console.log('[FetchUtil] Making HTTP request:', { url: requestUrl, method: request.method });
    }

    const response = await fetch(requestUrl, {
      method: request.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...(request.auth ? { Authorization: request.auth } : {}),
      },
      ...(request.body ? { body: request.body } : {}),
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const data = await response.json();

    if (isDev) {
      console.log('[FetchUtil] Request successful:', requestUrl);
    }

    return data;
  } catch (error) {
    console.error('[FetchUtil] Fetch request failed:', error);
    throw error;
  }
};
