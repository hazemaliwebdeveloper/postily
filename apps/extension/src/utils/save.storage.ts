import { saveStorageWithRetry } from '@gitroom/extension/utils/chrome-message.wrapper';

/**
 * Save a value to extension storage with automatic retry logic
 * Fixes: "Could not establish connection. Receiving end does not exist"
 */
export const saveStorage = async (key: string, value: any) => {
  try {
    return await saveStorageWithRetry(key, value);
  } catch (error) {
    console.error('[Storage] Failed to save storage key:', key, error);
    throw error;
  }
};
