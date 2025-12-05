/**
 * CONTENT SCRIPT INITIALIZER
 * 
 * Ensures the service worker is ready before content scripts attempt communication.
 * This prevents "Could not establish connection. Receiving end does not exist" errors.
 */

interface InitConfig {
  maxAttempts?: number;
  attemptDelayMs?: number;
  logDebug?: boolean;
}

const DEFAULT_CONFIG: InitConfig = {
  maxAttempts: 10,
  attemptDelayMs: 500,
  logDebug: process.env.NODE_ENV === 'development',
};

let initialized = false;
let initPromise: Promise<void> | null = null;

/**
 * Initialize content script communication with service worker.
 * Must be called before any message passing operations.
 */
export async function initializeContentScript(config: InitConfig = {}): Promise<void> {
  if (initialized) return;
  if (initPromise) return initPromise;

  const mergedConfig = { ...DEFAULT_CONFIG, ...config };

  initPromise = new Promise((resolve, reject) => {
    const attemptInit = async (attempt: number = 0) => {
      try {
        if (mergedConfig.logDebug) {
          console.log(`[Content Script Init] Attempt ${attempt + 1}/${mergedConfig.maxAttempts}`);
        }

        await new Promise<void>((resolveCheck, rejectCheck) => {
          const timeoutId = setTimeout(() => {
            rejectCheck(new Error('Service worker health check timeout'));
          }, 2000);

          chrome.runtime.sendMessage({ action: '__health_check__' }, (response) => {
            clearTimeout(timeoutId);

            if (chrome.runtime.lastError) {
              if (mergedConfig.logDebug) {
                console.warn(
                  `[Content Script Init] Chrome error: ${chrome.runtime.lastError.message}`
                );
              }
              rejectCheck(chrome.runtime.lastError);
            } else if (response?.status === 'healthy') {
              if (mergedConfig.logDebug) {
                console.log('[Content Script Init] Service worker is healthy');
              }
              resolveCheck();
            } else {
              rejectCheck(new Error('Service worker health check failed'));
            }
          });
        });

        initialized = true;
        resolve();
      } catch (error) {
        if (attempt < mergedConfig.maxAttempts! - 1) {
          if (mergedConfig.logDebug) {
            console.log(
              `[Content Script Init] Retrying in ${mergedConfig.attemptDelayMs}ms...`
            );
          }
          setTimeout(() => attemptInit(attempt + 1), mergedConfig.attemptDelayMs);
        } else {
          console.error('[Content Script Init] Failed to initialize after all attempts', error);
          reject(
            new Error(
              `Content script initialization failed: ${error instanceof Error ? error.message : 'Unknown error'}`
            )
          );
        }
      }
    };

    attemptInit();
  });

  return initPromise;
}

/**
 * Check if content script has been initialized
 */
export function isInitialized(): boolean {
  return initialized;
}

/**
 * Reset initialization state (for testing purposes)
 */
export function resetInitialization(): void {
  initialized = false;
  initPromise = null;
}
