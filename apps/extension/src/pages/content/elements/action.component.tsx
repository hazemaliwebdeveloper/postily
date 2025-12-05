import { FC, memo, useCallback, useEffect, useState } from 'react';
import { ProviderInterface } from '@gitroom/extension/providers/provider.interface';
import { fetchCookie } from '@gitroom/extension/utils/load.cookie';
import './action.component.css';

const Comp: FC<{ removeModal: () => void; platform: string; style: string }> = (
  props
) => {
  const load = useCallback(async () => {
    try {
      const cookie = await fetchCookie(`auth`);
      
      if (!cookie) {
        console.warn('[Action Component] No authentication cookie found');
        props.removeModal();
        return;
      }

      if (document.querySelector('iframe#modal-pozmixal')) {
        return;
      }

      const div = document.createElement('div');
      div.className = 'modal-overlay';
      document.body.appendChild(div);

      const iframe = document.createElement('iframe');
      iframe.className = 'modal-iframe';
      // @ts-ignore
      iframe.allowTransparency = 'true';
      iframe.src =
        (import.meta.env?.FRONTEND_URL || process?.env?.FRONTEND_URL) +
        `/modal/${props.style}/${props.platform}?loggedAuth=${cookie}`;
      iframe.id = 'modal-pozmixal';
      div.appendChild(iframe);

      window.addEventListener('message', (event) => {
        if (event.data.action === 'closeIframe') {
          const iframe = document.querySelector('iframe#modal-pozmixal');
          if (iframe) {
            props.removeModal();
            div.remove();
          }
        }
      });
    } catch (error) {
      console.error('[Action Component] Failed to load authentication:', error);
      props.removeModal();
      return;
    }
  }, [props]);
  
  useEffect(() => {
    load();
  }, [load]);
  return <></>;
};
export const ActionComponent: FC<{
  target: Node;
  keyIndex: number;
  actionType: string;
  provider: ProviderInterface;
  wrap: boolean;
  selector: string;
}> = memo((props) => {
  const { provider, selector, target } = props;
  const [modal, showModal] = useState(false);
  const handle = useCallback(async (e: any) => {
    showModal(true);
    e.preventDefault();
    e.stopPropagation();
  }, []);

  useEffect(() => {
    const blockingDiv = document.createElement('div');
    if (document.querySelector(`.${selector}`)) {
      console.log('already exists');
      return;
    }

    setTimeout(() => {
      // @ts-ignore
      const targetInformation = target.getBoundingClientRect();
      blockingDiv.id = 'blockingDiv';
      blockingDiv.className = `blocking-div ${selector}`;
      blockingDiv.style.top = `${targetInformation.top}px`;
      blockingDiv.style.left = `${targetInformation.left}px`;
      blockingDiv.style.width = `${targetInformation.width}px`;
      blockingDiv.style.height = `${targetInformation.height}px`;
      blockingDiv.style.zIndex = '9999';

      document.body.appendChild(blockingDiv);
      blockingDiv.addEventListener('click', handle);
    }, 1000);
    return () => {
      blockingDiv.removeEventListener('click', handle);
      blockingDiv.remove();
    };
  }, [handle, selector, target]);

  return (
    <div className="g-wrapper">
      <div className="absolute start-0 top-0 z-[9999] w-full h-full" />
      {modal && (
        <Comp
          platform={provider.identifier}
          style={provider.style}
          removeModal={() => showModal(false)}
        />
      )}
    </div>
  );
});
