import { createRoot } from 'react-dom/client';
import './style.css';
import { MainContent } from '@gitroom/extension/pages/content/main.content';
import { initializeContentScript } from '@gitroom/extension/utils/content-script-initializer';

async function initializeContent() {
  try {
    await initializeContentScript({
      maxAttempts: 10,
      attemptDelayMs: 500,
      logDebug: process.env.NODE_ENV === 'development',
    });

    const div = document.createElement('div');
    div.id = '__root';
    document.body.appendChild(div);

    const rootContainer = document.querySelector('#__root');
    if (!rootContainer) throw new Error("Can't find Content root element");
    const root = createRoot(rootContainer);
    root.render(<MainContent />);
  } catch (error) {
    console.error('[Content Script] Initialization failed:', error);
  }
}

initializeContent();
