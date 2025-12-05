import { saveStorageWithRetry } from '@gitroom/extension/utils/chrome-message.wrapper';

/**
 * Save a value to extension storage with automatic retry logic
 * Fixes: "Could not establish connection. Receiving end does not exist"
 */
export const saveStorage = async (key: string, value: any, maxRetries: number = 3) => {
  let lastError: Error | null = null;

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      if (process.env.NODE_ENV === 'development') {
        console.log(`[Storage] Saving key: ${key} (attempt ${attempt + 1}/${maxRetries})`);
      }

      const result = await saveStorageWithRetry(key, value);

      if (process.env.NODE_ENV === 'development') {
        console.log(`[Storage] Successfully saved key: ${key}`);
      }

      return result;
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      if (process.env.NODE_ENV === 'development') {
        console.warn(`[Storage] Attempt ${attempt + 1} failed:`, lastError.message);
      }

      if (attempt < maxRetries - 1) {
        const delayMs = Math.min(1000 * Math.pow(2, attempt), 5000);
        await new Promise((resolve) => setTimeout(resolve, delayMs));
      }
    }
  }

  console.error('[Storage] Failed to save key after all retries:', key, lastError);
  throw lastError || new Error(`Failed to save storage key: ${key}`);
};
