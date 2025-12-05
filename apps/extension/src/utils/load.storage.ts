import { loadStorageWithRetry } from '@gitroom/extension/utils/chrome-message.wrapper';

/**
 * Fetch a value from extension storage with automatic retry logic
 * Fixes: "Could not establish connection. Receiving end does not exist"
 */
export const fetchStorage = async (key: string) => {
  try {
    return await loadStorageWithRetry(key);
  } catch (error) {
    console.error('[Storage] Failed to fetch storage key:', key, error);
    throw error;
  }
};
