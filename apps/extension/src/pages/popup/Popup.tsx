import React, { FC, useCallback, useEffect, useMemo, useState } from 'react';
import { ProviderList } from '@gitroom/extension/providers/provider.list';
import { fetchCookie } from '@gitroom/extension/utils/load.cookie';
import { waitForServiceWorkerReady } from '@gitroom/extension/utils/chrome-message.wrapper';

export const PopupContainerContainer: FC = () => {
  const [url, setUrl] = useState<string | null>(null);
  const [swReady, setSwReady] = useState(false);

  useEffect(() => {
    /**
     * Initialize: Wait for service worker, then get current tab URL
     * This ensures the message listener is ready before sending messages
     */
    async function initPopup() {
      try {
        // First, wait for service worker to be ready
        await waitForServiceWorkerReady(5000);
        setSwReady(true);

        // Then get the current tab URL
        chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
          setUrl(tabs[0]?.url || null);
        });
      } catch (error) {
        console.error('[Popup] Service worker initialization failed:', error);
        setUrl(null); // Show error state
      }
    }

    initPopup();
  }, []);

  if (!swReady) {
    return <div className="text-lg p-4">Initializing extension...</div>;
  }

  if (!url) {
    return <div className="text-lg p-4">This website is not supported by Pozmixal</div>;
  }

  return <PopupContainer url={url} />;
};

export const PopupContainer: FC<{ url: string }> = (props) => {
  const { url } = props;
  const [isLoggedIn, setIsLoggedIn] = useState<false | string>(false);
  const [isLoading, setIsLoading] = useState(true);
  const provider = useMemo(() => {
    return ProviderList.find((p) => {
      return p.baseUrl.indexOf(new URL(url).hostname) > -1;
    });
  }, [url]);

  const loadCookie = useCallback(async () => {
    try {
      if (!provider) {
        setIsLoading(false);
        return;
      }

      if (process.env.NODE_ENV === 'development') {
        console.log('[Popup] Loading cookie for provider:', provider.name);
      }

      const auth = await fetchCookie('auth');

      if (auth) {
        setIsLoggedIn(auth);
      }

      setIsLoading(false);
    } catch (error) {
      console.error('[Popup] Failed to load cookie:', error);
      setIsLoading(false);
    }
  }, [provider]);

  useEffect(() => {
    loadCookie();
  }, [loadCookie]);

  if (isLoading) {
    return <div className="text-lg p-4">Loading...</div>;
  }

  if (!provider) {
    return <div className="text-lg p-4">This website is not supported by Pozmixal</div>;
  }

  if (!isLoggedIn) {
    return <div className="text-lg p-4">You are not logged in to Pozmixal</div>;
  }

  return <div />;
};

export default function Popup() {
  return (
    <div className="flex justify-center items-center h-screen">
      <PopupContainerContainer />
    </div>
  );
}
